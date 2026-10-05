import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_selector_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart' as app_widgets;
import '../../quran/models/surah.dart';
import '../../quran/providers/quran_providers.dart';
import '../../quran/screens/surah_detail_screen.dart';
import '../../home/widgets/surah_list_item.dart';

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
    final strings = ref.watch(appStringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
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
      body: Column(
        children: [
          // ── Arama Çubuğu ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF07201C) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(isDark ? 0.3 : 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
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
                      Icon(Icons.search_off_rounded,
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
                padding: const EdgeInsets.only(bottom: 110),
                itemCount: surahs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return SurahListItem(
                    surah: surah,
                    onTap: () => _openSurah(context, surah),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

  void _openSurah(BuildContext context, Surah surah) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailScreen(surah: surah),
      ),
    );
  }
}
