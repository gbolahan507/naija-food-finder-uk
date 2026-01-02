import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import 'theme_provider.dart';

class ThemeToggleWidget extends ConsumerWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeController = ref.read(themeControllerProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: AppColors.primaryGreen,
        ),
        title: const Text(
          'Dark Mode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          isDark ? 'Enabled' : 'Disabled',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.lightText,
          ),
        ),
        trailing: Switch(
          value: isDark,
          onChanged: (value) {
            themeController.toggleTheme();
          },
        ),
      ),
    );
  }
}
