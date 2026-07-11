import 'package:flutter/material.dart';
import '../providers/language_provider.dart';
import '../utils/app_constants.dart';

class LanguageToggleButton extends StatefulWidget {
  final Color? color;
  const LanguageToggleButton({super.key, this.color});

  @override
  State<LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<LanguageToggleButton> {
  static const _languages = [
    {'code': 'en', 'flag': '🇬🇧', 'label': 'EN'},
    {'code': 'lo', 'flag': '🇱🇦', 'label': 'ລາວ'},
  ];

  @override
  void initState() {
    super.initState();
    LanguageProvider.instance.addListener(_onLocaleChange);
  }

  @override
  void dispose() {
    LanguageProvider.instance.removeListener(_onLocaleChange);
    super.dispose();
  }

  void _onLocaleChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final current = LanguageProvider.instance.locale.languageCode;
    final textColor = widget.color ?? Colors.white;

    return PopupMenuButton<String>(
      onSelected: (code) {
        LanguageProvider.instance.setLocale(Locale(code));
      },
      color: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 40),
      itemBuilder: (context) => _languages.map((lang) {
        final isSelected = lang['code'] == current;
        return PopupMenuItem<String>(
          value: lang['code'],
          child: Row(
            children: [
              Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lang['label']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.check,
                size: 16,
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ],
          ),
        );
      }).toList(),
      child: SizedBox(
        width: 104,
        height: 40,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _languages.firstWhere((l) => l['code'] == current)['flag']!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                _languages.firstWhere((l) => l['code'] == current)['label']!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 16, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}
