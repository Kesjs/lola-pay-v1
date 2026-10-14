part of 'main.dart';

// Écrans 3 à 8 de la maquette : Recharger, Confirmation, Succès,
// Transfert, Retrait, Historique.

const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre'
];

String _two(int value) => value.toString().padLeft(2, '0');

String _frenchDate(dynamic value, {bool withYear = true}) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '';
  final day = '${date.day} ${_months[date.month - 1]}';
  final year = withYear ? ' ${date.year}' : '';
  return '$day$year · ${_two(date.hour)}:${_two(date.minute)}';
}

String _monthLabel(DateTime date) {
  final month = _months[date.month - 1];
  return '${month[0].toUpperCase()}${month.substring(1)} ${date.year}';
}

String _group(num value) => _formatXof(value).replaceAll(' FCFA', '');

String _shortXof(num value, {bool plus = false}) {
  final sign = value < 0 ? '−' : (plus ? '+' : '');
  return '$sign${_group(value.abs())} F';
}

String _shortNetwork(String name) => name.startsWith('MTN')
    ? 'MTN'
    : name.startsWith('Moov')
        ? 'Moov'
        : name.startsWith('Celtiis')
            ? 'Celtiis'
            : 'réseau';

// ---------------------------------------------------------------------------
// Briques communes
// ---------------------------------------------------------------------------

class _FlowPage extends StatelessWidget {
  const _FlowPage({
    required this.children,
    this.title,
    this.subtitle,
    this.bottom,
    this.onBack,
    this.trailing,
    this.showBack = true,
  });
  final String? title, subtitle;
  final List<Widget> children;
  final Widget? bottom, trailing;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.white,
      child: SafeArea(
          child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: Column(children: [
                if (title != null)
                  _FlowHeader(
                      title: title!,
                      subtitle: subtitle,
                      onBack: onBack,
                      showBack: showBack,
                      trailing: trailing)
                else
                  const SizedBox(height: 12),
                Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: children))),
                if (bottom != null)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: bottom!),
              ]))));
}

class _FlowHeader extends StatelessWidget {
  const _FlowHeader(
      {required this.title,
      this.subtitle,
      this.onBack,
      this.trailing,
      this.showBack = true});
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(children: [
        Row(children: [
          SizedBox(
              width: 52,
              child: showBack
                  ? IconButton(
                      tooltip: 'Retour',
                      onPressed: onBack ?? () => Navigator.pop(context),
                      icon: const Icon(Icons.chevron_left,
                          color: _ink, size: 32))
                  : null),
          Expanded(
              child: Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _ink, fontSize: 17, fontWeight: FontWeight.w700))),
          SizedBox(width: 52, child: trailing),
        ]),
        if (subtitle != null)
          Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(subtitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted, fontSize: 13))),
      ]));
}

class _FlowButton extends StatelessWidget {
  const _FlowButton(
      {required this.label,
      required this.onPressed,
      this.busy = false,
      this.outlined = false,
      this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool busy, outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    final child = busy
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700));
    return SizedBox(
        width: double.infinity,
        height: 52,
        child: outlined
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon ?? Icons.history, size: 18),
                label: child,
                style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: primary),
                    shape: shape))
            : FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                    backgroundColor: primary, shape: shape),
                child: child));
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              color: muted, fontSize: 13, fontWeight: FontWeight.w600)));
}

class _Tappable extends StatelessWidget {
  const _Tappable(
      {required this.selected,
      required this.onTap,
      required this.child,
      this.radius = 10,
      this.padding = EdgeInsets.zero});
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Semantics(
      button: true,
      selected: selected,
      child: Material(
          color: selected ? tint : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(
                  color: selected ? primary : _border,
                  width: selected ? 1.5 : 1)),
          child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(radius),
              child: Padding(padding: padding, child: child))));
}

class _NetworkLogo extends StatelessWidget {
  const _NetworkLogo({required this.name, this.size = 42});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mtn = name.startsWith('MTN');
    final moov = name.startsWith('Moov');
    final celtiis = name.startsWith('Celtiis');
    final color = mtn
        ? const Color(0xFFFFD500)
        : moov
            ? const Color(0xFF1476D4)
            : celtiis
                ? const Color(0xFF19A45B)
                : const Color(0xFFDCE8FF);
    final label = mtn
        ? 'MTN'
        : moov
            ? 'M'
            : celtiis
                ? 'C'
                : '✣';
    final dark = mtn || !(moov || celtiis);
    return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(size * .26)),
        child: Text(label,
            style: TextStyle(
                color: dark ? primaryDark : Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: label.length > 1 ? size * .27 : size * .42)));
  }
}

class _NetworkOption extends StatelessWidget {
  const _NetworkOption(
      {required this.name, required this.selected, required this.onTap});
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Tappable(
      selected: selected,
      onTap: onTap,
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(children: [
        _NetworkLogo(name: name, size: 40),
        const SizedBox(width: 12),
        Expanded(
            child: Text(name,
                style: const TextStyle(
                    color: _ink, fontWeight: FontWeight.w600, fontSize: 14))),
        if (selected) const Icon(Icons.check_circle, color: primary, size: 20),
      ]));
}

class _AmountChips extends StatelessWidget {
  const _AmountChips(
      {required this.values, required this.current, required this.onPick});
  final List<int> values;
  final int? current;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: i == values.length - 1 ? 0 : 8),
                  child: _Tappable(
                      selected: current == values[i],
                      onTap: () => onPick(values[i]),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                          child: Text(_group(values[i]),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: current == values[i]
                                      ? primary
                                      : _ink)))))),
      ]);
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) => TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
          hintText: 'Autre montant', suffixText: 'FCFA'));
}

class _FeeBlock extends StatelessWidget {
  const _FeeBlock({required this.fee, required this.total});
  final num fee, total;
  @override
  Widget build(BuildContext context) => Column(children: [
        _SummaryLine(label: 'Frais', value: _formatXof(fee)),
        const Divider(height: 14, color: _border),
        _SummaryLine(label: 'Montant total', value: _formatXof(total), bold: true),
      ]);
}

class _ValueBox extends StatelessWidget {
  const _ValueBox(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(12)),
      child: Text(value,
          style: const TextStyle(
              color: _ink, fontSize: 16, fontWeight: FontWeight.w700)));
}

class _Segmented extends StatelessWidget {
  const _Segmented(
      {required this.items, required this.selected, required this.onChanged});
  final List<String> items;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: const Color(0xFFF1F4F2),
          borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        for (final item in items)
          Expanded(
              child: Semantics(
                  button: true,
                  selected: item == selected,
                  child: Material(
                      color: item == selected ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      child: InkWell(
                          onTap: () => onChanged(item),
                          borderRadius: BorderRadius.circular(9),
                          child: Container(
                              height: 42,
                              alignment: Alignment.center,
                              child: Text(item,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: item == selected
                                          ? Colors.white
                                          : muted))))))),
      ]));
}

// ---------------------------------------------------------------------------
// Écrans 3, 4, 5 : recharge
// ---------------------------------------------------------------------------

class RechargeSheet extends StatefulWidget {
  const RechargeSheet(
      {required this.api,
      required this.onComplete,
      required this.onHistory,
      this.phone = '',
      super.key});

  final DemoApi api;
  final Future<void> Function() onComplete;
  final VoidCallback onHistory;
  final String phone;

  @override
  State<RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<RechargeSheet> {
  final amountController = TextEditingController();
  var network = 'MTN Mobile Money';
  Map<String, dynamic>? quote;
  Map<String, dynamic>? result;
  String? error;
  var busy = false;

  static const _allNetworks = [
    'MTN Mobile Money',
    'Moov Money',
    'Celtiis Cash',
    'Autre réseau compatible'
  ];

  @override
  void initState() {
    super.initState();
    amountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  int? get amount =>
      int.tryParse(amountController.text.replaceAll(RegExp(r'\s'), ''));

  Future<void> getQuote() async {
    final value = amount;
    if (value == null || value < 100) {
      setState(() => error = 'Entre un montant d’au moins 100 FCFA.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final nextQuote = await widget.api.quote(network, value);
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
    final value = (quote?['amountXof'] as num?)?.toInt();
    if (value == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final created = await widget.api.recharge(network, value);
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
    if (result != null) return _success(context, result!);
    if (quote != null) return _confirmation(quote!);
    return _form();
  }

  // Écran 3
  Widget _form() => _FlowPage(
          title: 'Recharger',
          children: [
            for (final item in _allNetworks)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NetworkOption(
                      name: item,
                      selected: item == network,
                      onTap: () => setState(() => network = item))),
            const SizedBox(height: 10),
            _AmountChips(
                values: const [1000, 5000, 10000, 25000],
                current: amount,
                onPick: (value) => amountController.text = '$value'),
            const SizedBox(height: 12),
            _AmountInput(controller: amountController),
            if (error != null) ...[
              const SizedBox(height: 14),
              _ErrorBox(message: error!)
            ],
          ],
          bottom: _FlowButton(
              label: 'Continuer', busy: busy, onPressed: busy ? null : getQuote));

  // Écran 4
  Widget _confirmation(Map<String, dynamic> data) {
    final name = data['network']?.toString() ?? network;
    return _FlowPage(
        title: 'Vérifier et confirmer',
        onBack: busy ? () {} : () => setState(() => quote = null),
        children: [
          const SizedBox(height: 8),
          Center(child: _NetworkLogo(name: name, size: 84)),
          const SizedBox(height: 14),
          Center(
              child: Text('Recharge ${_shortNetwork(name)}',
                  style: const TextStyle(
                      color: _ink, fontSize: 18, fontWeight: FontWeight.w800))),
          const SizedBox(height: 24),
          const _FieldLabel('Montant'),
          _ValueBox(_formatXof(data['creditedXof'] as num)),
          const SizedBox(height: 14),
          _FeeBlock(fee: data['feeXof'] as num, total: data['totalXof'] as num),
          if (widget.phone.isNotEmpty) ...[
            const SizedBox(height: 6),
            _SummaryLine(label: 'Numéro', value: widget.phone),
          ],
          if (error != null) ...[
            const SizedBox(height: 14),
            _ErrorBox(message: error!)
          ],
        ],
        bottom: _FlowButton(
            label: 'Confirmer', busy: busy, onPressed: busy ? null : confirm));
  }

  // Écran 5
  Widget _success(BuildContext context, Map<String, dynamic> data) {
    final ok = data['status'] == 'succeeded';
    final color = ok ? primary : const Color(0xFFB23C32);
    final failure = data['failureReason']?.toString();
    return _FlowPage(
        children: [
          const SizedBox(height: 56),
          Center(
              child: Container(
                  width: 132,
                  height: 132,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ok ? tint : const Color(0xFFFFF1EE)),
                  child: Container(
                      width: 92,
                      height: 92,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: color),
                      child: Icon(ok ? Icons.check : Icons.close,
                          color: Colors.white, size: 54)))),
          const SizedBox(height: 28),
          Text(ok ? 'Recharge réussie' : 'Recharge échouée',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _ink, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
              '${ok ? '+ ' : ''}${_formatXof((data['amountXof'] as num?) ?? 0)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: color,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: 10),
          Text(_frenchDate(data['createdAt']),
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 14)),
          if (!ok && failure != null) ...[
            const SizedBox(height: 10),
            Text(failure,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 13)),
          ],
        ],
        bottom: Column(mainAxisSize: MainAxisSize.min, children: [
          _FlowButton(
              label: 'Voir dans l’historique',
              outlined: true,
              onPressed: () {
                Navigator.pop(context);
                widget.onHistory();
              }),
          const SizedBox(height: 10),
          _FlowButton(label: 'Terminer', onPressed: () => Navigator.pop(context)),
        ]));
  }
}

// ---------------------------------------------------------------------------
// Écrans 6 et 7 : transfert et retrait
// ---------------------------------------------------------------------------

enum _MoneyKind { transfer, withdraw }

class _MoneyFlowSheet extends StatefulWidget {
  const _MoneyFlowSheet(
      {required this.kind,
      this.favorites = const [],
      this.favorite,
      this.phone = ''});
  final _MoneyKind kind;
  final List<Map<String, String>> favorites;
  final Map<String, String>? favorite;
  final String phone;

  @override
  State<_MoneyFlowSheet> createState() => _MoneyFlowSheetState();
}

class _MoneyFlowSheetState extends State<_MoneyFlowSheet> {
  final amountController = TextEditingController();
  final phoneController = TextEditingController();
  var mode = 'Numéro';
  var network = _networks.first;
  var review = false;
  String? error;

  bool get isTransfer => widget.kind == _MoneyKind.transfer;

  int? get amount =>
      int.tryParse(amountController.text.replaceAll(RegExp(r'\s'), ''));

  @override
  void initState() {
    super.initState();
    phoneController.text =
        widget.favorite?['phone'] ?? (isTransfer ? '' : widget.phone);
    final favoriteNetwork = widget.favorite?['network'];
    if (favoriteNetwork != null && _networks.contains(favoriteNetwork)) {
      network = favoriteNetwork;
    }
    amountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    final digits = phoneController.text.replaceAll(RegExp(r'\D'), '');
    final value = amount;
    String? problem;
    if (digits.length < 8) {
      problem = 'Indique un numéro de téléphone valide.';
    } else if (value == null || value < 100) {
      problem = 'Entre un montant d’au moins 100 FCFA.';
    }
    setState(() {
      error = problem;
      review = problem == null;
    });
  }

  @override
  Widget build(BuildContext context) =>
      review ? _review(amount ?? 0) : _form(amount ?? 0);

  Widget _contactList() {
    if (widget.favorites.isEmpty) {
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text(
              'Aucun contact enregistré. Ajoute un bénéficiaire depuis « Mon argent » ou saisis un numéro.',
              style: TextStyle(color: muted, height: 1.5)));
    }
    return Column(children: [
      for (final item in widget.favorites)
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
                backgroundColor: tint,
                child: Text(_initials(item['name']!),
                    style: const TextStyle(
                        color: primary, fontWeight: FontWeight.w700))),
            title: Text(item['name']!),
            subtitle: Text(item['phone']!),
            onTap: () => setState(() {
                  phoneController.text = item['phone']!;
                  if (_networks.contains(item['network'])) {
                    network = item['network']!;
                  }
                  mode = 'Numéro';
                })),
    ]);
  }

  Widget _form(int value) {
    final contactMode = isTransfer && mode == 'Contact';
    return _FlowPage(
        title: isTransfer ? 'Nouveau transfert' : 'Retrait',
        subtitle: isTransfer ? null : 'Vers un compte Mobile Money',
        children: [
          if (isTransfer) ...[
            _Segmented(
                items: const ['Contact', 'Numéro'],
                selected: mode,
                onChanged: (item) => setState(() => mode = item)),
            const SizedBox(height: 18),
          ] else ...[
            for (final item in _networks)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _NetworkOption(
                      name: item,
                      selected: item == network,
                      onTap: () => setState(() => network = item))),
            const SizedBox(height: 8),
          ],
          if (contactMode)
            _contactList()
          else ...[
            const _FieldLabel('Numéro de téléphone'),
            TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    hintText: '+229 01 23 45 67 89',
                    prefixIcon: isTransfer
                        ? null
                        : const Icon(Icons.phone_outlined, color: muted),
                    suffixIcon: isTransfer
                        ? IconButton(
                            tooltip: 'Choisir un contact',
                            onPressed: () => setState(() => mode = 'Contact'),
                            icon: const Icon(Icons.person_outline,
                                color: primary))
                        : null)),
            const SizedBox(height: 18),
            const _FieldLabel('Montant'),
            _AmountChips(
                values: isTransfer
                    ? const [1000, 5000, 10000, 25000]
                    : const [5000, 10000, 25000],
                current: amount,
                onPick: (picked) => amountController.text = '$picked'),
            const SizedBox(height: 10),
            _AmountInput(controller: amountController),
            const SizedBox(height: 16),
            _FeeBlock(fee: 0, total: value),
            if (error != null) ...[
              const SizedBox(height: 14),
              _ErrorBox(message: error!)
            ],
          ],
        ],
        bottom: contactMode
            ? null
            : _FlowButton(label: 'Continuer', onPressed: _continue));
  }

  Widget _review(int value) => _FlowPage(
          title: 'Vérifier et confirmer',
          onBack: () => setState(() => review = false),
          children: [
            const SizedBox(height: 8),
            if (isTransfer)
              _SummaryLine(
                  label: 'Destinataire', value: phoneController.text.trim())
            else ...[
              _SummaryLine(label: 'Réseau', value: network),
              _SummaryLine(label: 'Numéro', value: phoneController.text.trim()),
            ],
            _SummaryLine(label: 'Montant', value: _formatXof(value)),
            const Divider(height: 22, color: _border),
            _FeeBlock(fee: 0, total: value),
            const SizedBox(height: 18),
            Text(
                isTransfer
                    ? 'Le transfert est présenté pour validation visuelle. Le service de transfert n’est pas encore activé.'
                    : 'Le retrait sera activé lorsque le service Mobile Money sera connecté.',
                style: const TextStyle(color: muted, height: 1.45)),
          ],
          bottom: const _FlowButton(label: 'Confirmer', onPressed: null));
}

// ---------------------------------------------------------------------------
// Écran 8 : historique
// ---------------------------------------------------------------------------

class _HistorySheet extends StatefulWidget {
  const _HistorySheet(
      {required this.transactions,
      required this.loading,
      required this.error,
      required this.onRefresh});
  final List<Map<String, dynamic>> transactions;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  var tab = 'Tous';
  var searching = false;
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    search.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  bool _matchesTab(Map<String, dynamic> item) {
    final type = (item['type'] ?? 'recharge').toString();
    if (tab == 'Recharges') return type == 'recharge';
    if (tab == 'Transferts') return type == 'transfer';
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final query = search.text.trim().toLowerCase();
    final items = widget.transactions
        .where((item) =>
            _matchesTab(item) &&
            (query.isEmpty ||
                '${item['network']} ${item['reference']}'
                    .toLowerCase()
                    .contains(query)))
        .toList();

    final rows = <Widget>[];
    String? lastMonth;
    for (final item in items) {
      final date = DateTime.tryParse('${item['createdAt']}')?.toLocal();
      final label = date == null ? '' : _monthLabel(date);
      if (label.isNotEmpty && label != lastMonth) {
        lastMonth = label;
        rows.add(Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: Text(label,
                style: const TextStyle(
                    color: muted, fontSize: 13, fontWeight: FontWeight.w700))));
      }
      rows.add(_HistoryRow(transaction: item));
    }

    return _FlowPage(
        title: 'Historique',
        trailing: IconButton(
            tooltip: searching ? 'Fermer la recherche' : 'Rechercher',
            onPressed: () => setState(() {
                  searching = !searching;
                  if (!searching) search.clear();
                }),
            icon: Icon(searching ? Icons.close : Icons.search,
                color: _ink, size: 24)),
        children: [
          if (searching) ...[
            TextField(
                controller: search,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Rechercher une opération',
                    prefixIcon: Icon(Icons.search, color: muted))),
            const SizedBox(height: 12),
          ],
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final item in const ['Tous', 'Recharges', 'Transferts'])
              _TabPill(
                  label: item,
                  selected: tab == item,
                  onTap: () => setState(() => tab = item)),
          ]),
          if (widget.loading)
            const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()))
          else if (widget.error != null) ...[
            const SizedBox(height: 16),
            _ErrorBox(message: widget.error!),
            TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  unawaited(widget.onRefresh());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'))
          ] else if (items.isEmpty)
            _EmptyState(
                icon: Icons.receipt_long_outlined,
                title: tab == 'Transferts'
                    ? 'Aucun transfert'
                    : 'Aucune opération',
                body: tab == 'Transferts'
                    ? 'Tes transferts apparaîtront ici.'
                    : 'Tes recharges et leurs statuts apparaîtront ici.')
          else
            ...rows,
        ]);
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
      button: true,
      selected: selected,
      child: Material(
          color: selected ? primary : Colors.white,
          shape: StadiumBorder(
              side: BorderSide(color: selected ? primary : _border)),
          child: InkWell(
              onTap: onTap,
              customBorder: const StadiumBorder(),
              child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                          widthFactor: 1,
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : muted))))))));
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.transaction});
  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final status = transaction['status']?.toString();
    final success = status == 'succeeded';
    final failed = status == 'failed';
    final network = transaction['network']?.toString() ?? '';
    final amount = (transaction['amountXof'] as num?) ?? 0;
    final color = failed
        ? const Color(0xFFB23C32)
        : success
            ? primary
            : muted;
    final statusLabel = success
        ? 'Réussie'
        : failed
            ? 'Échouée'
            : 'En attente';
    final date = _frenchDate(transaction['createdAt'], withYear: false);
    return InkWell(
        onTap: () => _sheet(
            context,
            _InformationSheet(
              title: 'Détail de la recharge',
              icon: Icons.receipt_long_outlined,
              body: '${_formatXof(amount)} · $statusLabel',
              detail:
                  '$network\nFrais : ${_formatXof((transaction['feeXof'] as num?) ?? 0)}\nRéférence : ${transaction['reference']}\n${_transactionDate(transaction['createdAt'])}${transaction['failureReason'] == null ? '' : '\n${transaction['failureReason']}'}',
            )),
        child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _border))),
            child: Row(children: [
              _NetworkLogo(name: network, size: 40),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Recharge ${_shortNetwork(network)}',
                        style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(success ? date : '$date · $statusLabel',
                        style: const TextStyle(color: muted, fontSize: 12)),
                  ])),
              const SizedBox(width: 8),
              Text(_shortXof(amount, plus: success),
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFeatures: const [FontFeature.tabularFigures()])),
            ])));
  }
}
