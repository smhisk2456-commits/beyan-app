import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../../quran/services/quran_audio_service.dart';
import '../../quran/widgets/quran_audio_player_bar.dart';
import '../data/verified_duas_data.dart';
import '../models/dua_model.dart';
import '../providers/dua_providers.dart';

enum _DuaTab { categories, list, favorites }

/// Beyân - Dua Kütüphanesi Ekranı
/// 12 Kategorili Doğrulanmış Hadis ve Kur'an Duaları Külliyatı
class DuaLibraryScreen extends ConsumerStatefulWidget {
  const DuaLibraryScreen({super.key});

  @override
  ConsumerState<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends ConsumerState<DuaLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  _DuaTab _activeTab = _DuaTab.categories;

  static const _popularPills = [
    ('Âyetü\'l-Kürsî', '✨'),
    ('Nazar Duası', '🧿'),
    ('Sübhaneke', '🤲'),
    ('İnşirah', '🕊️'),
    ('Şifa Duası', '🌿'),
    ('Rabbi Yessir', '📖'),
    ('Ezan Duası', '🕌'),
    ('Tahiyyat', '📿'),
    ('Kunut', '✨'),
    ('Bereket', '💰'),
    ('Fâtiha', '🌟'),
    ('Lev Enzelnâ', '📜'),
  ];

  void _onQuickPillTap(String term) {
    HapticFeedback.lightImpact();
    if (_searchController.text.trim().toLowerCase() == term.toLowerCase()) {
      _searchController.clear();
      ref.read(duaSearchQueryProvider.notifier).state = '';
    } else {
      _searchController.text = term;
      ref.read(selectedDuaCategoryProvider.notifier).state = null;
      ref.read(duaSearchQueryProvider.notifier).state = term;
      _activeTab = _DuaTab.list;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(selectedDuaCategoryProvider);
    final duas = ref.watch(filteredDuasListProvider);
    final isSearching = _searchController.text.trim().isNotEmpty;
    final bottomAudioPadding = ref.watch(quranAudioProvider).currentSurahId != null ? 100.0 : 24.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          strings.duaLibraryTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              selectedCategory == null ? Icons.filter_alt_outlined : Icons.filter_alt,
              color: const Color(0xFFFFDF7A),
            ),
            tooltip: strings.duaFilterTooltip,
            onPressed: () {
              HapticFeedback.lightImpact();
              if (selectedCategory != null) {
                ref.read(selectedDuaCategoryProvider.notifier).state = null;
              } else {
                setState(() {
                  _activeTab = _DuaTab.categories;
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Arama Çubuğu ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF07201C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14.5,
                    ),
                    decoration: InputDecoration(
                      hintText: strings.duaSearchHint,
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFD4AF37),
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(duaSearchQueryProvider.notifier).state = '';
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (val) {
                      ref.read(duaSearchQueryProvider.notifier).state = val;
                      if (val.trim().isNotEmpty && _activeTab != _DuaTab.list) {
                        _activeTab = _DuaTab.list;
                      }
                      setState(() {});
                    },
                  ),
                ),
              ),

              // ── Hızlı Popüler Dualar Çubuğu ──────────────────────────────
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  children: _popularPills.map((pill) {
                    final isPillActive = _searchController.text.trim().toLowerCase() == pill.$1.toLowerCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => _onQuickPillTap(pill.$1),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPillActive
                                ? const Color(0xFFFFDF7A)
                                : (isDark
                                    ? const Color(0xFF0F3A32).withValues(alpha: 0.6)
                                    : const Color(0xFFE3EFEA)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isPillActive
                                  ? const Color(0xFFFFDF7A)
                                  : const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(pill.$2, style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                pill.$1,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isPillActive ? FontWeight.bold : FontWeight.w600,
                                  color: isPillActive
                                      ? const Color(0xFF012E2B)
                                      : (isDark ? const Color(0xFFFFDF7A) : const Color(0xFF07453B)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // ── Görünüm Modu Değiştirici (Kategoriler / Tüm Dualar) ────────
              if (!isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF06221D) : const Color(0xFFE9F3EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            label: '${strings.duaCategoriesTab} (12)',
                            icon: Icons.grid_view_rounded,
                            isActive: _activeTab == _DuaTab.categories && selectedCategory == null,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(selectedDuaCategoryProvider.notifier).state = null;
                              setState(() {
                                _activeTab = _DuaTab.categories;
                              });
                            },
                            isDark: isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            label: '${strings.allDuasTab} (${verifiedDuasList.length})',
                            icon: Icons.format_list_bulleted_rounded,
                            isActive: _activeTab == _DuaTab.list || selectedCategory != null,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _activeTab = _DuaTab.list;
                              });
                            },
                            isDark: isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            label: '${strings.language == AppLanguage.turkish ? 'Favorilerim' : 'Favorites'} (${duas.where((d) => d.isFavorite).length})',
                            icon: Icons.favorite_rounded,
                            isActive: _activeTab == _DuaTab.favorites,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ref.read(selectedDuaCategoryProvider.notifier).state = null;
                              setState(() {
                                _activeTab = _DuaTab.favorites;
                              });
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Kategori Çipleri (Yatay Kaydırma - Yalnızca Liste Modunda) ───
              if (_activeTab == _DuaTab.list || isSearching) ...[
                const SizedBox(height: 4),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildCategoryChip(
                        label: strings.allDuasWithCount(verifiedDuasList.length),
                        isSelected: selectedCategory == null,
                        onTap: () => ref.read(selectedDuaCategoryProvider.notifier).state = null,
                        isDark: isDark,
                      ),
                      ...DuaCategory.values.map((cat) {
                        final count = verifiedDuasList.where((d) => d.category == cat).length;
                        return _buildCategoryChip(
                          label: '${cat.localizedName(strings.language.code)} ($count)',
                          isSelected: selectedCategory == cat,
                          onTap: () => ref.read(selectedDuaCategoryProvider.notifier).state = cat,
                          isDark: isDark,
                        );
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 6),

              // ── Ana İçerik Alanı ──────────────────────────────────────────
              Expanded(
                child: _buildMainContent(
                  strings: strings,
                  isDark: isDark,
                  selectedCategory: selectedCategory,
                  duas: duas,
                  isSearching: isSearching,
                  bottomPadding: bottomAudioPadding,
                ),
              ),

              // Alt banner reklam (Tilavet çubuğu açık değilken görünür)
              if (ref.watch(quranAudioProvider).currentSurahId == null)
                const BannerAdWidget(),
            ],
          ),

          // Alt Mini Tilavet Oynatıcısı
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: QuranAudioPlayerBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? const Color(0xFF0F3E34) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? const Color(0xFFFFDF7A)
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? (isDark ? const Color(0xFFFFDF7A) : const Color(0xFF012E2B))
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({
    required AppStrings strings,
    required bool isDark,
    required DuaCategory? selectedCategory,
    required List<DuaItem> duas,
    required bool isSearching,
    required double bottomPadding,
  }) {
    // 1. Favoriler Görünümü
    if (_activeTab == _DuaTab.favorites && !isSearching) {
      final favoriteDuas = duas.where((d) => d.isFavorite).toList();
      if (favoriteDuas.isEmpty) {
        return _buildFavoritesEmptyState(isDark: isDark, strings: strings);
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
        addRepaintBoundaries: true,
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
        itemCount: favoriteDuas.length,
        itemBuilder: (context, index) {
          return _DuaCardItem(dua: favoriteDuas[index], isDark: isDark);
        },
      );
    }

    // 2. Kategoriler Grid Görünümü (Arama yokken ve Kategoriler sekmesi aktifken)
    if (_activeTab == _DuaTab.categories && !isSearching && selectedCategory == null) {
      return _buildCategoriesGrid(
        isDark: isDark,
        strings: strings,
        bottomPadding: bottomPadding,
        onSelectCategory: (cat) {
          HapticFeedback.mediumImpact();
          ref.read(selectedDuaCategoryProvider.notifier).state = cat;
          setState(() {
            _activeTab = _DuaTab.list;
          });
        },
      );
    }

    // 2. Arama sonucu boşsa
    if (duas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 54,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              strings.noDuaFound,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Tek bir kategori filtrelenmiş durumdaysa
    if (selectedCategory != null && !isSearching) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
        addRepaintBoundaries: true,
        padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
        children: [
          _buildSelectedCategoryBanner(
            category: selectedCategory,
            count: duas.length,
            isDark: isDark,
            strings: strings,
            onBackToCategories: () {
              HapticFeedback.lightImpact();
              ref.read(selectedDuaCategoryProvider.notifier).state = null;
              setState(() {
                _activeTab = _DuaTab.categories;
              });
            },
          ),
          ...duas.map((dua) => _DuaCardItem(dua: dua, isDark: isDark)),
        ],
      );
    }

    // 4. Arama yapılıyorsa (Düz arama sonuçları listesi)
    if (isSearching) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
        addRepaintBoundaries: true,
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
        itemCount: duas.length,
        itemBuilder: (context, index) {
          return _DuaCardItem(dua: duas[index], isDark: isDark);
        },
      );
    }

    // 5. Tüm Dualar Liste Görünümü (Kategorilere Göre Başlıklı & Gruplanmış)
    return ListView(
      physics: const BouncingScrollPhysics(),
      scrollCacheExtent: const ScrollCacheExtent.viewport(2.0),
      addRepaintBoundaries: true,
      padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPadding),
      children: [
        for (final cat in DuaCategory.values) ...[
          Builder(
            builder: (context) {
              final catDuas = duas.where((d) => d.category == cat).toList();
              if (catDuas.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySectionHeader(
                    category: cat,
                    count: catDuas.length,
                    isDark: isDark,
                    strings: strings,
                    onFocusCategory: () {
                      HapticFeedback.lightImpact();
                      ref.read(selectedDuaCategoryProvider.notifier).state = cat;
                    },
                  ),
                  ...catDuas.map((dua) => _DuaCardItem(dua: dua, isDark: isDark)),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCategoriesGrid({
    required bool isDark,
    required AppStrings strings,
    required double bottomPadding,
    required Function(DuaCategory) onSelectCategory,
  }) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.02,
      ),
      itemCount: DuaCategory.values.length,
      itemBuilder: (context, index) {
        final cat = DuaCategory.values[index];
        final count = verifiedDuasList.where((d) => d.category == cat).length;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelectCategory(cat),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF092922), const Color(0xFF051C17)]
                      : [Colors.white, const Color(0xFFF7FAF8)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          cat.icon,
                          size: 20,
                          color: const Color(0xFFFFDF7A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          strings.categoryDuaCount(count),
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    cat.localizedName(strings.language.code),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF033E35),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cat.localizedSubtitle(strings.language.code),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySectionHeader({
    required DuaCategory category,
    required int count,
    required bool isDark,
    required AppStrings strings,
    required VoidCallback onFocusCategory,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 14, 0, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D332B), const Color(0xFF06221D)]
              : [const Color(0xFFE4F0EB), const Color(0xFFF2F8F5)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Icon(
              category.icon,
              color: const Color(0xFFFFDF7A),
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.localizedName(strings.language.code),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF012E2B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        strings.categoryDuaCount(count),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  category.localizedSubtitle(strings.language.code),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onFocusCategory,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.language.code == 'tr' ? 'Tümü' : 'View',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Color(0xFFD4AF37),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCategoryBanner({
    required DuaCategory category,
    required int count,
    required bool isDark,
    required AppStrings strings,
    required VoidCallback onBackToCategories,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0D372E), const Color(0xFF07241F)]
              : [const Color(0xFFE3EFE9), const Color(0xFFF3F8F5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Icon(category.icon, color: const Color(0xFFFFDF7A), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.localizedName(strings.language.code),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF02362E),
                      ),
                    ),
                    Text(
                      strings.categoryDuaCount(count),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onBackToCategories,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 14, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 4),
                      Text(
                        strings.backToCategories,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.localizedSubtitle(strings.language.code),
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          HapticFeedback.selectionClick();
          onTap();
        },
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.black87
              : (isDark ? Colors.white70 : const Color(0xFF033E35)),
        ),
        backgroundColor: isDark ? const Color(0xFF072420) : const Color(0xFFF2F7F5),
        selectedColor: const Color(0xFFD4AF37),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFFFFDF7A)
                : const Color(0xFFD4AF37).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _buildFavoritesEmptyState({required bool isDark, required AppStrings strings}) {
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
                color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.15 : 0.1),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFFFDF7A),
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.language == AppLanguage.turkish ? 'Henüz Favori Duanız Yok' : 'No Favorite Duas Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF012E2B),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.language == AppLanguage.turkish
                  ? 'Gönlünüze ferahlık veren duaları kalp simgesine dokunarak buraya kaydedebilir, dilediğiniz an tek dokunuşla ulaşabilirsiniz.'
                  : 'Save duas that bring peace to your heart by tapping the heart icon, and access them anytime here.',
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
                setState(() => _activeTab = _DuaTab.categories);
              },
              icon: const Icon(Icons.auto_stories_rounded, size: 18, color: Color(0xFF012E2B)),
              label: Text(
                strings.language == AppLanguage.turkish ? 'Duaları Keşfet' : 'Explore Duas',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF012E2B)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDF7A),
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

class _DuaCardItem extends ConsumerWidget {
  final DuaItem dua;
  final bool isDark;

  const _DuaCardItem({required this.dua, required this.isDark});

  void _copyDua(BuildContext context, AppStrings strings) {
    HapticFeedback.mediumImpact();
    final text = '${dua.localizedTitle(strings.language.code)}\n\n'
        '${dua.arabicText}\n\n'
        '${strings.transliterationLabel}: ${dua.transliteration}\n\n'
        '${strings.meaningLabel}: ${dua.localizedMeaning(strings.language.code)}\n\n'
        '${strings.referenceLabel}: ${dua.localizedReference(strings.language.code)}\n\n'
        '${strings.appSignature}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A), size: 20),
            const SizedBox(width: 8),
            Text(strings.duaCopied),
          ],
        ),
        backgroundColor: const Color(0xFF012E2B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final linked = _getLinkedSurah(dua);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF06221D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Rozet & Başlık & Aksiyonlar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        dua.category.icon,
                        size: 13,
                        color: const Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        dua.category.localizedName(strings.language.code),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Favori butonu
                IconButton(
                  icon: Icon(
                    dua.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: dua.isFavorite ? Colors.redAccent : (isDark ? Colors.white60 : Colors.black45),
                    size: 22,
                  ),
                  tooltip: dua.isFavorite ? strings.removeFromFavorites : strings.addToFavorites,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(favoriteDuasProvider.notifier).toggleFavorite(dua.id);
                  },
                ),
                if (linked != null)
                  Consumer(
                    builder: (context, ref, _) {
                      final audioState = ref.watch(quranAudioProvider);
                      final isCurrent = audioState.currentSurahId == linked.id;
                      final isPlaying = isCurrent && audioState.isPlaying;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled_rounded
                                  : (isCurrent
                                      ? Icons.play_circle_filled_rounded
                                      : Icons.play_circle_outline_rounded),
                              color: isCurrent ? const Color(0xFFFFDF7A) : const Color(0xFFD4AF37),
                              size: 24,
                            ),
                            tooltip: isPlaying
                                ? strings.pauseRecitation
                                : (isCurrent
                                    ? strings.resumeRecitation
                                    : strings.listenSurahRecitation(linked.nameTurkish)),
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              if (isCurrent) {
                                ref.read(quranAudioProvider.notifier).togglePlayPause();
                              } else {
                                ref.read(quranAudioProvider.notifier).playSurah(linked.id, linked.nameTurkish);
                              }
                            },
                          ),
                          if (isCurrent)
                            IconButton(
                              icon: const Icon(
                                Icons.stop_circle_outlined,
                                color: Color(0xFFFF6B6B),
                                size: 22,
                              ),
                              tooltip: strings.stopRecitation,
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ref.read(quranAudioProvider.notifier).stop();
                              },
                            ),
                        ],
                      );
                    },
                  ),
                // Kopyala butonu
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  tooltip: strings.copyAndShare,
                  onPressed: () => _copyDua(context, strings),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Başlık
            Text(
              dua.localizedTitle(strings.language.code),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF033E35),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 12),

            // Arapça Metin (Amiri Fontu, RTL)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF021B17) : const Color(0xFFF7FAF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Text(
                dua.arabicText,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF012E2B),
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 10),

            // Okunuşu
            if (dua.transliteration.isNotEmpty) ...[
              Text(
                dua.transliteration,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Anlamı
            Text(
              dua.localizedMeaning(strings.language.code),
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF222222),
              ),
            ),

            // Fazilet / Açıklama
            if (dua.virtueExplanation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0B2D26)
                      : const Color(0xFFE8F2EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dua.virtueExplanation!,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white70 : const Color(0xFF033E35),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            // Kaynak
            Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  size: 14,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    dua.localizedReference(strings.language.code),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _LinkedSurahInfo {
  final int id;
  final String nameTurkish;
  const _LinkedSurahInfo(this.id, this.nameTurkish);
}

_LinkedSurahInfo? _getLinkedSurah(DuaItem dua) {
  switch (dua.id) {
    case 'kuran_fatiha':
      return const _LinkedSurahInfo(1, 'Fâtiha');
    case 'uyku_3': // Âyetü'l-Kürsî (Bakara 255)
    case 'kuran_ayetel_kursi':
    case 'aksam_3': // Âmenerresûlü (Bakara 285-286)
    case 'kuran_1': // Rabbena Âtina (Bakara 201)
      return const _LinkedSurahInfo(2, 'Bakara');
    case 'kuran_2': // Âl-i İmrân 8
    case 'peygamber_5': // Âl-i İmrân 38
      return const _LinkedSurahInfo(3, 'Âl-i İmrân');
    case 'peygamber_3': // A'râf 23
      return const _LinkedSurahInfo(7, 'A\'râf');
    case 'peygamber_4': // Yûsuf 101
      return const _LinkedSurahInfo(12, 'Yûsuf');
    case 'kuran_3': // İbrâhîm 41
    case 'kuran_5': // İbrâhîm 40
      return const _LinkedSurahInfo(14, 'İbrâhîm');
    case 'kuran_6': // Tâhâ 114
    case 'peygamber_1': // Tâhâ 25-28
      return const _LinkedSurahInfo(20, 'Tâhâ');
    case 'sikinti_1': // Enbiyâ 87 (Hz. Yûnus)
    case 'peygamber_2': // Enbiyâ 83 (Hz. Eyyûb)
      return const _LinkedSurahInfo(21, 'Enbiyâ');
    case 'kuran_4': // Furkân 74
      return const _LinkedSurahInfo(25, 'Furkân');
    case 'kuran_lev_enzelna': // Haşr 21-24
      return const _LinkedSurahInfo(59, 'Haşr');
    case 'kuran_insirah': // İnşirâh Suresi
      return const _LinkedSurahInfo(94, 'İnşirâh');
    case 'aksam_4': // İhlâs, Felak, Nas
      return const _LinkedSurahInfo(112, 'İhlâs');
    default:
      return null;
  }
}
