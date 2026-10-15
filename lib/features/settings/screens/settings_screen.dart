import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../../core/theme/screens/theme_selection_sheet.dart';
import '../../bedside_clock/screens/bedside_clock_screen.dart';
import '../../live_makkah/screens/mecca_medina_live_screen.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';
import '../../notifications/screens/notification_settings_sheet.dart';
import '../../notifications/screens/adhan_makam_selector_sheet.dart';
import '../../prayer_times/screens/calculation_method_sheet.dart';
import '../../prayer_times/screens/city_selector_sheet.dart';
import '../../notifications/models/short_verse_notification.dart';
import '../../verse_studio/screens/verse_card_studio_screen.dart';
import '../../widget_service/screens/widget_settings_dialog.dart';
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
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
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
          // ── 1. Beyân Premium Kartı ──────────────────────────────
          _buildPremiumCard(context, isPremium, strings),
          const SizedBox(height: 18),

          // ── 2. Görünüm & Dil Bölümü ─────────────────────────────
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
                iconColor: const Color(0xFFFFDF7A),
                title: strings.specialAdhanMakamsPro,
                subtitle: strings.specialAdhanSubtitle,
                onTap: () => AdhanMakamSelectorSheet.show(context),
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.notifications_active_outlined,
                iconColor: const Color(0xFF4DB6AC),
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
                iconColor: const Color(0xFFD4AF37),
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
                icon: Icons.bedtime_rounded,
                iconColor: const Color(0xFFFFD54F),
                title: strings.bedsideClockTitle,
                subtitle: strings.bedsideClockSubtitle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BedsideClockScreen()),
                  );
                },
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.style_rounded,
                iconColor: const Color(0xFFF48FB1),
                title: strings.verseStudioTitle,
                subtitle: strings.verseStudioSubtitle,
                onTap: () {
                  final initial = ShortVerseNotification.pool.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerseCardStudioScreen(
                        initialReference: initial.localizedReference(strings.language.code),
                        initialArabic: initial.arabicText,
                        initialMeaning: initial.localizedText(strings.language.code),
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.explore_rounded,
                iconColor: const Color(0xFF34D399),
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
                iconColor: const Color(0xFF2DD4BF),
                title: strings.lockscreenWidgetsTitle,
                subtitle: strings.lockscreenWidgetsSubtitle,
                onTap: () => showWidgetSettings(context),
              ),
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
                      color: const Color(0xFFFFDF7A).withValues(alpha: 0.5),
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

  Widget _buildPremiumCard(BuildContext context, bool isPremium, AppStrings strings) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF033E35), Color(0xFF01201B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              border: Border.all(color: const Color(0xFFFFDF7A), width: 1.2),
            ),
            child: const Center(
              child: Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFFFFDF7A),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Beyân Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          strings.activeStatus,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isPremium
                      ? strings.premiumActiveSubtitle
                      : strings.premiumPromoSubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => PremiumPaywallSheet.show(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDF7A),
              foregroundColor: const Color(0xFF01201B),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              isPremium ? strings.manageAction : strings.upgradeAction,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFFFDF7A),
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
        color: isDark ? const Color(0xFF032620) : Colors.white,
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
              color: (iconColor ?? const Color(0xFFFFDF7A)).withValues(alpha: 0.15),
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
