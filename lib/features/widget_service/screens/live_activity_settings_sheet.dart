import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../services/live_activity_service.dart';
import '../widget_service.dart';

class LiveActivityOption {
  final int minutes;
  final String titleTr;
  final String titleEn;
  final String subtitleTr;
  final String subtitleEn;
  final IconData icon;

  const LiveActivityOption({
    required this.minutes,
    required this.titleTr,
    required this.titleEn,
    required this.subtitleTr,
    required this.subtitleEn,
    required this.icon,
  });

  String localizedTitle(String langCode) => langCode == 'tr' ? titleTr : titleEn;
  String localizedSubtitle(String langCode) => langCode == 'tr' ? subtitleTr : subtitleEn;
}

const List<LiveActivityOption> liveActivityOptions = [
  LiveActivityOption(
    minutes: -1,
    titleTr: 'Her Zaman Açık (Sürekli - Önerilen)',
    titleEn: 'Always Active (Continuous - Recommended)',
    subtitleTr: 'Dynamic Island ve kilit ekranında gün boyu sürekli canlı geri sayım',
    subtitleEn: 'Continuous countdown on Dynamic Island and Lock Screen all day',
    icon: Icons.all_inclusive_rounded,
  ),
  LiveActivityOption(
    minutes: 60,
    titleTr: 'Vakte 60 Dakika Kala',
    titleEn: '60 Minutes Before Prayer',
    subtitleTr: 'Ezan vaktine 1 saat kaldığında canlı geri sayım başlar',
    subtitleEn: 'Countdown starts 1 hour before the adhan',
    icon: Icons.hourglass_top_rounded,
  ),
  LiveActivityOption(
    minutes: 45,
    titleTr: 'Vakte 45 Dakika Kala',
    titleEn: '45 Minutes Before',
    subtitleTr: 'İdeal pil ve dikkat dengesi, namaz hazırlığı için tam zamanında',
    subtitleEn: 'Ideal battery & focus balance, right on time for preparation',
    icon: Icons.stars_rounded,
  ),
  LiveActivityOption(
    minutes: 30,
    titleTr: 'Vakte 30 Dakika Kala',
    titleEn: '30 Minutes Before Prayer',
    subtitleTr: 'Yarım saat kaldığında ada genişleyerek geri sayıma başlar',
    subtitleEn: 'Island expands and starts countdown 30 mins prior',
    icon: Icons.timer_outlined,
  ),
  LiveActivityOption(
    minutes: 15,
    titleTr: 'Vakte 15 Dakika Kala',
    titleEn: '15 Minutes Before Prayer',
    subtitleTr: 'Yalnızca son 15 dakikada ada üzerinde uyarır',
    subtitleEn: 'Only alerts on the island in the final 15 minutes',
    icon: Icons.alarm_rounded,
  ),
  LiveActivityOption(
    minutes: 0,
    titleTr: 'Yalnızca Vakit Girdiğinde',
    titleEn: 'Only When Prayer Enters',
    subtitleTr: 'Ezan anında ve kerâhet süresince kilit ekranında gösterilir',
    subtitleEn: 'Appears at adhan moment and during prayer window',
    icon: Icons.mosque_rounded,
  ),
  LiveActivityOption(
    minutes: -999,
    titleTr: 'Devre Dışı Bırak (Kapat)',
    titleEn: 'Disable Completely (Turn Off)',
    subtitleTr: 'Dynamic Island ve kilit ekranı canlı etkinliğini tamamen kapatır',
    subtitleEn: 'Completely disables Dynamic Island & lock screen live activities',
    icon: Icons.notifications_off_rounded,
  ),
];

class LiveActivityEnabledNotifier extends StateNotifier<bool> {
  LiveActivityEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final enabled = await LiveActivityService().isEnabled();
    state = enabled;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await LiveActivityService().setEnabled(enabled);
    await WidgetService().updateAllWidgets();
  }
}

final liveActivityEnabledProvider =
    StateNotifierProvider<LiveActivityEnabledNotifier, bool>((ref) {
  return LiveActivityEnabledNotifier();
});

final isLiveActivitySupportedProvider = FutureProvider<bool>((ref) async {
  return LiveActivityService().isSupported();
});

class LiveActivityTriggerNotifier extends StateNotifier<int> {
  static const String key = 'live_activity_trigger_minutes';

  LiveActivityTriggerNotifier() : super(-1) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var val = prefs.getInt(key) ?? -1;
      if (val == 45) {
        val = -1;
        await prefs.setInt(key, -1);
      }
      state = val;
    } catch (_) {}
  }

  Future<void> setTriggerMinutes(int minutes) async {
    state = minutes;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, minutes);
      await HomeWidget.saveWidgetData<int>(key, minutes);
      await LiveActivityService().syncLiveActivity(customTriggerMinutes: minutes);
      await WidgetService().updateAllWidgets();
    } catch (_) {}
  }
}

final liveActivityTriggerProvider =
    StateNotifierProvider<LiveActivityTriggerNotifier, int>((ref) {
  return LiveActivityTriggerNotifier();
});

class LiveActivitySettingsSheet extends ConsumerWidget {
  const LiveActivitySettingsSheet({super.key});

  static void show(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LiveActivitySettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);
    final selectedMinutes = ref.watch(liveActivityTriggerProvider);
    final isEnabled = ref.watch(liveActivityEnabledProvider);
    final langCode = strings.language.code;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF04241E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFDF7A), Color(0xFFB8860B)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFDF7A).withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.apple_rounded, color: Color(0xFF01201B), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      langCode == 'tr'
                          ? 'Dynamic Island & Canlı Etkinlik'
                          : 'Dynamic Island & Live Activity',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      langCode == 'tr'
                          ? 'Geri sayımın adada ne zaman başlayacağını seçin'
                          : 'Choose when countdown appears on island & lockscreen',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Ana Açma / Kapatma Kartı ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF083228) : const Color(0xFFF1F8F5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isEnabled
                    ? const Color(0xFFFFDF7A)
                    : (isDark ? const Color(0xFF133B32) : const Color(0xFFE2EBE8)),
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isEnabled ? Icons.power_settings_new_rounded : Icons.power_off_rounded,
                  color: isEnabled ? const Color(0xFFFFDF7A) : Colors.white38,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        langCode == 'tr' ? 'Canlı Etkinlikleri Etkinleştir' : 'Enable Live Activities',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEnabled
                            ? (langCode == 'tr'
                                ? 'Dynamic Island ve Kilit Ekranı aktif'
                                : 'Active on Dynamic Island & Lock Screen')
                            : (langCode == 'tr'
                                ? 'Tamamen devre dışı bırakıldı (Kapalı)'
                                : 'Completely disabled (Off)'),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isEnabled
                              ? (isDark ? const Color(0xFF80CBC4) : const Color(0xFF0F5A47))
                              : Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isEnabled,
                  activeThumbColor: const Color(0xFFFFDF7A),
                  activeTrackColor: const Color(0xFF0F5A47),
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    ref.read(liveActivityEnabledProvider.notifier).setEnabled(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? (langCode == 'tr'
                                  ? 'Canlı Etkinlikler etkinleştirildi.'
                                  : 'Live Activities enabled.')
                              : (langCode == 'tr'
                                  ? 'Canlı Etkinlikler kapatıldı.'
                                  : 'Live Activities disabled.'),
                        ),
                        backgroundColor: const Color(0xFF033E35),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Options List
          Opacity(
            opacity: isEnabled ? 1.0 : 0.45,
            child: IgnorePointer(
              ignoring: !isEnabled,
              child: Column(
                children: liveActivityOptions.map((opt) {
                  final isDisableOption = opt.minutes == -999;
                  final isSelected = isEnabled
                      ? (selectedMinutes == opt.minutes)
                      : isDisableOption;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? const Color(0xFF0C3D32) : const Color(0xFFF1F8F5))
                          : (isDark ? const Color(0xFF062C24) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDisableOption ? const Color(0xFFFF6B6B) : const Color(0xFFFFDF7A))
                            : (isDark ? const Color(0xFF0D3830) : const Color(0xFFE2EBE8)),
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      leading: Icon(
                        opt.icon,
                        color: isSelected
                            ? (isDisableOption ? const Color(0xFFFF6B6B) : const Color(0xFFFFDF7A))
                            : Colors.white54,
                        size: 24,
                      ),
                      title: Text(
                        opt.localizedTitle(langCode),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? (isDisableOption
                                  ? const Color(0xFFFF6B6B)
                                  : (isDark ? const Color(0xFFFFDF7A) : AppColors.teal))
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      subtitle: Text(
                        opt.localizedSubtitle(langCode),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: isDisableOption ? const Color(0xFFFF6B6B) : const Color(0xFFFFDF7A),
                              size: 20,
                            )
                          : const Icon(Icons.radio_button_off_rounded, color: Colors.white24, size: 20),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        if (isDisableOption) {
                          await ref.read(liveActivityEnabledProvider.notifier).setEnabled(false);
                        } else {
                          if (!isEnabled) {
                            await ref.read(liveActivityEnabledProvider.notifier).setEnabled(true);
                          }
                          await ref.read(liveActivityTriggerProvider.notifier).setTriggerMinutes(opt.minutes);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
