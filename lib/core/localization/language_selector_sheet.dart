import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_strings.dart';

/// Lüks İslami tasarıma sahip dil seçici alt sayfası.
class LanguageSelectorSheet extends ConsumerWidget {
  const LanguageSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? BeyanColors.tone(0xFF071B18) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels <= 0 &&
                  notification.scrollDelta != null &&
                  notification.scrollDelta! < -10) {
                Navigator.pop(context);
                return true;
              }
              return false;
            },
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sürükleme Tutamağı (Aşağı kaydırarak veya dokunarak kapatma)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta != null && details.primaryDelta! > 6) {
                        Navigator.pop(context);
                      }
                    },
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white38,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Başlık
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          color: BeyanColors.tone(0xFFD4AF37),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          strings.languageSelect,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : BeyanColors.tone(0xFF033E35),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                        color: Colors.white70,
                        tooltip: 'Kapat',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                // Dil Seçenekleri
                ...AppLanguage.values.map((lang) {
                  final isSelected = lang == currentLang;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isSelected
                          ? BeyanColors.tone(0xFF033E35).withValues(alpha: isDark ? 0.4 : 0.08)
                          : (isDark ? BeyanColors.tone(0xFF0D2823) : BeyanColors.tone(0xFFF7FAF9)),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(appLanguageProvider.notifier).setLanguage(lang);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? BeyanColors.tone(0xFFD4AF37)
                                  : (isDark ? BeyanColors.tone(0xFF133B34) : BeyanColors.tone(0xFFE2EBE8)),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                lang.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.displayName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isDark ? Colors.white : BeyanColors.tone(0xFF11221F),
                                      ),
                                    ),
                                    Text(
                                      lang.shortCode,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: BeyanColors.tone(0xFFD4AF37),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: BeyanColors.tone(0xFF01201D),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

/// Dil seçici alt sayfasını açar.
void showLanguageSelectorSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (ctx) => const LanguageSelectorSheet(),
  );
}
