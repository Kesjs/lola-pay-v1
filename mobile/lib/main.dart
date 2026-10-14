import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

part 'home.dart';

const primary = Color(0xFF176B50);
const primaryDark = Color(0xFF123D32);
const pageBackground = Color(0xFFF7F8FA);
const tint = Color(0xFFEAF4EF);
const muted = Color(0xFF52625B);

void main() {
  runApp(const LolaPayApp());
}

class LolaPayApp extends StatelessWidget {
  const LolaPayApp({super.key, this.api});
  final DemoApi? api;

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
      home: HomeShell(api: api),
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

class RechargeSheet extends StatefulWidget {
  const RechargeSheet({required this.api, required this.onComplete, super.key});

  final DemoApi api;
  final Future<void> Function() onComplete;

  @override
  State<RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<RechargeSheet> {
  final amountController = TextEditingController(text: '10000');
  var network = 'MTN Mobile Money';
  Map<String, dynamic>? quote;
  Map<String, dynamic>? result;
  String? error;
  var busy = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> getQuote() async {
    final amount = int.tryParse(amountController.text.replaceAll(' ', ''));
    if (amount == null || amount < 100) {
      setState(() => error = 'Entre un montant d’au moins 100 FCFA.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final nextQuote = await widget.api.quote(network, amount);
      if (!mounted) return;
      setState(() {
        quote = nextQuote;
        busy = false;
      });
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception.toString().replaceFirst('Exception: ', '');
        busy = false;
      });
    }
  }

  Future<void> confirm() async {
    final amount = (quote?['amountXof'] as num?)?.toInt();
    if (amount == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final created = await widget.api.recharge(network, amount);
      final finalTransaction =
          await widget.api.waitForResult(created['id'] as String);
      if (!mounted) return;
      setState(() {
        result = finalTransaction;
        busy = false;
      });
      await widget.onComplete();
    } catch (exception) {
      if (!mounted) return;
      setState(() {
        error = exception.toString().replaceFirst('Exception: ', '');
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(
                tooltip: 'Retour',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20)),
            Expanded(
                child: Text(result == null ? 'Recharger' : 'Recharge réussie',
                    style: const TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            child: result != null
                ? _ResultView(
                    key: const ValueKey('recharge-success'),
                    transaction: result!)
                : quote == null
                    ? _AmountForm(
                        key: const ValueKey('recharge-form'),
                        network: network,
                        amountController: amountController,
                        onNetworkChanged: (value) =>
                            setState(() => network = value!),
                        onSubmit: getQuote,
                        busy: busy)
                    : _QuoteView(
                        key: const ValueKey('recharge-confirm'),
                        quote: quote!,
                        onBack: () => setState(() => quote = null),
                        onConfirm: confirm,
                        busy: busy),
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBox(message: error!)
          ],
        ]),
      ),
    );
  }
}

class _AmountForm extends StatelessWidget {
  const _AmountForm(
      {required this.network,
      required this.amountController,
      required this.onNetworkChanged,
      required this.onSubmit,
      required this.busy,
      super.key});
  final String network;
  final TextEditingController amountController;
  final ValueChanged<String?> onNetworkChanged;
  final VoidCallback onSubmit;
  final bool busy;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Réseau source',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        const Text('Choix du réseau',
            style: TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 10),
        ...const [
          'MTN Mobile Money',
          'Moov Money',
          'Celtiis Cash',
          'Autre réseau compatible'
        ].map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NetworkOption(
                name: item,
                selected: item == network,
                onTap: () => onNetworkChanged(item)),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final preset in ['1 000', '5 000', '10 000', '25 000'])
            ActionChip(
                label: Text(preset),
                onPressed: () =>
                    amountController.text = preset.replaceAll(' ', '')),
        ]),
        const SizedBox(height: 12),
        TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Autre montant', suffixText: 'FCFA')),
        SizedBox(height: MediaQuery.sizeOf(context).height > 700 ? 48 : 24),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: busy ? null : onSubmit,
                child: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Voir le récapitulatif')))
      ]);
}

class _NetworkOption extends StatelessWidget {
  const _NetworkOption(
      {required this.name, required this.selected, required this.onTap});
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final short = name.startsWith('MTN')
        ? 'MTN'
        : name.startsWith('Moov')
            ? 'M'
            : name.startsWith('Celtiis')
                ? 'C'
                : '✣';
    final color = name.startsWith('MTN')
        ? const Color(0xFFFFD500)
        : name.startsWith('Moov')
            ? const Color(0xFF1476D4)
            : name.startsWith('Celtiis')
                ? const Color(0xFF19A45B)
                : const Color(0xFFDCE8FF);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              border: Border.all(
                  color: selected ? primary : _border,
                  width: selected ? 1.5 : 1),
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: Text(short,
                    style: TextStyle(
                        color:
                            name.startsWith('MTN') || name.startsWith('Autre')
                                ? primaryDark
                                : Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 10))),
            const SizedBox(width: 12),
            Expanded(
                child: Text(name,
                    style: const TextStyle(
                        color: _ink, fontWeight: FontWeight.w600))),
            Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? primary : muted, size: 21)
          ]),
        ),
      ),
    );
  }
}

class _FlowInfoCard extends StatelessWidget {
  const _FlowInfoCard(
      {required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFEAF4EF),
          borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: primaryDark, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(body,
              style: const TextStyle(color: muted, fontSize: 12, height: 1.4)),
        ])),
      ]));
}

class _QuoteView extends StatelessWidget {
  const _QuoteView(
      {required this.quote,
      required this.onBack,
      required this.onConfirm,
      required this.busy,
      super.key});
  final Map<String, dynamic> quote;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  final bool busy;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Vérifie avant de confirmer',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _SummaryLine(label: 'Réseau', value: quote['network'].toString()),
        _SummaryLine(
            label: 'Montant crédité',
            value: _formatXof(quote['creditedXof'] as num)),
        _SummaryLine(label: 'Frais', value: _formatXof(quote['feeXof'] as num)),
        const Divider(height: 26),
        const _FlowInfoCard(
            icon: Icons.verified_outlined,
            title: 'Vérifie les détails',
            body: 'Aucun montant ne sera débité avant ta confirmation.'),
        const SizedBox(height: 18),
        _SummaryLine(
            label: 'Total à payer',
            value: _formatXof(quote['totalXof'] as num),
            bold: true),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: busy ? null : onBack,
                  child: const Text('Modifier'))),
          const SizedBox(width: 10),
          Expanded(
              child: FilledButton(
                  onPressed: busy ? null : onConfirm,
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmer')))
        ])
      ]);
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.transaction, super.key});
  final Map<String, dynamic> transaction;
  @override
  Widget build(BuildContext context) {
    final success = transaction['status'] == 'succeeded';
    return Center(
        child: Column(children: [
      Icon(success ? Icons.check_circle : Icons.error,
          color: success ? primary : Colors.red, size: 58),
      const SizedBox(height: 12),
      Text(success ? 'Recharge réussie' : 'Recharge échouée',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(_formatXof(transaction['amountXof'] as num),
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: primary, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Text(transaction['reference'].toString(),
          style: const TextStyle(color: muted)),
      const SizedBox(height: 24),
      SizedBox(
          width: double.infinity,
          child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Terminer')))
    ]));
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
