import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? language; // Optional for backward compatibility

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.language,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconColor.withValues(alpha: 0.18),
                iconColor.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 1),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 11),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15.5,
            color: AppColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [iconColor, iconColor.withValues(alpha: 0.5)],
            ),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowGreen,
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Optional: Add a localized version of SectionHeader if needed
class LocalizedSectionHeader extends StatelessWidget {
  final String titleKey;
  final IconData icon;
  final Color iconColor;
  final String language;
  final Map<String, Map<String, String>> translations;

  const LocalizedSectionHeader({
    super.key,
    required this.titleKey,
    required this.icon,
    required this.iconColor,
    required this.language,
    required this.translations,
  });

  String _getTranslatedTitle() {
    return translations[language]?[titleKey] ??
        translations['EN']?[titleKey] ??
        titleKey;
  }

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: _getTranslatedTitle(),
      icon: icon,
      iconColor: iconColor,
      language: language,
    );
  }
}
