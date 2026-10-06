import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart' as app_widgets;
import '../../quran/models/surah.dart';
import '../../quran/providers/quran_providers.dart';
import '../../quran/providers/quran_reading_providers.dart';
import '../../quran/screens/surah_detail_screen.dart';
import '../../home/widgets/surah_list_item.dart';
import '../../monetization/widgets/banner_ad_widget.dart';

/// Bağımsız sure listesi ekranı (Kur'an-ı Kerim Menü Sekmesi).
class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(filteredSurahsProvider);
    final allSurahs = ref.watch(allSurahsProvider).valueOrNull ?? [];
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastRead = ref.watch(lastReadProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(strings.quranTitle),
        centerTitle: true,
        actions: [
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
      body: Stack(
        children: [
          Column(
            children: [
              // ── Arama Çubuğu ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF07201C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (q) =>
                        ref.read(surahSearchQueryProvider.notifier).state = q,
                    decoration: InputDecoration(
                      hintText: strings.searchSurahPlaceholder,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : AppColors.textHint,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(surahSearchQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Kaldığım Yerden Devam Et Kartı ─────────────────────
              if (lastRead != null && _searchController.text.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final targetSurah = allSurahs.firstWhere(
                        (s) => s.id == lastRead.surahId,
                        orElse: () => allSurahs.isNotEmpty ? allSurahs.first : const Surah(
                          id: 1,
                          nameArabic: 'الفاتحة',
                          nameTurkish: 'Fâtiha',
                          nameEnglish: 'Al-Fatiha',
                          revelationType: 'meccan',
                          verseCount: 7,
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SurahDetailScreen(
                            surah: targetSurah,
                            initialScrollToVerse: lastRead.verseNumber,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF012E2B), Color(0xFF034A3E)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bookmark_added_rounded, color: Color(0xFFFFDF7A), size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kaldığım Yerden Devam Et',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFDF7A),
                                  ),
                                ),
                                Text(
                                  '${lastRead.surahName} • ${lastRead.verseNumber}. Ayet',
                                  style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFDF7A), size: 14),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Sure Listesi ──────────────────────────────────────
              Expanded(
                child: surahsAsync.when(
                  loading: () => const app_widgets.LoadingWidget(
                    message: 'Sureler yükleniyor...',
                  ),
                  error: (e, _) => app_widgets.AppErrorWidget(
                    message: 'Yüklenemedi: $e',
                    onRetry: () => ref.invalidate(filteredSurahsProvider),
                  ),
                  data: (surahs) {
                    if (surahs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 48, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            Text(
                              'Sure bulunamadı',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 90, top: 4),
                      physics: const BouncingScrollPhysics(),
                      itemCount: surahs.length,
                      separatorBuilder: (_, __) => Divider(
                        color: isDark ? const Color(0xFF133B34) : const Color(0xFFE2EBE8),
                        height: 1,
                        indent: 72,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final surah = surahs[index];
                        return SurahListItem(
                          surah: surah,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SurahDetailScreen(surah: surah),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Alt banner reklam
              const BannerAdWidget(),
            ],
          ),
        ],
      ),
    );
  }
}
