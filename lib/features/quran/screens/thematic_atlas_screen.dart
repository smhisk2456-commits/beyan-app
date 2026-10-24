import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/beyan_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/luxury_page_route.dart';
import '../models/quran_thematic_topic.dart';
import '../widgets/quran_audio_player_bar.dart';
import 'thematic_topic_detail_screen.dart';

/// Tematik Kur'an Fihristi ve Kavram Atlası Ana Ekranı
class ThematicAtlasScreen extends ConsumerStatefulWidget {
  const ThematicAtlasScreen({super.key});

  @override
  ConsumerState<ThematicAtlasScreen> createState() => _ThematicAtlasScreenState();
}

class _ThematicAtlasScreenState extends ConsumerState<ThematicAtlasScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);
    final query = _searchController.text.trim();

    // Filtreleme
    final filteredTopics = quranThematicTopicsList.where((topic) {
      if (_selectedCategory != 'all' && topic.category != _selectedCategory) {
        return false;
      }
      if (query.isNotEmpty && !topic.matchesQuery(query)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          tooltip: strings.language == AppLanguage.turkish ? 'Geri Dön' : 'Back',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
        ),
        title: Column(
          children: [
            Text(
              strings.language == AppLanguage.turkish
                  ? 'Tematik Kur\'an Fihristi'
                  : 'Thematic Quran Atlas',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.2),
            ),
            Text(
              strings.language == AppLanguage.turkish
                  ? 'Kavram & Yaşam Atlası'
                  : 'Concepts & Life Guidance',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: BeyanColors.tone(0xFFFFDF7A),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Arama Çubuğu ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
                      onChanged: (q) => setState(() {}),
                      style: TextStyle(fontSize: 14.5, color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: strings.language == AppLanguage.turkish
                            ? 'Konu, kavram veya âyet ara (örn: Sabır, Şifa, Rızık)...'
                            : 'Search concept (e.g. Patience, Healing, Sustenance)...',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 20),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Kategori Filtre Çipleri ───────────────────────────────────
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: strings.language == AppLanguage.turkish ? 'Tümü (${quranThematicTopicsList.length})' : 'All',
                        categoryKey: 'all',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings.language == AppLanguage.turkish ? 'Zor Zamanlar & Şifa' : 'Hardship & Healing',
                        categoryKey: 'zorluk_sifa',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings.language == AppLanguage.turkish ? 'Ahlak & Aile' : 'Ethics & Family',
                        categoryKey: 'ahlak_aile',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings.language == AppLanguage.turkish ? 'İbadet & Ahiret' : 'Worship & Hereafter',
                        categoryKey: 'ibadet_ahiret',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: strings.language == AppLanguage.turkish ? 'İlim & Tefekkür' : 'Knowledge & Reason',
                        categoryKey: 'ilim_tefekkur',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Konu Kartları Listesi ─────────────────────────────────────
              if (filteredTopics.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: BeyanColors.tone(0xFFD4AF37)),
                          const SizedBox(height: 12),
                          Text(
                            strings.language == AppLanguage.turkish
                                ? 'Aradığınız kritere uygun kavram bulunamadı.'
                                : 'No concept found matching your search.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final topic = filteredTopics[index];
                        return _buildTopicCard(
                          context: context,
                          topic: topic,
                          isDark: isDark,
                          strings: strings,
                        );
                      },
                      childCount: filteredTopics.length,
                    ),
                  ),
                ),
            ],
          ),

          // Alt Mini Tilavet Barı
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: QuranAudioPlayerBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String categoryKey,
    required bool isDark,
  }) {
    final isSelected = _selectedCategory == categoryKey;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCategory = categoryKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? BeyanColors.tone(0xFFD4AF37)
              : (isDark ? BeyanColors.tone(0xFF04201A) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? BeyanColors.tone(0xFFFFDF7A)
                : BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? BeyanColors.tone(0xFF01201B)
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required BuildContext context,
    required QuranThematicTopic topic,
    required bool isDark,
    required AppStrings strings,
  }) {
    final topicColor = Color(topic.primaryColorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF04201A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.22),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            LuxuryPageRoute(
              page: ThematicTopicDetailScreen(topic: topic),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // İkon Kutusu
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: topicColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: topicColor.withValues(alpha: 0.4), width: 1.2),
                    ),
                    child: Icon(topic.icon, color: topicColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Başlık ve Âyet Sayısı
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                topic.titleTr,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: topicColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: topicColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '${topic.verses.length} Âyet',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: topicColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topic.subtitleTr,
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.3,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.7),
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Âyet Önizleme Etiketleri
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    for (int i = 0; i < topic.verses.length; i++) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${topic.verses[i].surahNameTr} • ${topic.verses[i].verseNumber}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : const Color(0xFF475569),
                          ),
                        ),
                      ),
                      if (i < topic.verses.length - 1) const SizedBox(width: 5),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
