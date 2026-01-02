import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'theme_mode';

/// Provider for theme mode with persistence
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Default to system theme
  return ThemeMode.system;
});

/// Theme controller for managing theme mode
class ThemeController {
  final Ref ref;

  ThemeController(this.ref) {
    loadThemeMode();
  }

  /// Load theme mode from shared preferences
  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);

      if (themeModeString != null) {
        final mode = ThemeMode.values.firstWhere(
          (m) => m.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
        ref.read(themeModeProvider.notifier).state = mode;
      }
    } catch (e) {
      // Silently fail and use default
    }
  }

  /// Set theme mode and persist to shared preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    ref.read(themeModeProvider.notifier).state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
    } catch (e) {
      // Silently fail
    }
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final currentMode = ref.read(themeModeProvider);
    final newMode =
        currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Check if dark mode is active
  bool get isDarkMode => ref.read(themeModeProvider) == ThemeMode.dark;
}

/// Provider for theme controller
final themeControllerProvider = Provider<ThemeController>((ref) {
  return ThemeController(ref);
});
