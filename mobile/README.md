# Lola Pay mobile

Application Flutter Android. Accueil validé le 13 octobre 2026 : deux espaces par swipe, palette verte #176B50, cartes blanches et barre commune Envoyer / Recharger / Historique / Plus.

- Mon argent : solde fourni par l’API, masquage, recharge sandbox, favoris enregistrés sur le téléphone et dernières opérations.
- Cartes & paiements : carte virtuelle, carte physique et encaissement, avec des états explicites pour les services indisponibles.
- La recharge suit le devis, la confirmation et le statut API. Transferts, retraits, émission de cartes et SoftPOS ne simulent aucun succès.

## Lancer

Depuis la racine : `npm run dev:api`. Dans mobile/ : `flutter pub get`, puis `flutter run`.

L’émulateur Android utilise http://10.0.2.2:3000/api. Sur téléphone physique, utiliser `flutter run --dart-define=LOLA_API_URL=http://ADRESSE_LAN:3000/api`, sur le même réseau que l’ordinateur.

Sans API accessible, le solde est indiqué indisponible et une action Réessayer est proposée.

## Vérifier et construire

`flutter analyze`

`flutter test`

`flutter build apk --debug`

APK : build/app/outputs/flutter-apk/app-debug.apk. Cette démonstration locale utilise uniquement des fonds fictifs.
