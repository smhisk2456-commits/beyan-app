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
import '../../../core/widgets/luxury_page_route.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';

/// Lüks & Kapsamlı Ayarlar Ekranı (Settings Hub)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      LuxuryPageRoute(page: const SettingsScreen()),
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
          // ── Beyân Pro Kartı ─────────────────────────────────────
          Consumer(
            builder: (context, ref, _) {
              final isPremium = ref.watch(premiumProvider).isPremium;
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? [effectivePalette.darkCard, effectivePalette.darkSurface]
                        : [BeyanColors.tone(0xFF2C2204), effectivePalette.darkBackground],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: isPremium ? 0.45 : 0.75),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isPremium
                          ? BeyanColors.tone(0xFF033E35).withValues(alpha: 0.35)
                          : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => PremiumPaywallSheet.show(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  BeyanColors.tone(0xFFFFDF7A),
                                  BeyanColors.tone(0xFFD4AF37),
                                  BeyanColors.tone(0xFF997A15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: BeyanColors.tone(0xFF071F1B),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isPremium ? 'Beyân Pro Aktif 👑' : "Beyân Pro'ya Geçin",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (!isPremium) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: BeyanColors.tone(0xFFFFDF7A),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'PRO',
                                          style: TextStyle(
                                            color: BeyanColors.tone(0xFF071F1B),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isPremium
                                      ? 'Tüm lüks temalar, makamlar ve reklamsız deneyim aktif.'
                                      : "Reklamsız deneyim, özel makamlar, kilitli widget'lar ve lüks temalar.",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: BeyanColors.tone(0xFFFFDF7A),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

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
                    LuxuryPageRoute(page: const MeccaMedinaLiveScreen()),
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
                    LuxuryPageRoute(page: const NearbyMosquesScreen()),
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
