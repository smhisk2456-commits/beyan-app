import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../widget_service.dart';
import '../../monetization/providers/premium_provider.dart';
import '../../monetization/screens/premium_paywall_sheet.dart';
import '../../monetization/widgets/banner_ad_widget.dart';

/// Kilit Ekranı & Widget Yönetim Merkezi
class WidgetCenterScreen extends ConsumerStatefulWidget {
  const WidgetCenterScreen({super.key});

  @override
  ConsumerState<WidgetCenterScreen> createState() => _WidgetCenterScreenState();
}

class _WidgetCenterScreenState extends ConsumerState<WidgetCenterScreen> {
  int _selectedInterval = 5;
  bool _isLoading = true;
  bool _isUpdating = false;

  final List<int> _intervals = [3, 5, 10, 15];

  @override
  void initState() {
    super.initState();
    _loadSavedInterval();
  }

  Future<void> _loadSavedInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('widget_update_interval') ?? 5;
    setState(() {
      _selectedInterval = saved.clamp(3, 15);
      _isLoading = false;
    });
  }

  Future<void> _saveInterval(int minutes) async {
    setState(() => _selectedInterval = minutes);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('widget_update_interval', minutes);
    await WidgetService().updateAllWidgets();
    if (mounted) {
      final strings = ref.read(appStringsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${strings.widgetIntervalTitle}: ${strings.minutesSuffix(minutes)}'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _triggerManualRefresh() async {
    setState(() => _isUpdating = true);
    await WidgetService().updateAllWidgets();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🌙 Ayet güncellendi / Verse refreshed!'),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(strings.widgetCenterTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              ref.watch(premiumProvider).isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.workspace_premium_outlined,
              color: const Color(0xFFFFDF7A),
            ),
            tooltip: ref.watch(premiumProvider).isPremium ? 'Beyân Premium' : 'Premium & Reklamsız',
            onPressed: () => PremiumPaywallSheet.show(context),
          ),
          // Dil Seçici Buton
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showLanguageSelectorSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currentLang.flag, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      currentLang.shortCode,
                      style: const TextStyle(
                        color: Color(0xFFFFDF7A),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Kilit Ekranı Önizleme Kartı ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF012E2B),
                          Color(0xFF02443C),
                          Color(0xFF033E35),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF01201D).withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.phone_iphone_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                strings.widgetPreviewTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                strings.minutesShort(_selectedInterval),
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Simüle Edilmiş Kilit Ekranı Dikdörtgen Widget'ı
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'An-Nahl 114',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text('🌙', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Allah\'ın nimetlerini saymaya kalksanız sayamazsınız...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.gold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${strings.prayerNameDhuhr} 13:00  •  02:15 ${strings.remainingTime}',
                                    style: const TextStyle(
                                      color: AppColors.tealLight,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Zamanlayıcı Ayarı Başlığı ─────────────────────────────
                  Text(
                    strings.widgetIntervalTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.widgetIntervalDesc,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dakika Seçim Butonları
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _intervals.map((minutes) {
                      final isSelected = _selectedInterval == minutes;
                      return ChoiceChip(
                        label: Text(strings.minutesSuffix(minutes)),
                        selected: isSelected,
                        onSelected: (_) => _saveInterval(minutes),
                        selectedColor: AppColors.teal,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textPrimary),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: isDark ? AppColors.darkCard : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppColors.teal : Colors.transparent,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Manuel Yenileme Butonu
                  ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _triggerManualRefresh,
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(_isUpdating ? '...' : strings.refreshVerseNow),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Nasıl Kullanılır Rehberi ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline_rounded, color: AppColors.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              strings.howToAdd,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _guideStep(
                          '1',
                          strings.iphoneGuideTitle,
                          strings.iphoneGuideDesc,
                        ),
                        const SizedBox(height: 8),
                        _guideStep(
                          '2',
                          strings.androidGuideTitle,
                          strings.androidGuideDesc,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ── Saygılı Alt Banner Reklam (Premium'da otomatik gizlenir) ──
                  const BannerAdWidget(),
                ],
              ),
            ),
    );
  }

  Widget _guideStep(String num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.teal,
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
