import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/captcha/hcaptcha_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _emailController = TextEditingController();
  final _captchaKey = GlobalKey<HCaptchaWidgetState>();
  bool _isLoading = false;
  bool _emailSent = false;
  // Tracks whether the user has solved a fresh challenge since the
  // last reset. The submit button stays disabled until this is
  // true, otherwise the request goes to Supabase without a
  // captcha_token and Supabase Bot Protection rejects it.
  bool _captchaSolved = false;
  String? _emailError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _generalError = null;
    });
  }

  String _getErrorMessage(String error, AppLocalizations l10n) {
    if (error.contains('Invalid email')) {
      return l10n.errorEmailInvalid;
    }
    if (error.contains('Unable to validate email')) {
      return l10n.errorEmailInvalid;
    }
    if (error.contains('user not found') || error.contains('User not found')) {
      return l10n.errorUserNotFound;
    }
    return l10n.errorUnknown;
  }

  Future<void> _sendResetEmail() async {
    final l10n = AppLocalizations.of(context)!;
    _clearErrors();

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = l10n.errorEmailRequired);
      return;
    } else if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() => _emailError = l10n.errorEmailInvalid);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Capture the captcha token through the widget's
      // executeAndConsume(). It returns the cached token if the
      // user has already solved the challenge (the gate on the
      // submit button ensures this is the case), or waits for the
      // next onToken callback otherwise. The token is one-shot —
      // it cannot be reused for a second submit, which is why
      // _captchaKey.currentState?.reset() runs in the finally
      // block to force a fresh challenge on the next attempt.
      final captchaToken = AppConstants.hcaptchaEnabled
          ? await _captchaKey.currentState?.executeAndConsume()
          : null;
      final captchaToSend = (captchaToken != null && captchaToken.isNotEmpty)
          ? captchaToken
          : null;

      // Belt-and-suspenders: if captcha is enabled but the widget
      // produced no token, bail out before hitting Supabase with
      // a missing captcha_token. This would otherwise return
      // "no captcha_token found" and the user would be stuck.
      if (AppConstants.hcaptchaEnabled && captchaToSend == null) {
        if (!mounted) return;
        setState(() {
          _generalError = l10n.errorGeneric;
          _isLoading = false;
        });
        return;
      }

      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        // Tell Supabase to send the user to our reset-password
        // page after they click the link in the email. The
        // recovery link includes a one-time access token that
        // signs the user in on arrival, so we don't need to
        // prompt them to log in again on the reset form.
        redirectTo: '${Uri.base.origin}/auth/reset-password',
        captchaToken: captchaToSend,
      );
      if (!mounted) return;
      // Hand off to the dedicated "check your email" page so the
      // user can read the instructions on a single-purpose screen
      // and has a clear "back to login" button. The email is
      // passed as a query param so the page can echo it back
      // ("we sent it to ...").
      context.go(
        '/auth/recover-sent?email=${Uri.encodeComponent(_emailController.text.trim())}',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = _getErrorMessage(e.toString(), l10n);
        // A spent token must be replaced by a fresh challenge
        // before another submit can succeed.
        _captchaSolved = false;
      });
      _captchaKey.currentState?.reset();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _captchaSolved = false;
        });
      }
      // Defensive: clear widget state even on success, so the
      // next visit starts clean.
      _captchaKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resetPassword),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_emailSent) ...[
                const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.resetPasswordSent,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.checkEmail,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/auth'),
                    child: Text(l10n.back),
                  ),
                ),
              ] else ...[
                Text(
                  l10n.forgotPassword,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email),
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendResetEmail(),
                ),
                if (AppConstants.hcaptchaEnabled) ...[
                  const SizedBox(height: 20),
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
                ],
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
                    // When hCaptcha is enabled, the button stays
                    // disabled until the user solves the challenge.
                    // Without this guard, the user could submit
                    // before the token is produced and Supabase
                    // would respond with "no captcha_token found".
                    onPressed: (_isLoading ||
                            (AppConstants.hcaptchaEnabled &&
                                !_captchaSolved))
                        ? null
                        : _sendResetEmail,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
