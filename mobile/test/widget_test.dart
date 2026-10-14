import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lola_pay_mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

DemoApi sandboxApi({bool offline = false}) =>
    DemoApi(client: MockClient((request) async {
      if (offline) throw Exception('offline');
      if (request.url.path.endsWith('/wallet')) {
        return http.Response(
            jsonEncode({
              'environment': 'sandbox',
              'balanceXof': 25000,
              'user': {'phone': '+229 01 23 45 67 89'}
            }),
            200);
      }
      if (request.url.path.endsWith('/quote')) {
        return http.Response(
            jsonEncode({
              'network': 'MTN Mobile Money',
              'amountXof': 10000,
              'creditedXof': 10000,
              'feeXof': 0,
              'totalXof': 10000
            }),
            200);
      }
      return http.Response('[]', 200);
    }));

Future<void> launch(WidgetTester tester,
    {double width = 390, double scale = 1, bool offline = false}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
  await tester.pumpWidget(LolaPayApp(api: sandboxApi(offline: offline), requireAuth: false));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('swipe change l’espace et conserve les actions communes',
      (tester) async {
    await launch(tester);
    expect(find.text('25 000 FCFA'), findsOneWidget);
    expect(find.text('Bénéficiaires favoris'), findsOneWidget);
    expect(tester.getCenter(find.byKey(const ValueKey('bottom-recharge'))).dx, closeTo(195, 0.5));
    await tester.drag(
        find.byKey(const ValueKey('home-pages')), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('Cartes & paiements'), findsOneWidget);
    expect(find.text('Services cartes'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-Envoyer')), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-recharge')), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-Historique')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('bottom-Historique')));
    await tester.pumpAndSettle();
    expect(find.text('Historique'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('page-dot-0')).last);
    await tester.pumpAndSettle();
    expect(find.text('25 000 FCFA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('masque puis réaffiche le solde', (tester) async {
    await launch(tester);
    await tester.tap(find.byKey(const ValueKey('toggle-balance')));
    await tester.pumpAndSettle();
    expect(find.text('25 000 FCFA'), findsNothing);
    expect(find.text('•••••• FCFA'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('toggle-balance')));
    await tester.pumpAndSettle();
    expect(find.text('25 000 FCFA'), findsOneWidget);
  });

  testWidgets('ajout de bénéficiaire validé et conservé localement',
      (tester) async {
    await launch(tester);
    await tester.tap(find.byKey(const ValueKey('add-favorite')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-favorite')));
    await tester.pumpAndSettle();
    expect(find.text('Indique son nom.'), findsOneWidget);
    await tester.enterText(
        find.byKey(const ValueKey('favorite-name')), 'Ada Test');
    await tester.enterText(
        find.byKey(const ValueKey('favorite-phone')), '01 23 45 67 89');
    await tester.tap(find.byKey(const ValueKey('save-favorite')));
    await tester.pumpAndSettle();
    expect(find.text('Ada Test'), findsOneWidget);
    final storage = await SharedPreferences.getInstance();
    expect(storage.getString('lola.favorites.v1'), contains('Ada Test'));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(LolaPayApp(api: sandboxApi(), requireAuth: false));
    await tester.pumpAndSettle();
    expect(find.text('Ada Test'), findsOneWidget);
  });

  testWidgets('recharge commune ouvre le devis sandbox', (tester) async {
    await launch(tester);
    await tester.drag(
        find.byKey(const ValueKey('home-pages')), const Offset(-350, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bottom-recharge')));
    await tester.pumpAndSettle();
    expect(find.text('Autre réseau compatible'), findsOneWidget);
    await tester.tap(find.text('10 000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Vérifier et confirmer'), findsOneWidget);
    expect(find.text('Montant total'), findsOneWidget);
    expect(find.text('Confirmer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sans API aucun faux solde et une action de récupération',
      (tester) async {
    await launch(tester, offline: true);
    expect(find.text('Indisponible'), findsOneWidget);
    expect(find.text('0 FCFA'), findsNothing);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0]) {
    testWidgets(
        'deux espaces sans débordement à ${width.toInt()} dp et texte agrandi',
        (tester) async {
      await launch(tester, width: width, scale: 1.3);
      expect(tester.takeException(), isNull);
      await tester.drag(
          find.byKey(const ValueKey('home-pages')), Offset(-width, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
          find.byKey(const ValueKey('home-pages')), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  group('connexion par numéro et code OTP', () {
    Future<void> openApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
          LolaPayApp(api: sandboxApi(), auth: DemoAuthRepository()));
      await tester.pumpAndSettle();
    }

    testWidgets('première connexion : numéro, code, profil puis Mon argent',
        (tester) async {
      await openApp(tester);
      expect(find.text('Bienvenue sur Lola Pay'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('auth-phone-field')), '01 23 45 67 89');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Code de vérification'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('auth-otp-field')), '123456');
      await tester.pumpAndSettle();
      expect(find.text('Crée ton profil'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('auth-first-name')), 'Ada');
      await tester.enterText(
          find.byKey(const ValueKey('auth-last-name')), 'Test');
      await tester.enterText(
          find.byKey(const ValueKey('auth-create-pin')), '1234');
      await tester.tap(find.byKey(const ValueKey('auth-terms')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Créer mon compte'));
      await tester.pumpAndSettle();
      expect(find.text('25 000 FCFA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('numéro invalide et mauvais code affichent une erreur',
        (tester) async {
      await openApp(tester);
      await tester.enterText(
          find.byKey(const ValueKey('auth-phone-field')), '12 34');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      expect(find.text('Indique les 10 chiffres, en commençant par 01.'),
          findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('auth-phone-field')), '0123456789');
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const ValueKey('auth-otp-field')), '000000');
      await tester.pumpAndSettle();
      expect(find.textContaining('Code incorrect'), findsOneWidget);
    });

    testWidgets('retour dans l’app : verrouillage par PIN', (tester) async {
      SharedPreferences.setMockInitialValues({
        'lola.demo.session': '+2290123456789',
        'lola.demo.profiles': jsonEncode({
          '+2290123456789': {'firstName': 'Ada', 'lastName': 'Test'}
        }),
        'lola.pin.+2290123456789': '1234',
        'lola.auth.lastPhone': '+2290123456789',
      });
      await openApp(tester);
      expect(find.text('Bon retour, Ada'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('auth-pin-field')), '0000');
      await tester.pumpAndSettle();
      expect(find.textContaining('Code PIN incorrect'), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('auth-pin-field')), '1234');
      await tester.pumpAndSettle();
      expect(find.text('25 000 FCFA'), findsOneWidget);
    });
  });
}
