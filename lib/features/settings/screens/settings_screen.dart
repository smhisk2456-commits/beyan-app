import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/screens/theme_selection_sheet.dart';
import '../../../core/theme/theme_provider.dart';
import '../../live_makkah/screens/mecca_medina_live_screen.dart';
import '../../notifications/screens/notification_settings_sheet.dart';
import '../../notifications/screens/adhan_makam_selector_sheet.dart';
import '../../prayer_times/screens/calculation_method_sheet.dart';
import '../../prayer_times/screens/city_selector_sheet.dart';
import '../../widget_service/screens/widget_settings_dialog.dart';
import '../../widget_service/screens/live_activity_settings_sheet.dart';
import '../../mosque_finder/screens/nearby_mosques_screen.dart';

/// Lüks & Kapsamlı Ayarlar Ekranı (Settings Hub)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isLiveActivityEnabled = ref.watch(liveActivityEnabledProvider);
    final isLiveActivitySupported = ref.watch(isLiveActivitySupportedProvider).valueOrNull ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? effectivePalette.darkBackground : effectivePalette.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? effectivePalette.darkSurface : effectivePalette.primaryColor,
        title: Text(
          strings.settings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── 1. Görünüm & Dil Bölümü ─────────────────────────────
          _buildSectionHeader(strings.appearanceSection),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF64B5F6),
                title: strings.languageSelect,
                subtitle: '${currentLang.flag} ${currentLang.displayName}',
                onTap: () => showLanguageSelectorSheet(context),
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.palette_outlined,
                iconColor: const Color(0xFFBA68C8),
                title: strings.appearanceAndTheme,
                subtitle: strings.themeSubtitle,
                onTap: () => ThemeSelectionSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 3. Ezan, Makamlar & Bildirimler ─────────────────────
          _buildSectionHeader(strings.adhanSection),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.music_note_rounded,
                iconColor: BeyanColors.tone(0xFFFFDF7A),
                title: strings.specialAdhanMakamsPro,
                subtitle: strings.specialAdhanSubtitle,
                onTap: () => AdhanMakamSelectorSheet.show(context),
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.notifications_active_outlined,
                iconColor: BeyanColors.tone(0xFF4DB6AC),
                title: strings.notificationSettings,
                subtitle: strings.notificationSettingsSubtitle,
                onTap: () => NotificationSettingsSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 4. Namaz Vakti & Konum Hesaplaması ───────────────────
          _buildSectionHeader(strings.prayerCalculationSection),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.location_city_rounded,
                iconColor: const Color(0xFFFF8A65),
                title: strings.changeCity,
                subtitle: strings.changeCitySubtitle,
                onTap: () => CitySelectorSheet.show(context, ref),
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF81C784),
                title: strings.calculationMethodTitle,
                subtitle: strings.calculationMethodSubtitle,
                onTap: () => CalculationMethodSheet.show(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 5. Lüks Özellikler & Stüdyo ─────────────────────────
          _buildSectionHeader(strings.specialFeaturesSection),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.mosque_rounded,
                iconColor: BeyanColors.tone(0xFFD4AF37),
                title: strings.liveBroadcastTitle,
                subtitle: strings.liveBroadcastSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MeccaMedinaLiveScreen()),
                  );
                },
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.explore_rounded,
                iconColor: BeyanColors.tone(0xFF34D399),
                title: strings.nearbyMosquesTitle,
                subtitle: strings.nearbyMosquesSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NearbyMosquesScreen()),
                  );
                },
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.widgets_outlined,
                iconColor: BeyanColors.tone(0xFF2DD4BF),
                title: strings.lockscreenWidgetsTitle,
                subtitle: strings.lockscreenWidgetsSubtitle,
                onTap: () => showWidgetSettings(context),
              ),
              if (isLiveActivitySupported) ...[
                _buildDivider(),
                _buildTile(
                  icon: Icons.apple_rounded,
                  iconColor: BeyanColors.tone(0xFFFFDF7A),
                  title: strings.language == AppLanguage.turkish
                      ? 'Dynamic Island & Canlı Etkinlik'
                      : 'Dynamic Island & Live Activity',
                  subtitle: isLiveActivityEnabled
                      ? (strings.language == AppLanguage.turkish
                          ? 'Açık • Görünme zamanını ve ada ayarlarını özelleştir'
                          : 'Enabled • Customize trigger time & island behavior')
                      : (strings.language == AppLanguage.turkish
                          ? 'Kapalı • Canlı etkinlikler devre dışı'
                          : 'Disabled • Live activities turned off'),
                  onTap: () => LiveActivitySettingsSheet.show(context),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // ── 6. Paylaş & Hakkında ────────────────────────────────
          _buildSectionHeader(strings.aboutAndShareSection),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.share_rounded,
                iconColor: const Color(0xFF64B5F6),
                title: strings.shareBeyanTitle,
                subtitle: strings.shareBeyanSubtitle,
                onTap: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: strings.shareAppMessage,
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildTile(
                customLeading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: 'Beyân v1.0.0',
                subtitle: 'Google Flutter & iOS 18+ Apple Design',
                onTap: null,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: BeyanColors.tone(0xFFFFDF7A),
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool isDark, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF032620) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    IconData? icon,
    Color? iconColor,
    Widget? customLeading,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: customLeading ??
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? BeyanColors.tone(0xFFFFDF7A)).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11.5,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white38)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.7,
      indent: 58,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}
