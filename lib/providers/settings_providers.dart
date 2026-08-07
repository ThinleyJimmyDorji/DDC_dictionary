import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final double fontScale;

  const SettingsState({
    required this.themeMode,
    required this.fontScale,
  });

  static const initial =
      SettingsState(themeMode: ThemeMode.system, fontScale: 1.0);

  SettingsState copyWith({ThemeMode? themeMode, double? fontScale}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
      );
}

/// Small user preferences that should survive app restarts but don't
/// warrant a database round-trip: dark mode and the definition text scale
/// (useful for legibility of the stacked Tibetan script).
class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(SettingsState.initial) {
    _load();
  }

  static const _themeModeKey = 'settings.theme_mode';
  static const _fontScaleKey = 'settings.font_scale';

  static const double minFontScale = 0.85;
  static const double maxFontScale = 1.4;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey);
    final fontScale = prefs.getDouble(_fontScaleKey);

    state = SettingsState(
      themeMode: (themeIndex != null &&
              themeIndex >= 0 &&
              themeIndex < ThemeMode.values.length)
          ? ThemeMode.values[themeIndex]
          : ThemeMode.system,
      fontScale: fontScale ?? 1.0,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setFontScale(double scale) async {
    final clamped = scale.clamp(minFontScale, maxFontScale).toDouble();
    state = state.copyWith(fontScale: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, clamped);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});
