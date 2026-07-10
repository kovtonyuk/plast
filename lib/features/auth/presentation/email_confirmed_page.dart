import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';

/// Landing page shown after the user clicks the confirmation link in
/// their email. Supabase's email confirmation redirect points at
/// `<site>/auth/confirmed`, which routes here. We don't auto-sign the
/// user in — the email link only verifies the address; the user
/// explicitly logs in afterwards. (If Supabase is configured to issue
/// a session on confirmation, the auth state listener in main.dart
/// will pick that up and route them to /calendar instead.)
class EmailConfirmedPage extends StatelessWidget {
  const EmailConfirmedPage({super.key});

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
                Icons.mark_email_read,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.emailConfirmedTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.emailConfirmedMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth'),
                  child: Text(l10n.emailConfirmedCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
