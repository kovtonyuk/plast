import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/settings/bloc/settings_cubit.dart';
import 'l10n/app_localizations.dart';
import 'shared/services/event_change_notifier.dart';
import 'shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NotificationService is a no-op on web (flutter_local_notifications is
  // not supported on the web platform). On mobile/desktop we initialize it
  // and request permissions up front.
  if (!kIsWeb) {
    await NotificationService().initialize();
    await NotificationService().requestPermissions();
  }

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  _startEmailMirror();

  runApp(const PlastApp());
}

/// Mirror the verified email from Supabase Auth into the `profiles` table
/// whenever it changes. Supabase Auth sends the confirmation email itself
/// (via [updateUser]); this listener keeps the mirrored column in sync once
/// the user clicks the link — including when that happens in another tab
/// or device.
void _startEmailMirror() {
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event != AuthChangeEvent.userUpdated &&
        event != AuthChangeEvent.signedIn) {
      return;
    }
    final user = data.session?.user ?? Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final email = user.email;
    if (email == null || email.isEmpty) return;
    final verified = user.emailConfirmedAt != null ? 1 : 0;

    // Fire-and-forget: a sync failure should not surface to the user.
    () async {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'email': email, 'email_verified': verified})
            .eq('id', user.id);
      } catch (_) {
        // Best-effort mirror; will retry on the next auth event.
      }
    }();
  });
}

class PlastApp extends StatelessWidget {
  const PlastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EventChangeNotifier()),
        BlocProvider(create: (_) => SettingsCubit()..loadSettings()),
        BlocProvider(create: (_) => AuthBloc()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: context.read<SettingsCubit>().flutterThemeMode,
            locale: const Locale('uk', 'UA'),
            supportedLocales: const [
              Locale('uk', 'UA'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: createRouter(),
          );
        },
      ),
    );
  }
}
