import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';

/// Form where the user picks a new password after clicking the
/// recovery link in their email. The Supabase recovery link points
/// at `<site>/auth/recover?...` and includes a one-time access
/// token; once the user lands here and submits a new password,
/// Supabase signs them in on this session and invalidates the old
/// password so they cannot sign in with it again.
///
/// We don't show a captcha on this page — by the time the user is
/// here they've already proved they control the email address
/// (they clicked the link we sent them), so adding a captcha would
/// only add friction.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  // Supabase rejects an already-used or expired recovery token by
  // redirecting the user to <redirectTo>?error=access_denied
  // &error_code=otp_expired. We catch that here so the user sees
  // a real "request a new link" message instead of being kicked
  // back to the login form by the router redirect.
  bool _recoveryLinkInvalid = false;
  String? _passwordError;
  String? _confirmError;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    // Read the error params Supabase appends to the redirect URL
    // when it rejects a recovery token. They're delivered as
    // ?error=access_denied&error_code=otp_expired in the path
    // before GoRouter strips the query (the fragment is then
    // rewritten with /auth/reset-password by the router).
    final uri = GoRouterState.of(context).uri;
    final errorCode = uri.queryParameters['error_code'];
    if (errorCode == 'otp_expired' || errorCode == 'access_denied') {
      _recoveryLinkInvalid = true;
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _passwordError = null;
      _confirmError = null;
      _generalError = null;
    });
  }

  String _getErrorMessage(String error, AppLocalizations l10n) {
    if (error.contains('Password should be at least')) {
      return l10n.errorPasswordTooShort;
    }
    if (error.contains('rate limit') || error.contains('too many')) {
      return l10n.errorTooManyRequests;
    }
    if (error.contains('Auth session missing')) {
      // The recovery link expired or was already used. The user
      // needs to request a fresh reset email.
      return l10n.errorRecoverySessionExpired;
    }
    return l10n.errorGeneric;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    _clearErrors();

    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) {
      setState(() => _passwordError = l10n.errorPasswordRequired);
      return;
    }
    if (password.length < 6) {
      setState(() => _passwordError = l10n.errorPasswordTooShort);
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _confirmError = l10n.errorPasswordRequired);
      return;
    }
    if (password != confirm) {
      setState(() => _confirmError = l10n.errorPasswordsDoNotMatch);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // updateUser(password: ...) writes the new password to
      // auth.users. Because we're currently in a recovery session
      // (the email link signed us in with a one-time access
      // token), Supabase also rotates the password and
      // invalidates the old one — the user can no longer sign in
      // with the previous password after this call succeeds.
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      if (!mounted) return;
      // Hand off to the success page. The user is now signed in
      // with the new password and can navigate to the calendar.
      context.go('/auth/reset-success');
    } catch (e) {
      if (!mounted) return;
      // If the recovery token expired or was already used, the
      // error will surface as AuthRetryableFetchException with
      // otp_expired in the message, or as AuthException with
      // "Auth session missing". Switch the page to the
      // "link expired" view so the user can request a new one
      // instead of seeing a generic error over an empty form.
      final msg = e.toString();
      if (msg.contains('otp_expired') ||
          msg.contains('Auth session missing')) {
        setState(() => _recoveryLinkInvalid = true);
        return;
      }
      setState(() {
        _generalError = _getErrorMessage(msg, l10n);
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
      appBar: AppBar(title: Text(l10n.resetPassword)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_recoveryLinkInvalid) ...[
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.errorRecoverySessionExpired,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/auth/recover'),
                    child: Text(l10n.backToLogin),
                  ),
                ),
              ] else ...[
              Text(
                l10n.resetPasswordInstructions,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                  errorText: _passwordError,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: l10n.confirmPassword,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                      () => _obscureConfirm = !_obscureConfirm,
                    ),
                  ),
                  errorText: _confirmError,
                ),
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
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
