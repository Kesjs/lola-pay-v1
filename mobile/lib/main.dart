import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'home.dart';
part 'flows.dart';
part 'auth.dart';

const primary = Color(0xFF176B50);
const primaryDark = Color(0xFF123D32);
const pageBackground = Color(0xFFF7F8FA);
const tint = Color(0xFFEAF4EF);
const muted = Color(0xFF52625B);

// Supabase Auth : flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
// Sans ces deux valeurs, l'app utilise la connexion de démonstration (code 123456).
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AuthRepository auth;
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await sb.Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    auth = SupabaseAuthRepository();
  } else {
    auth = DemoAuthRepository();
  }
  runApp(LolaPayApp(auth: auth));
}

class LolaPayApp extends StatelessWidget {
  const LolaPayApp({super.key, this.api, this.auth, this.requireAuth = true});
  final DemoApi? api;
  final AuthRepository? auth;
  final bool requireAuth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lola Pay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(
            primary: primary, onPrimary: Colors.white, surface: Colors.white),
        bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: pageBackground,
            surfaceTintColor: Colors.transparent),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8E4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8E4)),
          ),
        ),
      ),
      home: requireAuth
          ? AuthGate(
              repo: auth ?? DemoAuthRepository(),
              builder: (signOut) => HomeShell(api: api, onSignOut: signOut))
          : HomeShell(api: api),
    );
  }
}

class DemoApi {
  DemoApi({http.Client? client}) : client = client ?? http.Client();
  final http.Client client;
  // Android emulator -> host machine. Use localhost on iOS simulator/web.
  static const baseUrl = String.fromEnvironment(
    'LOLA_API_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  Future<Map<String, dynamic>> wallet() async {
    final response = await client
        .get(Uri.parse('$baseUrl/wallet'))
        .timeout(const Duration(seconds: 10));
    _ensureOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> transactions() async {
    final response = await client
        .get(Uri.parse('$baseUrl/transactions'))
        .timeout(const Duration(seconds: 10));
    _ensureOk(response);
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> quote(String network, int amountXof) async {
    final response = await client.post(
      Uri.parse('$baseUrl/transactions/quote'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'network': network, 'amountXof': amountXof}),
    );
    _ensureOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> recharge(
    String network,
    int amountXof,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/transactions/recharge'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'network': network,
        'amountXof': amountXof,
        'idempotencyKey': 'mobile-${DateTime.now().microsecondsSinceEpoch}',
      }),
    );
    _ensureOk(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> waitForResult(String id) async {
    for (var attempt = 0; attempt < 12; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final response = await client
          .get(Uri.parse('$baseUrl/transactions/$id'))
          .timeout(const Duration(seconds: 10));
      _ensureOk(response);
      final transaction = jsonDecode(response.body) as Map<String, dynamic>;
      final status = transaction['status'] as String?;
      if (status == 'succeeded' || status == 'failed') return transaction;
    }
    throw Exception('Le statut de la recharge est toujours en attente.');
  }

  void _ensureOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erreur API (${response.statusCode})');
    }
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(
      {required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [
        Expanded(
            flex: 2, child: Text(label, style: const TextStyle(color: muted))),
        const SizedBox(width: 12),
        Expanded(
            flex: 3,
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    color: bold ? primaryDark : muted)))
      ]));
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: const Color(0xFFFFF5F2),
          border: Border.all(color: const Color(0xFFF1D4CC)),
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 19),
        const SizedBox(width: 9),
        Expanded(
            child: Text(message,
                style: const TextStyle(color: Color(0xFF8B3828), fontSize: 12)))
      ]));
}

String _formatXof(num value) {
  final digits = value.toInt().abs().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]} ',
      );
  return '${value < 0 ? '−' : ''}$digits FCFA';
}
