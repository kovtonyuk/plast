import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

/// Landing page shown after the user submits the password-recovery
/// form. Tells them a reset link was sent and offers a button to
/// return to the login page. Mirrors the visual style of
/// [EmailVerificationPage] and [EmailConfirmedPage] for consistency
/// across the auth flow.
class PasswordResetEmailSentPage extends StatelessWidget {
  const PasswordResetEmailSentPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.passwordResetEmailSentTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.passwordResetEmailSentMessage(email),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth'),
                  child: Text(l10n.backToLogin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
