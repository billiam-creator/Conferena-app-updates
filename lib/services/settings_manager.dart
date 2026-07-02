import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central store for all user preferences.
/// All reads/writes go through this class so there's one source of truth.
class SettingsManager {
  // ── Keys ────────────────────────────────────────────────────────────────
  static const _keySound       = 'pref_sound_enabled';
  static const _keyVibration   = 'pref_vibration_enabled';
  static const _keyTheme       = 'pref_theme_mode'; // light | dark | system
  static const _keyOnboarding  = 'pref_onboarding_seen';

  // ── Defaults ─────────────────────────────────────────────────────────────
  static const bool   _defaultSound      = true;
  static const bool   _defaultVibration  = true;
  static const String _defaultTheme      = 'system';

  // ── Sound ─────────────────────────────────────────────────────────────────
  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySound) ?? _defaultSound;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, value);
  }

  // ── Vibration ─────────────────────────────────────────────────────────────
  static Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibration) ?? _defaultVibration;
  }

  static Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibration, value);
  }

  // ── Theme ─────────────────────────────────────────────────────────────────
  /// Returns 'light', 'dark', or 'system'
  static Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyTheme) ?? _defaultTheme;
  }

  static Future<void> setThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, value);
  }

  /// Converts stored string to Flutter's ThemeMode enum
  static Future<ThemeMode> resolveThemeMode() async {
    final stored = await getThemeMode();
    switch (stored) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }

  // ── Onboarding ────────────────────────────────────────────────────────────
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, true);
  }

  // ── Load all at once (used on app start) ──────────────────────────────────
  static Future<AppSettings> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      soundEnabled:     prefs.getBool(_keySound)      ?? _defaultSound,
      vibrationEnabled: prefs.getBool(_keyVibration)  ?? _defaultVibration,
      themeString:      prefs.getString(_keyTheme)    ?? _defaultTheme,
    );
  }
}

/// Immutable snapshot of all user preferences — passed down the widget tree.
class AppSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String themeString; // 'light' | 'dark' | 'system'

  const AppSettings({
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.themeString,
  });

  ThemeMode get themeMode {
    switch (themeString) {
      case 'light':  return ThemeMode.light;
      case 'dark':   return ThemeMode.dark;
      default:       return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? themeString,
  }) {
    return AppSettings(
      soundEnabled:     soundEnabled     ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      themeString:      themeString      ?? this.themeString,
    );
  }
}

/// InheritedWidget so any screen can read settings without prop-drilling.
class AppSettingsProvider extends InheritedWidget {
  final AppSettings settings;
  final void Function(AppSettings) onChanged;

  const AppSettingsProvider({
    super.key,
    required this.settings,
    required this.onChanged,
    required super.child,
  });

  static AppSettingsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSettingsProvider>();
  }

  @override
  bool updateShouldNotify(AppSettingsProvider oldWidget) =>
      settings != oldWidget.settings;
}