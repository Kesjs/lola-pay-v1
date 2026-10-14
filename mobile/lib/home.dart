part of 'main.dart';

const _border = Color(0xFFE2E8E4);
const _ink = Color(0xFF17201D);
const _networks = ['MTN Mobile Money', 'Moov Money', 'Celtiis Cash'];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.api});
  final DemoApi? api;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final api = widget.api ?? DemoApi();
  final controller = PageController(viewportFraction: .94);
  Map<String, dynamic>? wallet;
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, String>> favorites = [];
  String? error;
  bool loading = true;
  bool favoritesLoaded = false;
  bool balanceVisible = true;
  int activePage = 0;

  @override
  void initState() {
    super.initState();
    unawaited(refresh());
    unawaited(_loadFavorites());
  }

  @override
  void dispose() {
    controller.dispose();
    if (widget.api == null) api.client.close();
    super.dispose();
  }

  Future<void> refresh() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final values =
          await Future.wait<dynamic>([api.wallet(), api.transactions()]);
      if (!mounted) return;
      setState(() {
        wallet = values[0] as Map<String, dynamic>;
        transactions = values[1] as List<Map<String, dynamic>>;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error =
            'Impossible de charger ton compte. Vérifie ta connexion et réessaie.';
        loading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final storage = await SharedPreferences.getInstance();
      final saved = storage.getString('lola.favorites.v1');
      final items = saved == null
          ? <Map<String, String>>[]
          : (jsonDecode(saved) as List)
              .map((item) => Map<String, String>.from(item as Map))
              .toList();
      if (mounted) {
        setState(() {
          favorites = items;
          favoritesLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => favoritesLoaded = true);
      }
    }
  }

  Future<bool> _saveFavorites(List<Map<String, String>> items) async {
    try {
      final storage = await SharedPreferences.getInstance();
      final saved =
          await storage.setString('lola.favorites.v1', jsonEncode(items));
      if (!saved) throw StateError('save failed');
      if (mounted) {
        setState(() => favorites = items);
      }
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Le bénéficiaire n’a pas pu être enregistré. Réessaie.')),
        );
      }
      return false;
    }
  }

  void goTo(int page) {
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.jumpToPage(page);
    } else {
      controller.animateToPage(page,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic);
    }
  }

  void _recharge() =>
      _sheet(context, RechargeSheet(api: api, onComplete: refresh));

  void _send([Map<String, String>? favorite]) =>
      _sheet(context, _TransferFlowSheet(favorite: favorite));

  void _withdraw() => _sheet(context, const _WithdrawFlowSheet());

  void _history() => _sheet(
      context,
      _HistorySheet(
          transactions: transactions,
          loading: loading,
          error: error,
          onRefresh: refresh));

  void _profile() => _sheet(
      context,
      _InformationSheet(
        title: 'Mon compte',
        icon: Icons.person_outline,
        body: wallet?['user']?['phone']?.toString() ?? 'Compte non chargé',
        detail:
            'Compte de démonstration. Les opérations de cette version utilisent uniquement des fonds fictifs.',
      ));

  void _notifications() => _sheet(
      context,
      const _InformationSheet(
        title: 'Notifications',
        icon: Icons.notifications_none_outlined,
        body: 'Aucune notification pour le moment.',
        detail: 'Les informations importantes de ton compte apparaîtront ici.',
      ));

  void _more() => _sheet(
      context,
      _SheetLayout(title: 'Plus', children: [
        ListTile(
            leading: const Icon(Icons.person_outline, color: primary),
            title: const Text('Mon compte'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              _profile();
            }),
        ListTile(
            leading: const Icon(Icons.people_outline, color: primary),
            title: const Text('Bénéficiaires favoris'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              _allFavorites();
            }),
        ListTile(
            leading: const Icon(Icons.refresh, color: primary),
            title: const Text('Actualiser mon compte'),
            onTap: () {
              Navigator.pop(context);
              unawaited(refresh());
            }),
        const Divider(),
        const Text('Lola Pay · Version de démonstration',
            style: TextStyle(color: muted, height: 1.5)),
        const SizedBox(height: 6),
        const Text(
            'Aucun fonds réel. Les cartes, transferts, retraits et encaissements ne sont pas encore disponibles.',
            style: TextStyle(color: muted, height: 1.5)),
      ]));

  Future<void> _addFavorite() async {
    final item = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FavoriteForm(existing: favorites),
    );
    if (item != null && mounted) await _saveFavorites([...favorites, item]);
  }

  void _allFavorites() => _sheet(
      context,
      _SheetLayout(title: 'Bénéficiaires favoris', children: [
        if (favorites.isEmpty)
          const Text(
              'Ajoute un bénéficiaire pour retrouver facilement ses coordonnées.',
              style: TextStyle(color: muted, height: 1.5)),
        ...favorites.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                  backgroundColor: tint,
                  child: Text(_initials(item['name']!),
                      style: const TextStyle(
                          color: primary, fontWeight: FontWeight.w700))),
              title: Text(item['name']!),
              subtitle: Text('${item['phone']}\n${item['network']}'),
              isThreeLine: true,
              onTap: () {
                Navigator.pop(context);
                _send(item);
              },
              trailing: IconButton(
                  tooltip: 'Supprimer ${item['name']}',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final saved = await _saveFavorites(
                        favorites.where((other) => other != item).toList());
                    if (saved && mounted) {
                      Navigator.pop(context);
                      _allFavorites();
                    }
                  }),
            )),
        const SizedBox(height: 16),
        FilledButton.icon(
            onPressed: favoritesLoaded
                ? () {
                    Navigator.pop(context);
                    unawaited(_addFavorite());
                  }
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un bénéficiaire')),
      ]));

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark),
      child: Scaffold(
        body: Stack(children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 238 + MediaQuery.paddingOf(context).top,
              child: Container(
                  decoration: const BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(240, 28))))),
          SafeArea(
              bottom: false,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                    child: Row(children: [
                      IconButton(
                          tooltip: 'Mon compte',
                          onPressed: _profile,
                          icon: const Icon(Icons.account_circle_outlined,
                              color: Colors.white, size: 28)),
                      const Expanded(
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Lola Pay',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -.7)))),
                      IconButton(
                          tooltip: 'Notifications',
                          onPressed: _notifications,
                          icon: const Icon(Icons.notifications_none_outlined,
                              color: Colors.white, size: 28)),
                    ])),
                const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text('DÉMONSTRATION · AUCUN FONDS RÉEL',
                        style: TextStyle(
                            color: Color(0xFFDAEDE3),
                            fontSize: 10,
                            letterSpacing: .8,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    child: PageView(
                  key: const ValueKey('home-pages'),
                  controller: controller,
                  onPageChanged: (page) => setState(() => activePage = page),
                  children: [
                    _MoneyPage(
                      wallet: wallet,
                      transactions: transactions,
                      loading: loading,
                      error: error,
                      balanceVisible: balanceVisible,
                      onToggleBalance: () =>
                          setState(() => balanceVisible = !balanceVisible),
                      activePage: activePage,
                      onPage: goTo,
                      onRefresh: refresh,
                      onRecharge: _recharge,
                      onSend: _send,
                      onWithdraw: _withdraw,
                      onHistory: _history,
                      favorites: favorites,
                      favoritesLoaded: favoritesLoaded,
                      onAddFavorite: _addFavorite,
                      onAllFavorites: _allFavorites,
                      onFavorite: _send,
                    ),
                    _CardsPage(activePage: activePage, onPage: goTo),
                  ],
                )),
              ])),
        ]),
        bottomNavigationBar: _ActionBar(
            onSend: _send,
            onRecharge: _recharge,
            onHistory: _history,
            onMore: _more),
      ),
    );
  }
}

class _MoneyPage extends StatelessWidget {
  const _MoneyPage(
      {required this.wallet,
      required this.transactions,
      required this.loading,
      required this.error,
      required this.balanceVisible,
      required this.onToggleBalance,
      required this.activePage,
      required this.onPage,
      required this.onRefresh,
      required this.onRecharge,
      required this.onSend,
      required this.onWithdraw,
      required this.onHistory,
      required this.favorites,
      required this.favoritesLoaded,
      required this.onAddFavorite,
      required this.onAllFavorites,
      required this.onFavorite});
  final Map<String, dynamic>? wallet;
  final List<Map<String, dynamic>> transactions;
  final bool loading, balanceVisible, favoritesLoaded;
  final String? error;
  final int activePage;
  final ValueChanged<int> onPage;
  final Future<void> Function() onRefresh;
  final VoidCallback onToggleBalance,
      onRecharge,
      onSend,
      onWithdraw,
      onHistory,
      onAddFavorite,
      onAllFavorites;
  final List<Map<String, String>> favorites;
  final ValueChanged<Map<String, String>> onFavorite;

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
          child: _OverviewCard(
            badge: 'Solde Lola Pay',
            title: 'Mon argent',
            value: loading
                ? '—'
                : wallet == null
                    ? 'Indisponible'
                    : balanceVisible
                        ? _formatXof(wallet!['balanceXof'] as num)
                        : '•••••• FCFA',
            valueSemantics: !balanceVisible ? 'Solde masqué' : null,
            trailing: IconButton(
                key: const ValueKey('toggle-balance'),
                tooltip:
                    balanceVisible ? 'Masquer le solde' : 'Afficher le solde',
                onPressed: onToggleBalance,
                icon: Icon(
                    balanceVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: primary,
                    size: 27)),
            actions: [
              _CardAction(
                  icon: Icons.add_card_outlined,
                  label: 'Recharger',
                  onTap: onRecharge),
              _CardAction(
                  icon: Icons.send_outlined, label: 'Envoyer', onTap: onSend),
              _CardAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Retirer',
                  onTap: onWithdraw),
            ],
          ),
        ),
        _PageDots(activePage: activePage, onPage: onPage),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              key: const PageStorageKey('money-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 32),
              children: [
                if (error != null) ...[
                  _ErrorBox(message: error!),
                  Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                          onPressed: onRefresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'))),
                ],
                _SectionHeading(
                    title: 'Bénéficiaires favoris',
                    action: 'Voir tout',
                    onTap: onAllFavorites),
                if (favoritesLoaded && favorites.isEmpty)
                  const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                          'Retrouve ici les personnes à qui tu envoies de l’argent.',
                          style: TextStyle(
                              color: muted, fontSize: 13, height: 1.5))),
                SizedBox(
                    height: 110,
                    child:
                        ListView(scrollDirection: Axis.horizontal, children: [
                      ...favorites
                          .take(3)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) => _FavoriteAvatar(
                                name: entry.value['name']!,
                                index: entry.key,
                                onTap: () => onFavorite(entry.value),
                              )),
                      SizedBox(
                          width: 84,
                          child: Column(children: [
                            SizedBox(
                                width: 56,
                                height: 56,
                                child: OutlinedButton(
                                  key: const ValueKey('add-favorite'),
                                  onPressed:
                                      favoritesLoaded ? onAddFavorite : null,
                                  style: OutlinedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: EdgeInsets.zero,
                                      side: const BorderSide(
                                          color: primary, width: 1.5)),
                                  child: const Icon(Icons.add,
                                      color: primary, size: 25),
                                )),
                            const SizedBox(height: 10),
                            const Text('Nouveau',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: muted, fontSize: 13)),
                          ])),
                    ])),
                const Divider(height: 24, color: _border),
                _SectionHeading(
                    title: 'Dernières opérations',
                    action: 'Voir tout',
                    onTap: onHistory),
                if (loading)
                  const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()))
                else if (error != null && transactions.isEmpty)
                  const _EmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: 'Opérations indisponibles',
                      body: 'Actualise ton compte pour les retrouver.')
                else if (transactions.isEmpty)
                  const _EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Aucune opération',
                      body: 'Ta première recharge apparaîtra ici.')
                else
                  ...transactions
                      .take(3)
                      .map((item) => _TransactionRow(transaction: item)),
              ],
            ),
          ),
        ),
      ]);
}

class _CardsPage extends StatelessWidget {
  const _CardsPage({required this.activePage, required this.onPage});
  final int activePage;
  final ValueChanged<int> onPage;

  void _virtual(BuildContext context) => _sheet(
      context,
      const _InformationSheet(
        title: 'Carte virtuelle',
        icon: Icons.credit_card_outlined,
        body:
            'Tu n’as pas encore de carte virtuelle. La création de carte n’est pas encore disponible.',
        detail:
            'Prix cible provisoire : 500 FCFA. Le tarif et les conditions seront affichés avant toute commande.',
      ));

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 18, 10, 0),
          child: _OverviewCard(
            badge: 'À venir',
            title: 'Cartes & paiements',
            value: 'Carte virtuelle',
            subtitle: 'Aucune carte pour le moment',
            actions: [
              _CardAction(
                  icon: Icons.credit_card_outlined,
                  label: 'Voir la carte',
                  onTap: () => _virtual(context)),
              _CardAction(
                  icon: Icons.settings_outlined,
                  label: 'Gérer la carte',
                  onTap: () => _virtual(context)),
            ],
          ),
        ),
        _PageDots(activePage: activePage, onPage: onPage),
        Expanded(
          child: ListView(
            key: const PageStorageKey('cards-scroll'),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 32),
            children: [
              const _SectionHeading(title: 'Services cartes'),
              LayoutBuilder(builder: (context, constraints) {
                final tiles = [
                  _ServiceTile(
                      icon: Icons.credit_card_outlined,
                      title: 'Carte physique',
                      body: 'Commander et gérer ta carte.',
                      button: 'Commander',
                      onTap: () => _sheet(
                          context,
                          const _InformationSheet(
                            title: 'Carte physique',
                            icon: Icons.credit_card_outlined,
                            body:
                                'La commande de carte physique n’est pas encore disponible.',
                            detail:
                                'Tarifs cibles provisoires\nCarte : 5 000 FCFA\nLivraison : 1 000 FCFA\nTotal livré : 6 000 FCFA\n\nLe tarif définitif sera affiché avant confirmation.',
                          ))),
                  _ServiceTile(
                      icon: Icons.contactless_outlined,
                      title: 'Encaisser',
                      body: 'Compte marchand et téléphone NFC éligibles.',
                      button: 'En savoir plus',
                      onTap: () => _sheet(
                          context,
                          const _InformationSheet(
                            title: 'Encaisser',
                            icon: Icons.contactless_outlined,
                            body:
                                'Accepter un paiement par carte sans contact sur ton téléphone.',
                            detail:
                                'Ce service nécessite un compte marchand activé et un appareil NFC compatible. Il n’est pas encore disponible dans cette version.',
                          ))),
                ];
                if (MediaQuery.textScalerOf(context).scale(14) > 19 ||
                    constraints.maxWidth < 290) {
                  return Column(children: tiles);
                }
                return IntrinsicHeight(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Expanded(child: tiles[0]),
                      const SizedBox(width: 12),
                      Expanded(child: tiles[1])
                    ]));
              }),
              const SizedBox(height: 16),
              const Divider(color: _border),
              const _SectionHeading(title: 'Opérations par carte'),
              const _EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Aucun paiement par carte',
                  body:
                      'Tes opérations apparaîtront ici dès que ta carte sera disponible.'),
            ],
          ),
        ),
      ]);
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard(
      {required this.badge,
      required this.title,
      required this.value,
      required this.actions,
      this.subtitle,
      this.trailing,
      this.valueSemantics});
  final String badge, title, value;
  final String? subtitle, valueSemantics;
  final Widget? trailing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey('overview-$title'),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x14123D32),
                  offset: Offset(0, 10),
                  blurRadius: 24)
            ]),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: const BoxDecoration(
                      color: tint,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(10))),
                  child: Text(badge,
                      style: const TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)))),
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 9, 14, 22),
              child: Column(children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: primaryDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (trailing != null) const SizedBox(width: 40),
                  Expanded(
                      child: Semantics(
                          label: valueSemantics,
                          child: Text(value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: primaryDark,
                                  fontSize:
                                      value == 'Carte virtuelle' ? 25 : 29,
                                  fontWeight: FontWeight.w800,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ])))),
                  if (trailing != null) SizedBox(width: 40, child: trailing),
                ]),
                if (subtitle != null) ...[
                  const SizedBox(height: 7),
                  Text(subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted, fontSize: 13))
                ],
              ])),
          const Divider(height: 1, color: _border),
          IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0)
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: VerticalDivider(width: 1, color: _border)),
                  Expanded(child: actions[i]),
                ],
              ])),
        ]),
      );
}

class _CardAction extends StatelessWidget {
  const _CardAction(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: onTap,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: primary, size: 25),
                    const SizedBox(height: 7),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700))
                  ]))));
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.activePage, required this.onPage});
  final int activePage;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        for (var i = 0; i < 2; i++)
          Semantics(
              selected: activePage == i,
              button: true,
              label: i == 0
                  ? 'Afficher Mon argent'
                  : 'Afficher Cartes et paiements',
              child: InkWell(
                key: ValueKey('page-dot-$i'),
                borderRadius: BorderRadius.circular(24),
                onTap: () => onPage(i),
                child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                        child: AnimatedContainer(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            height: 7,
                            width: activePage == i ? 20 : 7,
                            decoration: BoxDecoration(
                                color: activePage == i
                                    ? primary
                                    : const Color(0xFFAAB7AF),
                                borderRadius: BorderRadius.circular(5))))),
              )),
      ]));
}

class _ActionBar extends StatelessWidget {
  const _ActionBar(
      {required this.onSend,
      required this.onRecharge,
      required this.onHistory,
      required this.onMore});
  final VoidCallback onSend, onRecharge, onHistory, onMore;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
                color: Color(0x10123D32), offset: Offset(0, -4), blurRadius: 18)
          ]),
      child: SafeArea(
          top: false,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    flex: 3,
                    child: _BarAction(
                        label: 'Envoyer',
                        icon: Icons.send_outlined,
                        onTap: onSend)),
                Expanded(
                    flex: 2,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Transform.translate(
                          offset: const Offset(0, -12),
                          child: SizedBox(
                              width: 62,
                              height: 62,
                              child: FloatingActionButton(
                                key: const ValueKey('bottom-recharge'),
                                heroTag: 'recharge',
                                tooltip: 'Recharger',
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const CircleBorder(
                                    side: BorderSide(
                                        color: Colors.white, width: 4)),
                                onPressed: onRecharge,
                                child: const Icon(Icons.add, size: 34),
                              ))),
                      const Text('Recharger',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primary)),
                    ])),
                Expanded(
                    flex: 2,
                    child: _BarAction(
                        label: 'Historique',
                        icon: Icons.history_outlined,
                        onTap: onHistory)),
                Expanded(
                    child: _BarAction(
                        label: 'Plus', icon: Icons.more_horiz, onTap: onMore)),
              ]))));
}

class _BarAction extends StatelessWidget {
  const _BarAction(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
      key: ValueKey('bottom-$label'),
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: primary, size: 25),
            const SizedBox(height: 9),
            Text(label, style: const TextStyle(fontSize: 11, color: muted))
          ])));
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action, this.onTap});
  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: _ink, fontSize: 16, fontWeight: FontWeight.w700))),
        if (action != null)
          TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.only(left: 8),
                  minimumSize: const Size(64, 48)),
              child: Text('$action ›',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13))),
      ]));
}

class _FavoriteAvatar extends StatelessWidget {
  const _FavoriteAvatar(
      {required this.name, required this.index, required this.onTap});
  final String name;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 84,
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(children: [
            CircleAvatar(
                radius: 28,
                backgroundColor: [
                  primary,
                  const Color(0xFF427963),
                  const Color(0xFF2B5A46)
                ][index % 3],
                child: Text(_initials(name),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700))),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: muted, fontSize: 13))),
          ])));
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile(
      {required this.icon,
      required this.title,
      required this.body,
      required this.button,
      required this.onTap});
  final IconData icon;
  final String title, body, button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.fromLTRB(12, 22, 12, 16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        Icon(icon, color: primary, size: 33),
        const SizedBox(height: 15),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: primaryDark, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 13, height: 1.4)),
        const SizedBox(height: 18),
        SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child: Text(button,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12)))),
      ]));
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});
  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final status = transaction['status']?.toString();
    final success = status == 'succeeded';
    final failed = status == 'failed';
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
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            leading: CircleAvatar(
                backgroundColor: tint,
                child: Icon(
                    failed
                        ? Icons.close
                        : success
                            ? Icons.south
                            : Icons.schedule,
                    color: color,
                    size: 23)),
            title: const Text('Recharge',
                style: TextStyle(
                    color: _ink, fontWeight: FontWeight.w700, fontSize: 14)),
            subtitle: Text('${transaction['network']}\n$statusLabel',
                style:
                    const TextStyle(color: muted, fontSize: 11, height: 1.5)),
            trailing: Text(
                '${success ? '+ ' : ''}${_formatXof((transaction['amountXof'] as num?) ?? 0)}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    fontFeatures: const [FontFeature.tabularFigures()])),
            onTap: () => _sheet(
                context,
                _InformationSheet(
                  title: 'Détail de la recharge',
                  icon: Icons.receipt_long_outlined,
                  body:
                      '${_formatXof((transaction['amountXof'] as num?) ?? 0)} · $statusLabel',
                  detail:
                      '${transaction['network']}\nFrais : ${_formatXof((transaction['feeXof'] as num?) ?? 0)}\nRéférence : ${transaction['reference']}\n${_transactionDate(transaction['createdAt'])}${transaction['failureReason'] == null ? '' : '\n${transaction['failureReason']}'}',
                )),
          ),
        ));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title, body;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Column(children: [
        Icon(icon, color: primary, size: 28),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: primaryDark, fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Text(body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 13, height: 1.5))
      ]));
}

class _SheetLayout extends StatelessWidget {
  const _SheetLayout({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
      child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height,
              maxHeight: MediaQuery.sizeOf(context).height),
          child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  22, 0, 22, 24 + MediaQuery.viewInsetsOf(context).bottom),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      IconButton(
                          tooltip: 'Fermer',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: _ink, size: 20)),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  color: primaryDark,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800))),
                      const SizedBox(width: 40)
                    ]),
                    const SizedBox(height: 18),
                    ...children,
                  ]))));
}

class _TransferFlowSheet extends StatefulWidget {
  const _TransferFlowSheet({this.favorite});
  final Map<String, String>? favorite;
  @override
  State<_TransferFlowSheet> createState() => _TransferFlowSheetState();
}

class _TransferFlowSheetState extends State<_TransferFlowSheet> {
  final amount = TextEditingController();
  final phone = TextEditingController();
  bool review = false;
  @override
  void initState() {
    super.initState();
    phone.text = widget.favorite?['phone'] ?? '';
  }

  @override
  void dispose() {
    amount.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _SheetLayout(
          title: review ? 'Vérifier le transfert' : 'Nouveau transfert',
          children: [
            _FlowProgress(current: review ? 2 : 1, total: 2),
            const SizedBox(height: 18),
            if (!review) ...[
              SegmentedButton<String>(segments: const [
                ButtonSegment(value: 'Contact', label: Text('Contact')),
                ButtonSegment(value: 'Numéro', label: Text('Numéro')),
              ], selected: const {
                'Numéro'
              }, onSelectionChanged: (_) {}),
              const SizedBox(height: 16),
              TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Numéro de téléphone',
                      hintText: '+229 01 23 45 67 89')),
              const SizedBox(height: 12),
              TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Montant', suffixText: 'FCFA')),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: () => setState(() => review = true),
                  child: const Text('Continuer')),
            ] else ...[
              const _FlowSummary(
                  label: 'Destinataire', value: '+229 01 23 45 67 89'),
              _FlowSummary(label: 'Montant', value: '10 000 FCFA'),
              const _FlowSummary(label: 'Frais', value: '0 FCFA'),
              const Divider(height: 28),
              FilledButton(onPressed: null, child: const Text('Confirmer')),
              const SizedBox(height: 12),
              const Text(
                  'Le transfert est présenté pour validation visuelle. Le service de transfert n’est pas encore activé.',
                  style: TextStyle(color: muted, height: 1.45)),
            ],
          ]);
}

class _WithdrawFlowSheet extends StatefulWidget {
  const _WithdrawFlowSheet();
  @override
  State<_WithdrawFlowSheet> createState() => _WithdrawFlowSheetState();
}

class _WithdrawFlowSheetState extends State<_WithdrawFlowSheet> {
  bool review = false;
  @override
  Widget build(BuildContext context) => _SheetLayout(
          title: review ? 'Vérifier le retrait' : 'Retrait',
          children: [
            _FlowProgress(current: review ? 2 : 1, total: 2),
            const SizedBox(height: 18),
            if (!review) ...[
              const _NetworkOption(
                  name: 'MTN Mobile Money', selected: true, onTap: _noop),
              const SizedBox(height: 8),
              const _NetworkOption(
                  name: 'Moov Money', selected: false, onTap: _noop),
              const SizedBox(height: 16),
              const TextField(
                  keyboardType: TextInputType.phone,
                  decoration:
                      InputDecoration(labelText: 'Numéro de téléphone')),
              const SizedBox(height: 12),
              const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Montant', suffixText: 'FCFA')),
              const SizedBox(height: 20),
              FilledButton(
                  onPressed: () => setState(() => review = true),
                  child: const Text('Continuer')),
            ] else ...[
              const _FlowSummary(label: 'Réseau', value: 'MTN Mobile Money'),
              const _FlowSummary(label: 'Montant', value: '5 000 FCFA'),
              const _FlowSummary(label: 'Frais', value: '0 FCFA'),
              const Divider(height: 28),
              const FilledButton(onPressed: null, child: Text('Confirmer')),
              const SizedBox(height: 12),
              const Text(
                  'Le retrait sera activé lorsque le service Mobile Money sera connecté.',
                  style: TextStyle(color: muted, height: 1.45)),
            ],
          ]);
}

void _noop() {}

class _FlowProgress extends StatelessWidget {
  const _FlowProgress({required this.current, required this.total});
  final int current, total;
  @override
  Widget build(BuildContext context) => Row(
      children: List.generate(
          total,
          (i) => Expanded(
              child: Container(
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                  height: 4,
                  decoration: BoxDecoration(
                      color: i < current ? primary : _border,
                      borderRadius: BorderRadius.circular(4))))));
}

class _FlowSummary extends StatelessWidget {
  const _FlowSummary({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: muted))),
        Text(value,
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w700))
      ]));
}

class _InformationSheet extends StatelessWidget {
  const _InformationSheet(
      {required this.title,
      required this.icon,
      required this.body,
      required this.detail});
  final String title, body, detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _SheetLayout(title: title, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
                radius: 28,
                backgroundColor: tint,
                child: Icon(icon, color: primary, size: 28))),
        const SizedBox(height: 18),
        Text(body,
            style: const TextStyle(
                color: _ink,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Text(detail, style: const TextStyle(color: muted, height: 1.6)),
        const SizedBox(height: 24),
        FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer')),
      ]);
}

class _HistorySheet extends StatelessWidget {
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
  Widget build(BuildContext context) =>
      _SheetLayout(title: 'Historique', children: [
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (error != null) ...[
          _ErrorBox(message: error!),
          TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                unawaited(onRefresh());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'))
        ] else if (transactions.isEmpty)
          const _EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aucune opération',
              body: 'Tes recharges et leurs statuts apparaîtront ici.')
        else
          ...transactions.map((item) => _TransactionRow(transaction: item)),
      ]);
}

class _FavoriteForm extends StatefulWidget {
  const _FavoriteForm({required this.existing});
  final List<Map<String, String>> existing;
  @override
  State<_FavoriteForm> createState() => _FavoriteFormState();
}

class _FavoriteFormState extends State<_FavoriteForm> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final phone = TextEditingController();
  String network = _networks.first;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  String get normalizedPhone => phone.text
      .replaceAll(RegExp(r'[\s\-()]'), '')
      .replaceFirst(RegExp(r'^(\+229|00229)'), '');

  @override
  Widget build(BuildContext context) =>
      _SheetLayout(title: 'Nouveau bénéficiaire', children: [
        const Text('Ses coordonnées sont enregistrées sur ce téléphone.',
            style: TextStyle(color: muted, height: 1.5)),
        const SizedBox(height: 18),
        Form(
            key: form,
            child: Column(children: [
              TextFormField(
                  key: const ValueKey('favorite-name'),
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 40,
                  decoration:
                      const InputDecoration(labelText: 'Nom du bénéficiaire'),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Indique son nom.'
                      : null),
              const SizedBox(height: 14),
              TextFormField(
                  key: const ValueKey('favorite-phone'),
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Numéro au Bénin', hintText: '01 23 45 67 89'),
                  validator: (_) {
                    if (!RegExp(r'^01\d{8}$').hasMatch(normalizedPhone)) {
                      return 'Indique les 10 chiffres, en commençant par 01.';
                    }
                    if (widget.existing.any((item) =>
                        item['phone'] == normalizedPhone &&
                        item['network'] == network)) {
                      return 'Ce bénéficiaire est déjà enregistré.';
                    }
                    return null;
                  }),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                  initialValue: network,
                  decoration: const InputDecoration(labelText: 'Réseau'),
                  items: _networks
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) => setState(() => network = value!)),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      key: const ValueKey('save-favorite'),
                      onPressed: () {
                        if (form.currentState!.validate()) {
                          Navigator.pop(context, <String, String>{
                            'name': name.text.trim(),
                            'phone': normalizedPhone,
                            'network': network
                          });
                        }
                      },
                      child: const Text('Enregistrer'))),
            ])),
      ]);
}

void _sheet(BuildContext context, Widget child) =>
    unawaited(showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        enableDrag: false,
        showDragHandle: false,
        constraints:
            BoxConstraints.tightFor(height: MediaQuery.sizeOf(context).height),
        shape: const RoundedRectangleBorder(),
        backgroundColor: Color(0xFFF7F8FA),
        builder: (_) => child));
String _initials(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .take(2)
    .map((word) => word.isEmpty ? '' : word.characters.first.toUpperCase())
    .join();
String _transactionDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
