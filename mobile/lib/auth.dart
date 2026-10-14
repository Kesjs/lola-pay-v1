part of 'main.dart';

// Connexion par numéro de téléphone + code OTP (un seul parcours).
//  - Numéro inconnu  : numéro -> OTP -> profil (nom + PIN) -> Mon argent
//  - Numéro connu    : numéro -> OTP -> Mon argent
//  - Retour dans l'app (session présente) : verrouillage par PIN -> Mon argent
//
// Deux implémentations :
//  - DemoAuthRepository     : sans serveur, code SMS fixe 123456
//  - SupabaseAuthRepository : Supabase Auth (activé si SUPABASE_URL et
//    SUPABASE_ANON_KEY sont fournis via --dart-define)

const _demoOtp = '123456';
const _pinMaxAttempts = 5;
const _otpResendSeconds = 60;
const _lockAfterBackground = Duration(seconds: 60);

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthSession {
  const AuthSession({required this.phone, this.firstName, this.lastName});
  final String phone;
  final String? firstName, lastName;
  bool get needsProfile => (firstName ?? '').trim().isEmpty;
}

/// +229 suivi de 10 chiffres commençant par 01. Retourne null si invalide.
String? _normalizeBeninPhone(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00229')) {
    digits = digits.substring(5);
  } else if (digits.startsWith('229') && digits.length == 13) {
    digits = digits.substring(3);
  }
  if (!RegExp(r'^01\d{8}$').hasMatch(digits)) return null;
  return '+229$digits';
}

String _localPhone(String e164) {
  final d = e164.replaceFirst('+229', '');
  if (d.length != 10) return d;
  return '${d.substring(0, 2)} ${d.substring(2, 4)} ${d.substring(4, 6)} ${d.substring(6, 8)} ${d.substring(8)}';
}

String _displayPhone(String e164) => '+229 ${_localPhone(e164)}';

abstract class AuthRepository {
  bool get isDemo => false;

  Future<AuthSession?> restore();
  Future<void> sendCode(String phone);
  Future<AuthSession> verifyCode(String phone, String code);
  Future<AuthSession> saveProfile(
      {required String firstName, required String lastName});
  Future<void> signOut();

  // --- Données locales à l'appareil (dernier numéro, PIN de verrouillage) ---
  // Démo : le PIN est stocké tel quel. En production, utiliser
  // flutter_secure_storage (et la biométrie) à la place de SharedPreferences.

  Future<String?> lastPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('lola.auth.lastPhone');
    } catch (_) {
      return null;
    }
  }

  Future<void> rememberPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lola.auth.lastPhone', phone);
    } catch (_) {}
  }

  Future<bool> hasPin(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('lola.pin.$phone') != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> setPin(String phone, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lola.pin.$phone', pin);
  }

  Future<bool> checkPin(String phone, String pin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('lola.pin.$phone') == pin;
    } catch (_) {
      return false;
    }
  }
}

class DemoAuthRepository extends AuthRepository {
  static const _sessionKey = 'lola.demo.session';
  static const _profilesKey = 'lola.demo.profiles';

  @override
  bool get isDemo => true;

  Map<String, dynamic> _readProfiles(SharedPreferences prefs) {
    final raw = prefs.getString(_profilesKey);
    if (raw == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  AuthSession _sessionFor(String phone, Map<String, dynamic> profiles) {
    final profile = profiles[phone];
    final map = profile is Map ? profile : const {};
    return AuthSession(
        phone: phone,
        firstName: map['firstName'] as String?,
        lastName: map['lastName'] as String?);
  }

  @override
  Future<AuthSession?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_sessionKey);
    if (phone == null) return null;
    return _sessionFor(phone, _readProfiles(prefs));
  }

  @override
  Future<void> sendCode(String phone) =>
      Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  Future<AuthSession> verifyCode(String phone, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (code != _demoOtp) {
      throw const AuthFailure(
          'Code incorrect. En démonstration, le code est 123456.');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, phone);
    return _sessionFor(phone, _readProfiles(prefs));
  }

  @override
  Future<AuthSession> saveProfile(
      {required String firstName, required String lastName}) async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_sessionKey);
    if (phone == null) {
      throw const AuthFailure('Session expirée. Reconnecte-toi.');
    }
    final profiles = _readProfiles(prefs);
    profiles[phone] = {'firstName': firstName, 'lastName': lastName};
    await prefs.setString(_profilesKey, jsonEncode(profiles));
    return _sessionFor(phone, profiles);
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}

class SupabaseAuthRepository extends AuthRepository {
  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  AuthSession? _fromUser(sb.User? user) {
    if (user == null) return null;
    final raw = user.phone ?? '';
    final phone = raw.startsWith('+') ? raw : '+$raw';
    final meta = user.userMetadata ?? const <String, dynamic>{};
    return AuthSession(
        phone: phone,
        firstName: meta['first_name'] as String?,
        lastName: meta['last_name'] as String?);
  }

  @override
  Future<AuthSession?> restore() async =>
      _fromUser(_client.auth.currentSession?.user);

  @override
  Future<void> sendCode(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } catch (_) {
      throw const AuthFailure(
          'Impossible d’envoyer le code. Réessaie dans un instant.');
    }
  }

  @override
  Future<AuthSession> verifyCode(String phone, String code) async {
    sb.AuthResponse response;
    try {
      response = await _client.auth
          .verifyOTP(phone: phone, token: code, type: sb.OtpType.sms);
    } catch (_) {
      throw const AuthFailure('Code incorrect ou expiré.');
    }
    final session = _fromUser(response.user);
    if (session == null) {
      throw const AuthFailure('Code incorrect ou expiré.');
    }
    return session;
  }

  @override
  Future<AuthSession> saveProfile(
      {required String firstName, required String lastName}) async {
    try {
      final response = await _client.auth.updateUser(sb.UserAttributes(
          data: {'first_name': firstName, 'last_name': lastName}));
      final session = _fromUser(response.user);
      if (session != null) return session;
    } catch (_) {}
    throw const AuthFailure(
        'Impossible d’enregistrer ton profil. Réessaie dans un instant.');
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}

// ---------------------------------------------------------------------------
// Orchestration
// ---------------------------------------------------------------------------

enum _AuthStage { loading, phone, otp, profile, locked, ready }

class AuthGate extends StatefulWidget {
  const AuthGate({required this.repo, required this.builder, super.key});
  final AuthRepository repo;
  final Widget Function(VoidCallback signOut) builder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  var stage = _AuthStage.loading;
  var phone = '';
  String? lastPhone;
  AuthSession? session;
  DateTime? pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = pausedAt;
      pausedAt = null;
      if (stage == _AuthStage.ready &&
          since != null &&
          DateTime.now().difference(since) > _lockAfterBackground) {
        setState(() => stage = _AuthStage.locked);
      }
    }
  }

  Future<void> _start() async {
    final remembered = await widget.repo.lastPhone();
    AuthSession? existing;
    try {
      existing = await widget.repo.restore();
    } catch (_) {}
    var pin = false;
    if (existing != null) pin = await widget.repo.hasPin(existing.phone);
    if (!mounted) return;
    setState(() {
      lastPhone = remembered;
      if (existing == null) {
        stage = _AuthStage.phone;
        return;
      }
      session = existing;
      phone = existing.phone;
      stage = (existing.needsProfile || !pin)
          ? _AuthStage.profile
          : _AuthStage.locked;
    });
  }

  Future<void> _sendCode(String value) async {
    await widget.repo.sendCode(value);
    if (!mounted) return;
    setState(() {
      phone = value;
      stage = _AuthStage.otp;
    });
  }

  Future<void> _verify(String code) async {
    final result = await widget.repo.verifyCode(phone, code);
    await widget.repo.rememberPhone(phone);
    final pin = await widget.repo.hasPin(phone);
    if (!mounted) return;
    setState(() {
      session = result;
      lastPhone = phone;
      stage = (result.needsProfile || !pin) ? _AuthStage.profile : _AuthStage.ready;
    });
  }

  Future<void> _saveProfile(String first, String last, String pin) async {
    var updated = session;
    if (updated == null || updated.firstName != first || updated.lastName != last) {
      updated = await widget.repo.saveProfile(firstName: first, lastName: last);
    }
    await widget.repo.setPin(phone, pin);
    if (!mounted) return;
    setState(() {
      session = updated;
      stage = _AuthStage.ready;
    });
  }

  Future<bool> _unlock(String pin) async {
    final ok = await widget.repo.checkPin(phone, pin);
    if (ok && mounted) setState(() => stage = _AuthStage.ready);
    return ok;
  }

  Future<void> _signOut() async {
    try {
      await widget.repo.signOut();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      session = null;
      stage = _AuthStage.phone;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (stage) {
      case _AuthStage.loading:
        child = const Material(
            key: ValueKey('auth-loading'),
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()));
      case _AuthStage.phone:
        child = _PhoneScreen(
            key: const ValueKey('auth-phone'),
            demo: widget.repo.isDemo,
            returningPhone: lastPhone,
            onSubmit: _sendCode);
      case _AuthStage.otp:
        child = _OtpScreen(
            key: const ValueKey('auth-otp'),
            demo: widget.repo.isDemo,
            phone: phone,
            onBack: () => setState(() => stage = _AuthStage.phone),
            onVerify: _verify,
            onResend: () => widget.repo.sendCode(phone));
      case _AuthStage.profile:
        child = _ProfileScreen(
            key: const ValueKey('auth-profile'),
            initialFirst: session?.firstName ?? '',
            initialLast: session?.lastName ?? '',
            onSubmit: _saveProfile);
      case _AuthStage.locked:
        child = _LockScreen(
            key: const ValueKey('auth-lock'),
            name: session?.firstName,
            onUnlock: _unlock,
            onSignOut: _signOut);
      case _AuthStage.ready:
        child = KeyedSubtree(
            key: const ValueKey('auth-ready'),
            child: widget.builder(_signOut));
    }
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200), child: child);
  }
}

// ---------------------------------------------------------------------------
// Écrans
// ---------------------------------------------------------------------------

class _DemoNote extends StatelessWidget {
  const _DemoNote(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: tint, borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, color: primary, size: 19),
        const SizedBox(width: 9),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: primaryDark, fontSize: 12.5, height: 1.4))),
      ]));
}

class _PhoneScreen extends StatefulWidget {
  const _PhoneScreen(
      {required this.demo,
      required this.returningPhone,
      required this.onSubmit,
      super.key});
  final bool demo;
  final String? returningPhone;
  final Future<void> Function(String phone) onSubmit;

  @override
  State<_PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<_PhoneScreen> {
  late final controller = TextEditingController(
      text: widget.returningPhone == null
          ? ''
          : _localPhone(widget.returningPhone!));
  String? error;
  var busy = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final phone = _normalizeBeninPhone(controller.text);
    if (phone == null) {
      setState(
          () => error = 'Indique les 10 chiffres, en commençant par 01.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onSubmit(phone);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        error = failure.message;
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final returning = widget.returningPhone != null;
    return _FlowPage(
        children: [
          const SizedBox(height: 28),
          const Text('lola pay.',
              style: TextStyle(
                  color: primary,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1)),
          const SizedBox(height: 36),
          Text(returning ? 'Bon retour' : 'Bienvenue sur Lola Pay',
              style: const TextStyle(
                  color: _ink, fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
              'Entre ton numéro pour continuer. Nous t’envoyons un code par SMS.',
              style: TextStyle(color: muted, fontSize: 15, height: 1.5)),
          const SizedBox(height: 28),
          const _FieldLabel('Numéro de téléphone'),
          TextField(
              key: const ValueKey('auth-phone-field'),
              controller: controller,
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => busy ? null : submit(),
              decoration: const InputDecoration(
                  prefixText: '+229  ',
                  prefixStyle:
                      TextStyle(color: _ink, fontWeight: FontWeight.w700),
                  hintText: '01 23 45 67 89')),
          if (error != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(message: error!)
          ],
          const SizedBox(height: 16),
          const Text(
              'En continuant, tu acceptes les conditions d’utilisation de Lola Pay.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.4)),
          if (widget.demo)
            const _DemoNote(
                'Mode démonstration : aucun SMS n’est envoyé, le code de vérification est 123456.'),
        ],
        bottom: _FlowButton(
            label: 'Continuer', busy: busy, onPressed: busy ? null : submit));
  }
}

class _OtpScreen extends StatefulWidget {
  const _OtpScreen(
      {required this.demo,
      required this.phone,
      required this.onBack,
      required this.onVerify,
      required this.onResend,
      super.key});
  final bool demo;
  final String phone;
  final VoidCallback onBack;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function() onResend;

  @override
  State<_OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<_OtpScreen> {
  final controller = TextEditingController();
  Timer? timer;
  var seconds = _otpResendSeconds;
  String? error;
  var busy = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    timer?.cancel();
    seconds = _otpResendSeconds;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => seconds = seconds > 0 ? seconds - 1 : 0);
      if (seconds == 0) t.cancel();
    });
  }

  Future<void> submit() async {
    final code = controller.text.trim();
    if (busy || code.length != 6) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onVerify(code);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      controller.clear();
      setState(() {
        error = failure.message;
        busy = false;
      });
    }
  }

  Future<void> resend() async {
    setState(() => error = null);
    try {
      await widget.onResend();
      if (mounted) _startTimer();
    } on AuthFailure catch (failure) {
      if (mounted) setState(() => error = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) => _FlowPage(
          title: 'Code de vérification',
          onBack: widget.onBack,
          children: [
            const SizedBox(height: 12),
            Text('Entre le code reçu par SMS au\n${_displayPhone(widget.phone)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 15, height: 1.5)),
            const SizedBox(height: 28),
            TextField(
                key: const ValueKey('auth-otp-field'),
                controller: controller,
                autofocus: true,
                enabled: !busy,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    color: _ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 12),
                onChanged: (value) {
                  setState(() {});
                  if (value.length == 6) submit();
                },
                decoration: const InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: TextStyle(color: Color(0xFFC3CEC8)))),
            if (error != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(message: error!)
            ],
            const SizedBox(height: 18),
            Center(
                child: TextButton(
                    onPressed: seconds == 0 && !busy ? resend : null,
                    child: Text(seconds == 0
                        ? 'Renvoyer le code'
                        : 'Renvoyer le code dans $seconds s'))),
            if (widget.demo)
              const _DemoNote('Mode démonstration : utilise le code 123456.'),
          ],
          bottom: _FlowButton(
              label: 'Vérifier',
              busy: busy,
              onPressed:
                  busy || controller.text.length != 6 ? null : submit));
}

class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen(
      {required this.initialFirst,
      required this.initialLast,
      required this.onSubmit,
      super.key});
  final String initialFirst, initialLast;
  final Future<void> Function(String first, String last, String pin) onSubmit;

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  late final first = TextEditingController(text: widget.initialFirst);
  late final last = TextEditingController(text: widget.initialLast);
  final pin = TextEditingController();
  late final isNew = widget.initialFirst.trim().isEmpty;
  var accepted = false;
  var showPin = false;
  var busy = false;
  String? error;

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    pin.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    String? problem;
    if (first.text.trim().isEmpty || last.text.trim().isEmpty) {
      problem = 'Indique ton prénom et ton nom.';
    } else if (!RegExp(r'^\d{4}$').hasMatch(pin.text)) {
      problem = 'Choisis un code PIN de 4 chiffres.';
    } else if (isNew && !accepted) {
      problem = 'Accepte les conditions d’utilisation pour continuer.';
    }
    if (problem != null) {
      setState(() => error = problem);
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.onSubmit(first.text.trim(), last.text.trim(), pin.text);
    } on AuthFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        error = failure.message;
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => _FlowPage(
          title: isNew ? 'Crée ton profil' : 'Sécurise ton compte',
          showBack: false,
          children: [
            const SizedBox(height: 8),
            Text(
                isNew
                    ? 'Dis-nous comment t’appeler et choisis un code PIN pour protéger ton compte.'
                    : 'Choisis un code PIN pour protéger ton compte sur ce téléphone.',
                style: const TextStyle(color: muted, fontSize: 15, height: 1.5)),
            const SizedBox(height: 22),
            const _FieldLabel('Prénom'),
            TextField(
                key: const ValueKey('auth-first-name'),
                controller: first,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Jean')),
            const SizedBox(height: 14),
            const _FieldLabel('Nom'),
            TextField(
                key: const ValueKey('auth-last-name'),
                controller: last,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Dupont')),
            const SizedBox(height: 14),
            const _FieldLabel('Code PIN (4 chiffres)'),
            TextField(
                key: const ValueKey('auth-create-pin'),
                controller: pin,
                obscureText: !showPin,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    suffixIcon: IconButton(
                        tooltip: showPin ? 'Masquer le code' : 'Afficher le code',
                        onPressed: () => setState(() => showPin = !showPin),
                        icon: Icon(
                            showPin
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: muted)))),
            if (isNew) ...[
              const SizedBox(height: 8),
              Row(children: [
                Checkbox(
                    key: const ValueKey('auth-terms'),
                    value: accepted,
                    activeColor: primary,
                    onChanged: (value) =>
                        setState(() => accepted = value ?? false)),
                const Expanded(
                    child: Text('J’accepte les conditions d’utilisation',
                        style: TextStyle(color: _ink, fontSize: 14))),
              ]),
            ],
            if (error != null) ...[
              const SizedBox(height: 12),
              _ErrorBox(message: error!)
            ],
          ],
          bottom: _FlowButton(
              label: isNew ? 'Créer mon compte' : 'Continuer',
              busy: busy,
              onPressed: busy ? null : submit));
}

class _LockScreen extends StatefulWidget {
  const _LockScreen(
      {required this.name,
      required this.onUnlock,
      required this.onSignOut,
      super.key});
  final String? name;
  final Future<bool> Function(String pin) onUnlock;
  final Future<void> Function() onSignOut;

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  final controller = TextEditingController();
  var attempts = 0;
  var busy = false;
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> check(String pin) async {
    if (busy) return;
    setState(() => busy = true);
    final ok = await widget.onUnlock(pin);
    if (ok || !mounted) return;
    attempts++;
    controller.clear();
    if (attempts >= _pinMaxAttempts) {
      await widget.onSignOut();
      return;
    }
    final left = _pinMaxAttempts - attempts;
    setState(() {
      busy = false;
      error =
          'Code PIN incorrect. Il te reste $left essai${left > 1 ? 's' : ''}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.name?.trim();
    return _FlowPage(
        children: [
          const SizedBox(height: 56),
          const Center(
              child: CircleAvatar(
                  radius: 32,
                  backgroundColor: tint,
                  child: Icon(Icons.lock_outline, color: primary, size: 30))),
          const SizedBox(height: 20),
          Text(
              name == null || name.isEmpty ? 'Bon retour' : 'Bon retour, $name',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _ink, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Entre ton code PIN pour accéder à ton compte.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 15, height: 1.5)),
          const SizedBox(height: 28),
          TextField(
              key: const ValueKey('auth-pin-field'),
              controller: controller,
              autofocus: true,
              enabled: !busy,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                  color: _ink,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 14),
              onChanged: (value) {
                if (value.length == 4) check(value);
              },
              decoration: const InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(color: Color(0xFFC3CEC8)))),
          if (error != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(message: error!)
          ],
        ],
        bottom: TextButton(
            onPressed: busy ? null : () => unawaited(widget.onSignOut()),
            child: const Text('Utiliser un autre numéro')));
  }
}
