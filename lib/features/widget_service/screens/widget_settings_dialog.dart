import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_strings.dart';
import '../widget_service.dart';

/// Lüks Ayarlar ve Dil Seçimi Alt Menüsü
class WidgetSettingsDialog extends ConsumerStatefulWidget {
  const WidgetSettingsDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<WidgetSettingsDialog> createState() => _WidgetSettingsDialogState();
}

class _WidgetSettingsDialogState extends ConsumerState<WidgetSettingsDialog> {
  int _selectedInterval = 5;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInterval();
  }

  Future<void> _loadInterval() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('widget_update_interval') ?? 5;
    setState(() {
      _selectedInterval = saved.clamp(3, 15);
      _isLoading = false;
    });
  }

  Future<void> _saveInterval(int interval) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('widget_update_interval', interval);
    setState(() => _selectedInterval = interval);
    
    // Değişikliği anında uygulamak için widget servisini tetikle
    await ref.read(widgetServiceProvider).updateAllWidgets();
    
    if (mounted) {
      final strings = ref.read(appStringsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${strings.widgetIntervalTitle}: ${strings.minutesSuffix(interval)}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      );
    }

    final intervals = [3, 5, 10, 15];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF071B18) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
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

          // Başlık
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings_suggest_rounded,
                  color: Color(0xFFD4AF37),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strings.settings,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF033E35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Dil Seçimi Bölümü ──
          Text(
            strings.languageSelect,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF033E35),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: AppLanguage.values.map((lang) {
              final isSelected = lang == currentLang;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(appLanguageProvider.notifier).setLanguage(lang);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF033E35).withOpacity(isDark ? 0.6 : 0.12)
                            : (isDark ? const Color(0xFF0D2823) : const Color(0xFFF0F5F3)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFD4AF37)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lang.flag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            lang.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? const Color(0xFFFFDF7A) : const Color(0xFF033E35))
                                  : (isDark ? Colors.white60 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),

          // ── Ayet Döngü Süresi Bölümü ──
          Text(
            strings.widgetIntervalTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF033E35),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.widgetIntervalDesc,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: intervals.map((m) {
              final isSelected = m == _selectedInterval;
              return ChoiceChip(
                label: Text(strings.minutesShort(m)),
                selected: isSelected,
                selectedColor: const Color(0xFF033E35),
                backgroundColor: isDark ? const Color(0xFF0D2823) : const Color(0xFFF0F5F3),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                  ),
                ),
                onSelected: (_) => _saveInterval(m),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

void showWidgetSettings(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const WidgetSettingsDialog(),
  );
}
