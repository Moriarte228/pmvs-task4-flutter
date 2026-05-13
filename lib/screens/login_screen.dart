import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/platform_utils.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v, AppLocalizations l10n) {
    if (v == null || v.trim().isEmpty) return l10n.emailRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return l10n.emailInvalid;
    }
    return null;
  }

  String? _passwordValidator(String? v, AppLocalizations l10n) {
    if (v == null || v.isEmpty) return l10n.passwordRequired;
    if (v.length < 6) return l10n.passwordTooShort;
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().login(
          _emailController.text,
          _passwordController.text,
        );
    if (!mounted) return;
    if (ok) {
      NotificationService.instance.success(context, l10n.welcome);
      widget.onLoginSuccess?.call();
    } else {
      final err = context.read<AuthProvider>().error;
      NotificationService.instance
          .error(context, _errorText(err, l10n) ?? l10n.loginError);
    }
  }

  String? _errorText(AuthErrorType? type, AppLocalizations l10n) {
    switch (type) {
      case AuthErrorType.emailRequired:
        return l10n.emailRequired;
      case AuthErrorType.emailInvalid:
        return l10n.emailInvalid;
      case AuthErrorType.passwordRequired:
        return l10n.passwordRequired;
      case AuthErrorType.passwordTooShort:
        return l10n.passwordTooShort;
      case AuthErrorType.invalidCredentials:
      case AuthErrorType.unknown:
        return l10n.loginError;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    // Адаптивная ширина формы.
    final width = MediaQuery.sizeOf(context).width;
    final formWidth = width < 600
        ? width * 0.9
        : (width < 1200 ? 420.0 : 480.0);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SizedBox(
                  width: formWidth,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.local_library,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.appTitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.login,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                labelText: l10n.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => _emailValidator(v, l10n),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: l10n.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (v) => _passwordValidator(v, l10n),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.loginHint,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: auth.isLoading ? null : _submit,
                              icon: auth.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.login),
                              label: Text(l10n.loginButton),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (PlatformUtils.isDesktop || PlatformUtils.isWeb)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  PlatformUtils.isWeb
                                      ? 'Web'
                                      : 'Desktop',
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
