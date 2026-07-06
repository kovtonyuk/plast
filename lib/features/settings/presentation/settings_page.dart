import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/calendar'),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Theme(
            data: Theme.of(context).copyWith(
              listTileTheme: const ListTileThemeData(
                shape: RoundedRectangleBorder(),
              ),
            ),
            child: ListView(
              children: [
                _SectionHeader(title: l10n.theme),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: Text(l10n.lightTheme),
                  trailing: state.themeMode == AppThemeMode.light
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => context.read<SettingsCubit>().setThemeMode(AppThemeMode.light),
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(l10n.darkTheme),
                  trailing: state.themeMode == AppThemeMode.dark
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => context.read<SettingsCubit>().setThemeMode(AppThemeMode.dark),
                ),
                ListTile(
                  leading: const Icon(Icons.settings_suggest),
                  title: Text(l10n.systemTheme),
                  trailing: state.themeMode == AppThemeMode.system
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => context.read<SettingsCubit>().setThemeMode(AppThemeMode.system),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  },
                ),
                if (_packageInfo != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(AppLocalizations.of(context)!.version,),
                    trailing: Text(
                      '${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
