import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_theme.dart';
import '../theme_provider.dart';
import '../../../features/monetization/providers/premium_provider.dart';
import '../../../features/monetization/screens/premium_paywall_sheet.dart';
import '../../localization/app_strings.dart';

/// Kullanıcının tema modu ve 4 lüks renk paletini seçtiği modern alt sayfa.
class ThemeSelectionSheet extends ConsumerWidget {
  const ThemeSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ThemeSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark
        ? themeState.palette.darkSurface
        : Colors.white;

    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Çekme çubuğu
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Başlık
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeState.palette.accentGold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: themeState.palette.accentGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.appearanceAndTheme,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      strings.appearanceDesc,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  ref.watch(premiumProvider).isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.workspace_premium_outlined,
                  color: themeState.palette.accentGold,
                  size: 26,
                ),
                tooltip: 'Beyân Premium',
                onPressed: () => PremiumPaywallSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bölüm 1: Karanlık Mod Seçici
          Text(
            strings.appearanceModeSection,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: themeState.palette.accentGold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildModeOption(
                context: context,
                title: strings.modeLight,
                icon: Icons.wb_sunny_rounded,
                selected: themeState.mode == ThemeMode.light,
                onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                isDark: isDark,
                accentColor: themeState.palette.accentGold,
              ),
              const SizedBox(width: 8),
              _buildModeOption(
                context: context,
                title: strings.modeDark,
                icon: Icons.nightlight_round,
                selected: themeState.mode == ThemeMode.dark,
                onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                isDark: isDark,
                accentColor: themeState.palette.accentGold,
              ),
              const SizedBox(width: 8),
              _buildModeOption(
                context: context,
                title: strings.modeSystem,
                icon: Icons.settings_suggest_rounded,
                selected: themeState.mode == ThemeMode.system,
                onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                isDark: isDark,
                accentColor: themeState.palette.accentGold,
              ),
            ],
          ),
          const SizedBox(height: 26),

          // Bölüm 2: Lüks Renk Paletleri
          Text(
            strings.colorPaletteSection,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: themeState.palette.accentGold,
            ),
          ),
          const SizedBox(height: 12),

          ...AppThemePalette.values.map((palette) {
            final isSelected = themeState.palette == palette;
            return _buildPaletteTile(
              context: context,
              palette: palette,
              isSelected: isSelected,
              onTap: () => themeNotifier.setPalette(palette),
              isDark: isDark,
              langCode: strings.language.code,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
    required Color accentColor,
  }) {
    final bgColor = selected
        ? accentColor.withValues(alpha: 0.18)
        : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04));

    final borderColor = selected
        ? accentColor
        : (isDark ? Colors.white10 : Colors.black12);

    final textColor = selected
        ? accentColor
        : (isDark ? Colors.white70 : Colors.black87);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 1.8 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaletteTile({
    required BuildContext context,
    required AppThemePalette palette,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required String langCode,
  }) {
    final borderColor = isSelected
        ? palette.accentGold
        : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08));

    final bgColor = isDark
        ? (isSelected ? palette.darkCard : Colors.white.withValues(alpha: 0.03))
        : (isSelected ? palette.primaryColor.withValues(alpha: 0.06) : Colors.white);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Önizleme Renk Halkası
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: palette.darkBackground,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: palette.accentGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Bilgi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      palette.localizedTitle(langCode),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      palette.localizedDescription(langCode),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Seçili İkonu veya PRO Rozeti
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: palette.accentGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 16,
                  ),
                )
              else if (palette != AppThemePalette.emerald)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: palette.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: palette.accentGold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: palette.accentGold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
