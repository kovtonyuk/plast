import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/captcha/hcaptcha_widget.dart';
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
  final _captchaKey = GlobalKey<HCaptchaWidgetState>();
  // Debouncer: prevents double-submits from a single user and absorbs a few
  // rapid taps that would otherwise count as separate hits on the auth
  // endpoint (Supabase rate limit is 30 signups/hour per IP).
  final _submitDebouncer = Debouncer(duration: const Duration(seconds: 2));
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  // `true` between the user solving the captcha and the next reset
  // call. Submit is enabled only while this is true. We don't store
  // the token here — the widget owns it and hands it out exactly once
  // via `consumeToken`. Storing the token at the page level caused
  // "already-seen-response" errors from hCaptcha because the same
  // value could end up being submitted twice.
  bool _captchaSolved = false;

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
    // "Too Many Requests", "rate limit exceeded", or "email rate limit
    // exceeded" (the latter appears in the dev console when the anon
    // key has been scraped by bots — see migrations/README_RATE_LIMIT.md).
    // Match on the bare phrase so we catch all of them.
    if (error.contains('429') ||
        error.contains('Too Many Requests') ||
        error.contains('rate limit') ||
        error.contains('rate_limit') ||
        error.contains('too many')) {
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
    // Captcha rejection by Supabase (expired, missing, or wrong token).
    // The widget has already been reset, so the user can solve a fresh
    // challenge and retry.
    if (error.contains('captcha') || error.contains('Captcha')) {
      return l10n.errorGeneric;
    }
    return l10n.errorGeneric;
  }

  Future<void> _submit() async {
    // Drop double-taps: the submit button is disabled while loading,
    // but `onSubmitted` on the password field fires regardless of
    // that — a user pressing Enter twice in a row would otherwise
    // fire two signUp calls and create a duplicate account (or hit
    // Supabase's "user already registered" path).
    if (_isLoading) return;
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
      // Belt-and-suspenders: even though the submit button is disabled
      // until captcha is solved, double-check here. We call
      // `executeAndConsume()` which forces hCaptcha to issue a fresh
      // token via `hcaptcha.execute()` and waits for the new token
      // before returning. This is the only reliable way to avoid
      // hCaptcha's "already-seen-response" rejection — using the
      // cached token from the widget can resend a value that hCaptcha
      // has already invalidated.
      final captchaToken = AppConstants.hcaptchaEnabled
          ? await _captchaKey.currentState?.executeAndConsume()
          : null;
      final captchaToSend = (captchaToken != null && captchaToken.isNotEmpty)
          ? captchaToken
          : null;

      // If captcha is enabled but the widget had no token (e.g. user
      // raced past the disabled button via keyboard), bail out before
      // hitting Supabase with a missing captcha_token.
      if (AppConstants.hcaptchaEnabled && captchaToSend == null) {
        setState(() {
          _generalError = l10n.errorGeneric;
          _isLoading = false;
        });
        return;
      }

      if (_isLogin) {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          captchaToken: captchaToSend,
        );
        if (response.user != null && mounted) {
          context.go('/calendar');
        }
      } else {
        // Pre-check: look up the email in the `profiles` table
        // (populated at signup, mirrored from auth.users via the
        // listener in main.dart). This is a reliable way to detect
        // duplicates without burning a captcha token on a signIn
        // attempt that Supabase Bot Protection would reject.
        //
        // The RLS policy on `profiles` allows anon SELECT (we
        // explicitly grant it so the registration form can show
        // "email already in use" without forcing a sign-in first).
        // If your RLS is stricter, the query returns 0 rows and we
        // fall through to signUp — which is also fine, because
        // Supabase's own duplicate check (when "Enable strict
        // email validation" is on) will catch the case.
        try {
          final existing = await Supabase.instance.client
              .from('profiles')
              .select('id')
              .eq('email', _emailController.text.trim())
              .maybeSingle();
          if (existing != null) {
            if (!mounted) return;
            setState(() {
              _generalError = l10n.errorUserAlreadyRegistered;
              _isLoading = false;
            });
            return;
          }
        } catch (_) {
          // Best-effort: if the lookup fails (RLS denial, network
          // blip), don't block signup. Supabase's own checks are
          // the source of truth.
        }

        AuthResponse? response;
        try {
          // The `emailRedirectTo` parameter tells Supabase where to
          // send the user after they click the confirmation link in
          // the email. On web the link points to a URL on our domain
          // (`<site>/auth/confirmed`), which the router maps to
          // [EmailConfirmedPage]. On mobile the same path is opened
          // in the WebView. The exact value is the same on every
          // platform — Supabase picks the right protocol based on
          // the request origin.
          response = await Supabase.instance.client.auth.signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            captchaToken: captchaToSend,
            emailRedirectTo: '${Uri.base.origin}/auth/confirmed',
          );
        } on AuthException catch (e) {
          // Supabase returns 422 "user already registered" when
          // "Enable strict email validation" is on in the dashboard.
          // Surface a clean error and bail out before we try to
          // navigate anywhere — the user is still on the register
          // form, so we don't want to push them to verify-email.
          //
          // The auth.users trigger installed in
          // migrations/015_prevent_duplicate_auth_users.sql
          // blocks duplicates at the database level. Supabase
          // does not propagate the trigger's exception text to
          // the client — it returns a generic "Database error
          // saving new user" instead. Treat that message as a
          // duplicate-account signal so the user still sees the
          // friendly "email already in use" error.
          if (e.message.contains('already registered') ||
              e.message.contains('User already registered') ||
              e.statusCode == '422' ||
              e.message.contains('Database error saving new user')) {
            if (!mounted) return;
            setState(() {
              _generalError = l10n.errorUserAlreadyRegistered;
              _isLoading = false;
            });
            return;
          }
          rethrow;
        }

        if (!mounted) return;
        debugPrint(
          'signUp response: user=${response.user?.id}, session=${response.session?.accessToken != null}',
        );
        if (response.user == null) {
          setState(() {
            _generalError = l10n.errorGeneric;
            _isLoading = false;
          });
          return;
        }

        // Fire-and-forget profile insert — see _createProfileSafely
        // docstring for why we don't block the navigation on it.
        unawaited(_createProfileSafely(
          userId: response.user!.id,
          email: _emailController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        ));

        // Navigate immediately. The profile upsert is fire-and-forget.
        context.go('/auth/verify-email?email=${Uri.encodeComponent(_emailController.text.trim())}');
        return;
      }
    } catch (e, st) {
      debugPrint('Auth error: $e');
      debugPrint('Stack: $st');
      setState(() {
        _generalError = _getErrorMessage(e.toString(), l10n);
        // Force the user to solve a fresh captcha after any failure —
        // a submitted token is consumed and can't be reused.
        _captchaSolved = false;
      });
      // Reset() drops the cached token in the widget and asks hCaptcha
      // for a fresh challenge. Without this the next submit would
      // either have no token (button stays disabled, no path forward)
      // or reuse a spent token (hCaptcha's "already-seen-response").
      _captchaKey.currentState?.reset();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Same logic on the success path: the token was just spent,
          // so the captcha must be re-solved before another submit.
          _captchaSolved = false;
        });
      }
      // Defensive: ensure the widget's internal state is also cleared
      // even on success, so re-opening the page is clean.
      _captchaKey.currentState?.reset();
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
                const SizedBox(height: 20),
                if (AppConstants.hcaptchaEnabled)
                  Center(
                    child: HCaptchaWidget(
                      key: _captchaKey,
                      siteKey: AppConstants.hcaptchaSiteKey,
                      onToken: (_) {
                        if (mounted) {
                          setState(() => _captchaSolved = true);
                        }
                      },
                      onError: (err) {
                        debugPrint('hCaptcha error: $err');
                        if (!mounted) return;
                        setState(() {
                          _captchaSolved = false;
                          _generalError = l10n.errorGeneric;
                        });
                      },
                    ),
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
                    // When hCaptcha is enabled, the button stays disabled
                    // until the user solves the challenge. Without this
                    // guard, the user could submit before the token is
                    // produced and Supabase would respond with
                    // "no captcha_token found".
                    onPressed: (_isLoading ||
                            (AppConstants.hcaptchaEnabled &&
                                !_captchaSolved))
                        ? null
                        : _submit,
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
                      _captchaSolved = false;
                      // Force a fresh captcha challenge when switching
                      // between login and register modes (no-op when
                      // captcha is disabled — the key is not mounted).
                      _captchaKey.currentState?.reset();
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

  /// Insert the new user's profile row, but with a hard 5s timeout.
  /// If the call hangs (Supabase upstream timeout, RLS policy holding
  /// the row, etc.) we drop it and log — the user has already been
  /// created in `auth.users` and the email-mirror listener in main.dart
  /// will keep the profile in sync on later auth events. The signup
  /// flow must never be blocked on this side-effect.
  Future<void> _createProfileSafely({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await Supabase.instance.client
          .from('profiles')
          .upsert({
            'id': userId,
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'email_verified': 0,
            'phone': '',
            'location': '',
            'created_at': DateTime.now().toIso8601String(),
          })
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Profile upsert failed (non-fatal): $e');
      // Best-effort — will be retried on next auth state change.
    }
  }
}
