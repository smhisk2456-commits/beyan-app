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
import '../../verse_studio/screens/verse_card_studio_screen.dart';
import '../../widget_service/screens/widget_settings_dialog.dart';

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
          _buildSectionHeader(
            strings.language == AppLanguage.english
                ? 'Appearance & Language'
                : (strings.language == AppLanguage.arabic ? 'المظهر واللغة' : 'Görünüm & Dil'),
          ),
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
                subtitle: 'Zümrüt Yeşili, Gece Safiri, OLED Siyah...',
                onTap: () => ThemeSelectionSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 3. Ezan, Makamlar & Bildirimler ─────────────────────
          _buildSectionHeader(
            strings.language == AppLanguage.english
                ? 'Adhan & Notifications'
                : (strings.language == AppLanguage.arabic ? 'الأذان والإشعارات' : 'Ezan & Bildirimler'),
          ),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.music_note_rounded,
                iconColor: const Color(0xFFFFDF7A),
                title: strings.specialAdhanMakamsPro,
                subtitle: 'İstanbul, Mekke, Medine ve Tekbir Makamları',
                onTap: () => AdhanMakamSelectorSheet.show(context),
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.notifications_active_outlined,
                iconColor: const Color(0xFF4DB6AC),
                title: strings.notificationSettings,
                subtitle: 'Vakit ezanları, hatırlatıcılar ve günlük âyetler',
                onTap: () => NotificationSettingsSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 4. Namaz Vakti & Konum Hesaplaması ───────────────────
          _buildSectionHeader(
            strings.language == AppLanguage.english
                ? 'Prayer Times & Calculation'
                : (strings.language == AppLanguage.arabic ? 'المواقيت والحساب' : 'Namaz Vakti & Konum'),
          ),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.location_city_rounded,
                iconColor: const Color(0xFFFF8A65),
                title: strings.language == AppLanguage.turkish
                    ? 'Şehir Değiştir'
                    : (strings.language == AppLanguage.english ? 'Change City' : 'تغيير المدينة'),
                subtitle: 'Türkiye (Diyanet) ve dünya şehirleri',
                onTap: () => CitySelectorSheet.show(context, ref),
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF81C784),
                title: strings.calculationMethodTitle,
                subtitle: 'Diyanet İşleri Başkanlığı takvimi',
                onTap: () => CalculationMethodSheet.show(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 5. Lüks Özellikler & Stüdyo ─────────────────────────
          _buildSectionHeader(
            strings.language == AppLanguage.english
                ? 'Special Features'
                : (strings.language == AppLanguage.arabic ? 'ميزات خاصة' : 'Lüks Deneyimler'),
          ),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.mosque_rounded,
                iconColor: const Color(0xFFD4AF37),
                title: 'Mekke & Medine 24/7 Canlı Yayın',
                subtitle: 'Kâbe-i Muazzama ve Mescid-i Nebevi resmi yayını',
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
                title: 'iOS StandBy (Gece Masası Saati)',
                subtitle: 'Loş OLED dijital saat ve sahur/imsak sayacı',
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
                title: 'Ayet & Hikaye Stüdyosu',
                subtitle: 'Instagram Hikaye ve estetik duvar kağıdı oluşturucu',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerseCardStudioScreen(
                        initialReference: 'İnşirâh 94:6',
                        initialArabic: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
                        initialMeaning: 'Şüphesiz her güçlükle beraber bir kolaylık vardır.',
                      ),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.widgets_outlined,
                iconColor: const Color(0xFF2DD4BF),
                title: strings.language == AppLanguage.english
                    ? 'Lock Screen & Widgets'
                    : (strings.language == AppLanguage.arabic ? 'شاشة القفل والويدجت' : 'Kilit Ekranı & Widget Tercihleri'),
                subtitle: 'Yenileme sıklığı ve widget görünüm ayarları',
                onTap: () => showWidgetSettings(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── 6. Paylaş & Hakkında ────────────────────────────────
          _buildSectionHeader(
            strings.language == AppLanguage.english
                ? 'About & Share'
                : (strings.language == AppLanguage.arabic ? 'حول التطبيق' : 'Hakkında & Paylaş'),
          ),
          _buildCard(
            context,
            isDark,
            children: [
              _buildTile(
                icon: Icons.share_rounded,
                iconColor: const Color(0xFF64B5F6),
                title: strings.language == AppLanguage.english
                    ? 'Share Beyân'
                    : (strings.language == AppLanguage.arabic ? 'شارك بيان' : 'Beyân\'ı Sevdiklerinle Paylaş'),
                subtitle: 'Sadaka-i cariye niyetiyle hayra vesile ol',
                onTap: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'Namaz vakitleri, kilit ekranı ayet widget\'ları ve tarihi ezan makamları içeren Beyân uygulamasını keşfedin: https://testflight.apple.com/join/Q3UDfndV',
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildTile(
                icon: Icons.info_outline_rounded,
                iconColor: Colors.white60,
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
                        child: const Text(
                          'AKTİF',
                          style: TextStyle(
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
                      ? 'Tüm tarihi ezan makamları ve lüks özellikler açık'
                      : 'Mekke & Medine makamları, reklamsız huzur ve sınırsız widget',
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
              isPremium ? 'Yönet' : 'Yükselt',
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
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
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
