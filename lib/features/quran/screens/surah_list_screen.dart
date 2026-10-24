import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/common_widgets.dart' as app_widgets;
import '../../home/widgets/surah_list_item.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../../ramadan/models/khatam_tracker_model.dart';
import '../../settings/screens/settings_screen.dart';
import '../../dua/screens/dua_library_screen.dart';
import '../../dua/providers/dua_providers.dart';
import '../models/quran_featured_verse.dart';
import '../models/surah.dart';
import '../providers/quran_providers.dart';
import '../providers/quran_reading_providers.dart';
import '../screens/surah_detail_screen.dart';
import '../models/quran_thematic_topic.dart';
import 'thematic_atlas_screen.dart';
import 'thematic_topic_detail_screen.dart';
import '../../../core/widgets/luxury_page_route.dart';
import '../../../main.dart';

enum _QuranTab { surahs, juzs, versesAndDuas, favorites }
enum _SurahFilter { all, meccan, medinan, famous }

/// Kur'an-ı Kerim Ekranı
/// - 3 Ana Kategori: Sureler (114), Cüzler (30 Cüz), Önemli Âyet & Dualar
/// - Akıllı Arama: Sureler + Âyetü'l-Kürsî ve diğer dualar + Dua Kütüphanesi Köprüsü
/// - 120 FPS Donanım Hızlandırmalı Akıcı Kaydırma (itemExtent optimize)
class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  final _searchController = TextEditingController();
  _QuranTab _selectedTab = _QuranTab.surahs;
  _SurahFilter _selectedFilter = _SurahFilter.all;

  static const _famousSurahIds = {1, 2, 18, 36, 48, 55, 56, 67, 78, 94, 112, 113, 114};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSurahAtVerse(Surah surah, int verseNumber) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      LuxuryPageRoute(
        page: SurahDetailScreen(
          surah: surah,
          initialScrollToVerse: verseNumber,
        ),
      ),
    );
  }

  void _openDuaLibraryWithQuery(String query) {
    HapticFeedback.mediumImpact();
    ref.read(duaSearchQueryProvider.notifier).state = query;
    Navigator.push(
      context,
      LuxuryPageRoute(page: const DuaLibraryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final allSurahsAsync = ref.watch(allSurahsProvider);
    final allSurahs = allSurahsAsync.valueOrNull ?? [];
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lastRead = ref.watch(lastReadProvider);
    final searchQuery = _searchController.text.trim();
    final isSearching = searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? effectivePalette.darkBackground : effectivePalette.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? effectivePalette.darkSurface : effectivePalette.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          tooltip: strings.language == AppLanguage.turkish ? 'Ana Sayfaya Dön' : 'Back to Home',
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(selectedTabProvider.notifier).state = 0;
          },
        ),
        title: Text(
          strings.quranTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: strings.settings,
            onPressed: () => SettingsScreen.show(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Arama Çubuğu ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? BeyanColors.tone(0xFF07201C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (q) {
                      setState(() {});
                    },
                    style: TextStyle(
                      fontSize: 14.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: strings.searchQuranHint,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : AppColors.textHint,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: BeyanColors.tone(0xFFD4AF37),
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Kaldığım Yerden Devam Et Kartı ─────────────────────────────
              if (lastRead != null && !isSearching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
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
                      _openSurahAtVerse(targetSurah, lastRead.verseNumber);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [BeyanColors.tone(0xFF012E2B), BeyanColors.tone(0xFF034A3E)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.bookmark_added_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.resumeReading,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: BeyanColors.tone(0xFFFFDF7A),
                                  ),
                                ),
                                Text(
                                  '${lastRead.surahName} • ${strings.verseNumberLabel(lastRead.verseNumber)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 12),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Tematik Kur'an Fihristi & Kavram Atlası Öne Çıkan Kartı ──
              if (!isSearching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        LuxuryPageRoute(page: const ThematicAtlasScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [BeyanColors.tone(0xFF032B25), BeyanColors.tone(0xFF011814)]
                              : [const Color(0xFFFBF8ED), const Color(0xFFF1EAD8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.45 : 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4)),
                            ),
                            child: Icon(Icons.explore_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      strings.language == AppLanguage.turkish
                                          ? 'Tematik Kur\'an Fihristi'
                                          : 'Thematic Quran Atlas',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '12 Konu',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: BeyanColors.tone(0xFFFFDF7A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  strings.language == AppLanguage.turkish
                                      ? 'Sabır, Rızık, Şifa, Aile, Tevbe ve Yaşam Âyetleri'
                                      : 'Patience, Healing, Sustenance & Family Verses',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 13),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── 3 Ana Kategori Sekmesi (Sureler / Cüzler / Önemli Âyet & Dualar) ──
              if (!isSearching)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: isDark ? BeyanColors.tone(0xFF06221D) : BeyanColors.tone(0xFFE9F3EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildCategoryTabButton(
                            label: strings.tabSurahs,
                            icon: Icons.auto_stories_rounded,
                            isActive: _selectedTab == _QuranTab.surahs,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedTab = _QuranTab.surahs;
                              });
                            },
                            isDark: isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildCategoryTabButton(
                            label: '${strings.tabJuzs} (30)',
                            icon: Icons.menu_book_rounded,
                            isActive: _selectedTab == _QuranTab.juzs,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedTab = _QuranTab.juzs;
                              });
                            },
                            isDark: isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildCategoryTabButton(
                            label: strings.tabImportantVerses,
                            icon: Icons.spa_rounded,
                            isActive: _selectedTab == _QuranTab.versesAndDuas,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedTab = _QuranTab.versesAndDuas;
                              });
                            },
                            isDark: isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildCategoryTabButton(
                            label: strings.language == AppLanguage.turkish ? 'Favoriler' : 'Favorites',
                            icon: Icons.star_rounded,
                            isActive: _selectedTab == _QuranTab.favorites,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedTab = _QuranTab.favorites;
                              });
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Sureler Alt Filtre Çipleri (Mekkî / Medenî / Meşhur) ─────────
              if (!isSearching && _selectedTab == _QuranTab.surahs)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterPill(
                          label: strings.filterAllSurahs,
                          isSelected: _selectedFilter == _SurahFilter.all,
                          onTap: () => setState(() => _selectedFilter = _SurahFilter.all),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        _buildFilterPill(
                          label: strings.filterMeccan,
                          isSelected: _selectedFilter == _SurahFilter.meccan,
                          onTap: () => setState(() => _selectedFilter = _SurahFilter.meccan),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        _buildFilterPill(
                          label: strings.filterMedinan,
                          isSelected: _selectedFilter == _SurahFilter.medinan,
                          onTap: () => setState(() => _selectedFilter = _SurahFilter.medinan),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 6),
                        _buildFilterPill(
                          label: '✨ ${strings.filterFamousSurahs}',
                          isSelected: _selectedFilter == _SurahFilter.famous,
                          onTap: () => setState(() => _selectedFilter = _SurahFilter.famous),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Ana İçerik Görünümü ────────────────────────────────────────
              Expanded(
                child: allSurahsAsync.when(
                  loading: () => app_widgets.LoadingWidget(message: strings.versesLoading),
                  error: (e, _) => app_widgets.AppErrorWidget(
                    message: strings.versesLoadError,
                    onRetry: () => ref.invalidate(allSurahsProvider),
                  ),
                  data: (surahs) {
                    // Arama Yapılıyorsa
                    if (isSearching) {
                      return _buildSearchResultsView(
                        query: searchQuery,
                        allSurahs: surahs,
                        strings: strings,
                        isDark: isDark,
                      );
                    }

                    // Sekmeye Göre Gösterim
                    switch (_selectedTab) {
                      case _QuranTab.surahs:
                        return _buildSurahsListView(
                          allSurahs: surahs,
                          filter: _selectedFilter,
                          strings: strings,
                          isDark: isDark,
                        );
                      case _QuranTab.juzs:
                        return _buildJuzsGridView(
                          allSurahs: surahs,
                          strings: strings,
                          isDark: isDark,
                        );
                      case _QuranTab.versesAndDuas:
                        return _buildFeaturedVersesAndDuasView(
                          allSurahs: surahs,
                          strings: strings,
                          isDark: isDark,
                        );
                      case _QuranTab.favorites:
                        return _buildFavoritesView(
                          allSurahs: surahs,
                          strings: strings,
                          isDark: isDark,
                        );
                    }
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

  Widget _buildCategoryTabButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? BeyanColors.tone(0xFF0F3E34) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? BeyanColors.tone(0xFFFFDF7A)
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: isActive
                      ? (isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF012E2B))
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? BeyanColors.tone(0xFFD4AF37)
              : (isDark ? BeyanColors.tone(0xFF082621) : BeyanColors.tone(0xFFF1F6F4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? BeyanColors.tone(0xFFFFDF7A)
                : BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.black87
                : (isDark ? Colors.white70 : BeyanColors.tone(0xFF033E35)),
          ),
        ),
      ),
    );
  }

  // ── Sureler Listesi (Ultra Hızlı 120 FPS - itemExtent Optimize) ─────────────
  Widget _buildSurahsListView({
    required List<Surah> allSurahs,
    required _SurahFilter filter,
    required AppStrings strings,
    required bool isDark,
  }) {
    final filtered = allSurahs.where((s) {
      switch (filter) {
        case _SurahFilter.all:
          return true;
        case _SurahFilter.meccan:
          return s.isMeccan;
        case _SurahFilter.medinan:
          return !s.isMeccan;
        case _SurahFilter.famous:
          return _famousSurahIds.contains(s.id);
      }
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90, top: 2),
      physics: const BouncingScrollPhysics(),
      itemExtent: 74.0,
      scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
      addRepaintBoundaries: true,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final surah = filtered[index];
        return SurahListItem(
          surah: surah,
          langCode: strings.language.code,
          onTap: () => _openSurahAtVerse(surah, 1),
        );
      },
    );
  }

  // ── 30 Cüz Vitrini ──────────────────────────────────────────────────────────
  Widget _buildJuzsGridView({
    required List<Surah> allSurahs,
    required AppStrings strings,
    required bool isDark,
  }) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      itemCount: quranJuzList.length,
      itemBuilder: (context, index) {
        final juz = quranJuzList[index];
        final matchingSurah = allSurahs.firstWhere(
          (s) => s.nameTurkish.toLowerCase().contains(juz.startSurah.toLowerCase()) ||
                 juz.startSurah.toLowerCase().contains(s.nameTurkish.toLowerCase()),
          orElse: () => allSurahs.isNotEmpty ? allSurahs.first : const Surah(
            id: 1,
            nameArabic: 'الفاتحة',
            nameTurkish: 'Fâtiha',
            nameEnglish: 'Al-Fatiha',
            revelationType: 'meccan',
            verseCount: 7,
          ),
        );

        return RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? BeyanColors.tone(0xFF0D2823) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDark ? BeyanColors.tone(0xFF133B34) : BeyanColors.tone(0xFFE5ECE9),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => _openSurahAtVerse(matchingSurah, juz.startAyah),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Cüz Numarası Rozeti
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              strings.juzLabel,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: BeyanColors.tone(0xFFD4AF37),
                              ),
                            ),
                            Text(
                              '${juz.juzNumber}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF012E2B),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Cüz Bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${juz.juzNumber}. ${strings.juzLabel} • ${juz.startSurah}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : BeyanColors.tone(0xFF02362E),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${strings.pageRangeLabel} ${juz.startPage} - ${juz.endPage} • ${juz.pageCount} ${strings.pageRangeLabel}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Başlangıç Ayeti ve Oku Butonu
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${juz.startAyah}. Âyet',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: BeyanColors.tone(0xFFD4AF37),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: BeyanColors.tone(0xFFD4AF37),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Önemli Âyet & Dualar Vitrini ──────────────────────────────────────────
  Widget _buildFeaturedVersesAndDuasView({
    required List<Surah> allSurahs,
    required AppStrings strings,
    required bool isDark,
  }) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        // ── Dua Kütüphanesi Tanıtım ve Doğrudan Geçiş Kartı ──────────────
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.push(
              context,
              LuxuryPageRoute(page: const DuaLibraryScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [BeyanColors.tone(0xFF0D372E), BeyanColors.tone(0xFF06221D)]
                    : [BeyanColors.tone(0xFFE2EFE9), BeyanColors.tone(0xFFF3F8F5)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: BeyanColors.tone(0xFFFFDF7A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.openDuaLibrary,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF012E2B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Peygamber duaları, şifa, nazar, namaz, sabah-akşam külliyatı',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: BeyanColors.tone(0xFFD4AF37),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── 13 Meşhur Âyet ve Kur'an Duası Kartları ─────────────────────────
        ...featuredQuranicVersesList.map((verse) {
          final targetSurah = allSurahs.firstWhere(
            (s) => s.id == verse.surahId,
            orElse: () => allSurahs.isNotEmpty ? allSurahs.first : const Surah(
              id: 2,
              nameArabic: 'البقرة',
              nameTurkish: 'Bakara',
              nameEnglish: 'Al-Baqarah',
              revelationType: 'medinan',
              verseCount: 286,
            ),
          );

          return _buildFeaturedVerseCard(
            verse: verse,
            surah: targetSurah,
            strings: strings,
            isDark: isDark,
          );
        }),
      ],
    );
  }

  Widget _buildFeaturedVerseCard({
    required QuranFeaturedVerse verse,
    required Surah surah,
    required AppStrings strings,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF0D2823) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? BeyanColors.tone(0xFF133B34) : BeyanColors.tone(0xFFE5ECE9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openSurahAtVerse(surah, verse.verseNumber),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${verse.surahName} ${verse.verseRange}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: BeyanColors.tone(0xFFD4AF37),
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _openSurahAtVerse(surah, verse.verseNumber),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: Icon(Icons.menu_book_rounded, size: 14, color: BeyanColors.tone(0xFFD4AF37)),
                      label: Text(
                        strings.readInSurah,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: BeyanColors.tone(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  verse.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : BeyanColors.tone(0xFF02362E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  verse.subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? BeyanColors.tone(0xFF071F1B) : BeyanColors.tone(0xFFF7FAF9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    verse.arabicSnippet,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15,
                      color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF02362E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  verse.turkishMeaning,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.3,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Akıllı Arama Sonuçları Görünümü ────────────────────────────────────────
  Widget _buildSearchResultsView({
    required String query,
    required List<Surah> allSurahs,
    required AppStrings strings,
    required bool isDark,
  }) {
    final normQuery = QuranFeaturedVerse.normalize(query);

    // 1. Eşleşen Sureler
    final matchedSurahs = allSurahs.where((s) {
      if (normQuery.isEmpty) return true;
      final t = QuranFeaturedVerse.normalize(s.nameTurkish);
      final e = QuranFeaturedVerse.normalize(s.nameEnglish);
      final idStr = s.id.toString();
      return t.contains(normQuery) || e.contains(normQuery) || s.nameArabic.contains(query) || idStr == query;
    }).toList();

    // 2. Eşleşen Önemli Âyet & Dualar (örn: 'aye' -> Âyetü'l-Kürsî!)
    final matchedVerses = featuredQuranicVersesList.where((v) => v.matchesQuery(query)).toList();

    // 3. Eşleşen Tematik Kur'an Kavramları (örn: 'sabır', 'şifa', 'rızık', 'aile')
    final matchedTopics = quranThematicTopicsList.where((t) => t.matchesQuery(query)).toList();

    if (matchedSurahs.isEmpty && matchedVerses.isEmpty && matchedTopics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off_rounded, size: 52, color: AppColors.textHint),
              const SizedBox(height: 12),
              Text(
                strings.noSurahFound,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Aradığınız dua veya ayet Kur\'an kütüphanesinde bulunamadıysa Dua Kütüphanesi\'nde arayabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openDuaLibraryWithQuery(query),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BeyanColors.tone(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: Text(
                  '${strings.searchInDuaLibrary} ("$query")',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
      children: [
        // ── Dua Kütüphanesinde Arama Hızlı Butonu ──────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dua Kütüphanesi\'nde "$query" ara (40+ Dua)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFD4AF37),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _openDuaLibraryWithQuery(query),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Aç', style: TextStyle(fontWeight: FontWeight.bold, color: BeyanColors.tone(0xFFD4AF37))),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: BeyanColors.tone(0xFFD4AF37)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Eşleşen Tematik Kur'an Kavramları & Yaşam Atlası ──────────
        if (matchedTopics.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.explore_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Tematik Kur\'an Atlası (${matchedTopics.length} Konu)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFFFDF7A),
                  ),
                ),
              ],
            ),
          ),
          for (final topic in matchedTopics)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? BeyanColors.tone(0xFF032620) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
                ),
              ),
              child: ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Color(topic.primaryColorHex).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(topic.icon, color: Color(topic.primaryColorHex), size: 18),
                ),
                title: Text(
                  topic.titleTr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  '${topic.verses.length} Âyet • ${topic.subtitleTr}',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: BeyanColors.tone(0xFFD4AF37)),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    LuxuryPageRoute(page: ThematicTopicDetailScreen(topic: topic)),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
        ],

        // ── Eşleşen Önemli Âyet & Dualar Bölümü ────────────────────────
        if (matchedVerses.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.stars_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${strings.foundVersesAndDuas} (${matchedVerses.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFFFDF7A),
                  ),
                ),
              ],
            ),
          ),
          ...matchedVerses.map((verse) {
            final targetSurah = allSurahs.firstWhere(
              (s) => s.id == verse.surahId,
              orElse: () => allSurahs.isNotEmpty ? allSurahs.first : const Surah(
                id: 2,
                nameArabic: 'البقرة',
                nameTurkish: 'Bakara',
                nameEnglish: 'Al-Baqarah',
                revelationType: 'medinan',
                verseCount: 286,
              ),
            );
            return _buildFeaturedVerseCard(
              verse: verse,
              surah: targetSurah,
              strings: strings,
              isDark: isDark,
            );
          }),
          const SizedBox(height: 10),
        ],

        // ── Eşleşen Sureler Bölümü ────────────────────────────────────
        if (matchedSurahs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(Icons.format_list_bulleted_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${strings.foundSurahs} (${matchedSurahs.length})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : BeyanColors.tone(0xFF02362E),
                  ),
                ),
              ],
            ),
          ),
          ...matchedSurahs.map((surah) {
            return SurahListItem(
              surah: surah,
              langCode: strings.language.code,
              onTap: () => _openSurahAtVerse(surah, 1),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildFavoritesView({
    required List<Surah> allSurahs,
    required AppStrings strings,
    required bool isDark,
  }) {
    final favoriteSurahIds = ref.watch(favoriteSurahsProvider);
    final bookmarkedKeys = ref.watch(bookmarkedVersesProvider);

    final favoriteSurahs = allSurahs.where((s) => favoriteSurahIds.contains(s.id)).toList();
    final sortedBookmarks = bookmarkedKeys.toList()..sort();

    final isEmpty = favoriteSurahs.isEmpty && sortedBookmarks.isEmpty;

    if (isEmpty) {
      return _buildQuranFavoritesEmptyState(isDark: isDark, strings: strings);
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // ── Favori Sureler Bölümü ───────────────────────────────────
        if (favoriteSurahs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
                const SizedBox(width: 8),
                Text(
                  strings.language == AppLanguage.turkish
                      ? 'Favori Sureler (${favoriteSurahs.length})'
                      : 'Favorite Surahs (${favoriteSurahs.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFFFDF7A),
                  ),
                ),
              ],
            ),
          ),
          ...favoriteSurahs.map((surah) {
            return SurahListItem(
              surah: surah,
              langCode: strings.language.code,
              onTap: () => _openSurahAtVerse(surah, 1),
            );
          }),
          const SizedBox(height: 16),
        ],

        // ── Kaydedilen Ayetler Bölümü ────────────────────────────────
        if (sortedBookmarks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
            child: Row(
              children: [
                Icon(Icons.bookmark_added_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 18),
                const SizedBox(width: 8),
                Text(
                  strings.language == AppLanguage.turkish
                      ? 'Kaydedilen Âyetler (${sortedBookmarks.length})'
                      : 'Bookmarked Verses (${sortedBookmarks.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : BeyanColors.tone(0xFF012E2B),
                  ),
                ),
              ],
            ),
          ),
          ...sortedBookmarks.map((key) {
            final parts = key.split(':');
            final sId = int.tryParse(parts.first) ?? 1;
            final vNum = int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1;

            final targetSurah = allSurahs.firstWhere(
              (s) => s.id == sId,
              orElse: () => allSurahs.isNotEmpty ? allSurahs.first : const Surah(
                id: 1,
                nameArabic: 'الفاتحة',
                nameTurkish: 'Fâtiha',
                nameEnglish: 'Al-Fatiha',
                revelationType: 'meccan',
                verseCount: 7,
              ),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? BeyanColors.tone(0xFF082621) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openSurahAtVerse(targetSurah, vNum),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$vNum',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF033E35),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${targetSurah.localizedName(strings.language.code)} • ${strings.verseNumberLabel(vNum)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : BeyanColors.tone(0xFF02362E),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${targetSurah.localizedRevelation(strings.language.code)} • ${targetSurah.localizedVerseCount(strings.language.code)}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.star_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 22),
                          tooltip: strings.removeBookmark,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            ref.read(bookmarkedVersesProvider.notifier).toggleBookmark(sId, vNum);
                          },
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: BeyanColors.tone(0xFFD4AF37),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildQuranFavoritesEmptyState({
    required bool isDark,
    required AppStrings strings,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.15 : 0.1),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.star_rounded,
                color: BeyanColors.tone(0xFFFFDF7A),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.language == AppLanguage.turkish ? 'Henüz Favori Âyet veya Sure Yok' : 'No Favorite Verses Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : BeyanColors.tone(0xFF012E2B),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.language == AppLanguage.turkish
                  ? 'Kur\'an-ı Kerim okurken ayetlerin yanındaki veya sure başlığındaki yıldız simgesine dokunarak favorilerinize ekleyebilirsiniz.'
                  : 'While reading the Holy Quran, tap the star icon next to any verse or surah header to save your favorites here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedTab = _QuranTab.surahs);
              },
              icon: Icon(Icons.auto_stories_rounded, size: 18, color: BeyanColors.tone(0xFF012E2B)),
              label: Text(
                strings.language == AppLanguage.turkish ? 'Sureleri Keşfet' : 'Explore Surahs',
                style: TextStyle(fontWeight: FontWeight.bold, color: BeyanColors.tone(0xFF012E2B)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BeyanColors.tone(0xFFFFDF7A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
