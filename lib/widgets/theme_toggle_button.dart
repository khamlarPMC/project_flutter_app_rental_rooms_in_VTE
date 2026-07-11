import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../utils/app_constants.dart';

class ThemeToggleButton extends StatefulWidget {
  final Color? color;
  const ThemeToggleButton({super.key, this.color});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  static const _themes = [ThemeMode.light, ThemeMode.dark];

  @override
  void initState() {
    super.initState();
    ThemeProvider.instance.addListener(_onThemeChange);
  }

  @override
  void dispose() {
    ThemeProvider.instance.removeListener(_onThemeChange);
    super.dispose();
  }

  void _onThemeChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ThemeProvider.instance.themeMode;
    final buttonColor = widget.color ?? AppColors.primary;
    final isDark = currentMode == ThemeMode.dark;

    return PopupMenuButton<ThemeMode>(
      onSelected: ThemeProvider.instance.setThemeMode,
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      itemBuilder: (context) => _themes.map((mode) {
        final selected = mode == currentMode;
        return PopupMenuItem<ThemeMode>(
          value: mode,
          child: Row(
            children: [
              Icon(
                mode == ThemeMode.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mode == ThemeMode.dark ? 'Dark' : 'Light',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.check,
                size: 16,
                color: selected ? AppColors.primary : Colors.transparent,
              ),
            ],
          ),
        );
      }).toList(),
      child: SizedBox(
        width: 104,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isDark ? 'Dark' : 'Light',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
