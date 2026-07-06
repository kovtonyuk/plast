import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class SettingsState extends Equatable {
  final AppThemeMode themeMode;

  const SettingsState({
    this.themeMode = AppThemeMode.system,
  });

  SettingsState copyWith({AppThemeMode? themeMode}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [themeMode];
}

class SettingsCubit extends Cubit<SettingsState> {
  static const String _themeModeKey = 'app_theme_mode';

  SettingsCubit() : super(const SettingsState());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? 2;

    emit(SettingsState(
      themeMode: AppThemeMode.values[themeModeIndex],
    ));
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
    emit(state.copyWith(themeMode: themeMode));
  }

  ThemeMode get flutterThemeMode {
    switch (state.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
