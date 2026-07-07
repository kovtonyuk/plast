import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/debouncer.dart';
import '../../../l10n/app_localizations.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  // Debouncer: prevents double-submits from a single user and absorbs a few
  // rapid taps that would otherwise count as separate hits on the auth
  // endpoint (Supabase rate limit is 30 signups/hour per IP).
  final _submitDebouncer = Debouncer(duration: const Duration(seconds: 2));
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Error states
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });
  }

  String _getErrorMessage(String error, AppLocalizations l10n) {
    // Supabase returns 429 (rate limited) with messages like
    // "Too Many Requests" or "rate limit exceeded" or HTTP code 429.
    if (error.contains('429') ||
        error.contains('Too Many Requests') ||
        error.contains('rate limit')) {
      return l10n.errorTooManyRequests;
    }
    if (error.contains('Invalid login credentials')) {
      return l10n.errorInvalidCredentials;
    }
    if (error.contains('Email not confirmed')) {
      return l10n.errorEmailNotConfirmed;
    }
    if (error.contains('User already registered')) {
      return l10n.errorUserAlreadyRegistered;
    }
    if (error.contains('Invalid email')) {
      return l10n.errorEmailInvalid;
    }
    if (error.contains('Password should be at least')) {
      return l10n.errorPasswordTooShort;
    }
    if (error.contains('Unable to validate email address')) {
      return l10n.errorEmailInvalid;
    }
    return l10n.errorGeneric;
  }

  Future<void> _submit() async {
    // Debounce: drop the request if a previous one is still in flight.
    // This is the main defense against 429 from Supabase auth endpoint.
    await _submitDebouncer.run(_performSubmit);
  }

  Future<void> _performSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    _clearErrors();

    if (!_isLogin) {
      // Registration validation
      if (_firstNameController.text.trim().isEmpty) {
        setState(() => _firstNameError = l10n.errorNameRequired);
      }
      if (_lastNameController.text.trim().isEmpty) {
        setState(() => _lastNameError = l10n.errorNameRequired);
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (_emailController.text.trim().isEmpty) {
        setState(() => _emailError = l10n.errorEmailRequired);
      } else if (!emailRegex.hasMatch(_emailController.text.trim())) {
        setState(() => _emailError = l10n.errorEmailInvalid);
      }

      if (_passwordController.text.isEmpty) {
        setState(() => _passwordError = l10n.errorPasswordRequired);
      } else if (_passwordController.text.length < 6) {
        setState(() => _passwordError = l10n.errorPasswordTooShort);
      }

      if (_firstNameError != null || _lastNameError != null ||
          _emailError != null || _passwordError != null) {
        return;
      }
    } else {
      // Login validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (_emailController.text.trim().isEmpty) {
        setState(() => _emailError = l10n.errorEmailRequired);
      } else if (!emailRegex.hasMatch(_emailController.text.trim())) {
        setState(() => _emailError = l10n.errorEmailInvalid);
      }

      if (_passwordController.text.isEmpty) {
        setState(() => _passwordError = l10n.errorPasswordRequired);
      }

      if (_emailError != null || _passwordError != null) {
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (response.user != null && mounted) {
          context.go('/calendar');
        }
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null) {
          await Supabase.instance.client.from('profiles').insert({
            'id': response.user!.id,
            'first_name': _firstNameController.text.trim(),
            'last_name': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'email_verified': 0,
            'phone': '',
            'location': '',
            'created_at': DateTime.now().toIso8601String(),
          });

          if (mounted) {
            context.go('/auth/verify-email?email=${Uri.encodeComponent(_emailController.text.trim())}');
          }
        }
      }
    } catch (e) {
      setState(() {
        _generalError = _getErrorMessage(e.toString(), l10n);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image(
                    image: AssetImage(AppConstants.logoAuthAssetPath),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.park,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                if (!_isLogin) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: l10n.firstName,
                            prefixIcon: const Icon(Icons.person_outline),
                            errorText: _firstNameError,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: l10n.lastName,
                            prefixIcon: const Icon(Icons.person),
                            errorText: _lastNameError,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email),
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    errorText: _passwordError,
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                if (_generalError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _generalError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isLogin ? l10n.loginButton : l10n.registerButton),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _clearErrors();
                    });
                  },
                  child: Text(_isLogin ? l10n.noAccount : l10n.haveAccount),
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.push('/auth/recover');
                    },
                    child: Text(l10n.forgotPassword),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
