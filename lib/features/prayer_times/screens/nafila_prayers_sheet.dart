import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/core/utils/navigator_guard.dart';
import '../../../core/localization/app_strings.dart';
import '../models/nafila_prayer_model.dart';
import '../services/nafila_prayers_data.dart';

/// Önemli & Nafile Namazlar Rehberi Bottom Sheet (Teveccüh, Teheccüd, Kuşluk, vb.)
class NafilaPrayersSheet extends ConsumerStatefulWidget {
  final String? initialPrayerId;

  const NafilaPrayersSheet({
    super.key,
    this.initialPrayerId,
  });

  static void show(BuildContext context, [String? initialPrayerId]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => NafilaPrayersSheet(initialPrayerId: initialPrayerId),
    );
  }

  @override
  ConsumerState<NafilaPrayersSheet> createState() => _NafilaPrayersSheetState();
}

class _NafilaPrayersSheetState extends ConsumerState<NafilaPrayersSheet> {
  final TextEditingController _searchController = TextEditingController();
  NafilaCategory? _selectedCategory;
  String _searchQuery = '';
  NafilaPrayer? _selectedDetailPrayer;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrayerId != null) {
      _selectedDetailPrayer = NafilaPrayersData.getPrayerById(widget.initialPrayerId!);
    }
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
    final gold = BeyanColors.tone(0xFFFFDF7A);
    final goldMuted = BeyanColors.tone(0xFFD4AF37);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF02211C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: goldMuted, width: 1.8),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: _selectedDetailPrayer != null
            ? _buildDetailView(context, _selectedDetailPrayer!, strings, isDark, gold)
            : _buildListView(context, strings, isDark, gold),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LİSTE GÖRÜNÜMÜ
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildListView(
    BuildContext context,
    AppStrings strings,
    bool isDark,
    Color gold,
  ) {
    final allPrayers = NafilaPrayersData.getAllPrayers();
    final filtered = allPrayers.where((p) {
      final matchesCat = _selectedCategory == null || p.category == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.shortSummary.toLowerCase().contains(q) ||
          p.conditions.toLowerCase().contains(q) ||
          p.timing.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sürükleme Tutamağı
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! > 6) {
              BeyanNavigatorGuard.safePopOnDrag(context);
            }
          },
          onTap: () => BeyanNavigatorGuard.safePop(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),
        ),

        // Üst Başlık Barı
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [BeyanColors.tone(0xFF005A4C), BeyanColors.tone(0xFF00241E)],
                  ),
                  border: Border.all(color: gold.withValues(alpha: 0.6), width: 1.2),
                ),
                child: Center(
                  child: Icon(Icons.stars_rounded, color: gold, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Önemli & Nafile Namazlar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Teveccüh, Teheccüd, Kuşluk & 15 Sünnet Namazı',
                      style: TextStyle(
                        color: gold.withValues(alpha: 0.85),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => BeyanNavigatorGuard.safePop(context),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Arama Çubuğu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Namaz ara (Teveccüh, Teheccüd, Kuşluk, Hacet...)',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: gold, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: gold.withValues(alpha: 0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: gold, width: 1.2),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),

        const SizedBox(height: 10),

        // Kategori Filtre Butonları
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(
                label: 'Tümü (${allPrayers.length})',
                isSelected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
                gold: gold,
              ),
              ...NafilaCategory.values.map((cat) {
                return _buildCategoryChip(
                  label: cat.localizedName(strings.language),
                  isSelected: _selectedCategory == cat,
                  onTap: () => setState(() => _selectedCategory = cat),
                  gold: gold,
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 10),
        const Divider(color: Colors.white12, height: 1),

        // Namaz Kartları Listesi
        Flexible(
          child: filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, color: gold.withValues(alpha: 0.6), size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Aramanızla eşleşen namaz bulunamadı.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildPrayerSummaryCard(item, gold, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color gold,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? gold : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? gold : Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? BeyanColors.tone(0xFF01201B) : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerSummaryCard(NafilaPrayer prayer, Color gold, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: prayer.isFeatured
            ? BeyanColors.tone(0xFF03382E)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: prayer.isFeatured
              ? gold.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.08),
          width: prayer.isFeatured ? 1.4 : 1,
        ),
        boxShadow: prayer.isFeatured
            ? [
                BoxShadow(
                  color: gold.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedDetailPrayer = prayer;
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: prayer.isFeatured ? 0.22 : 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: gold.withValues(alpha: 0.4), width: 1),
                      ),
                      child: Icon(
                        prayer.id == 'teveccuh'
                            ? Icons.favorite_rounded
                            : (prayer.id == 'teheccud' ? Icons.nightlight_round : Icons.self_improvement_rounded),
                        color: gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                prayer.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (prayer.isFeatured) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: gold,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    prayer.id == 'teveccuh' ? 'ÖZEL HUZUR ✨' : 'ÖNE ÇIKAN ⭐',
                                    style: TextStyle(
                                      color: BeyanColors.tone(0xFF01201B),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            prayer.arabicTitle,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              color: gold.withValues(alpha: 0.8),
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: gold, size: 24),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  prayer.shortSummary,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                if (prayer.rewards.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: gold.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, color: gold, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          '${prayer.rewards.length} Müjde ve İlahi Sevap Detaylı',
                          style: TextStyle(
                            color: gold,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.repeat_rounded, color: gold, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            prayer.rakats,
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.access_time_rounded, color: gold, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                prayer.timing,
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // DETAY GÖRÜNÜMÜ (Şartlar, Faziletler, Adımlar, Dualar)
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildDetailView(
    BuildContext context,
    NafilaPrayer prayer,
    AppStrings strings,
    bool isDark,
    Color gold,
  ) {
    return Column(
      children: [
        // Sürükleme Tutamağı
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta != null && details.primaryDelta! > 6) {
              BeyanNavigatorGuard.safePopOnDrag(context);
            }
          },
          onTap: () => BeyanNavigatorGuard.safePop(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),
        ),

        // Üst Navigasyon Barı (Geri Butonu + Başlık + Kapat)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedDetailPrayer = null);
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayer.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      prayer.arabicTitle,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: gold.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => BeyanNavigatorGuard.safePop(context),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),

        // Detay İçerik Listesi (Kaydırılabilir)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── 1. Niyet & Rekat Rozeti ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BeyanColors.tone(0xFF034A3E), BeyanColors.tone(0xFF012922)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: gold.withValues(alpha: 0.45), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bookmark_added_rounded, color: gold, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Kılınış Niyeti',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: gold.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            prayer.rakats,
                            style: TextStyle(color: gold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '«${prayer.niyyah}»',
                      style: TextStyle(
                        color: gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 2. Vakti (Ne Zaman Kılınır?) ──
              _buildDetailSection(
                icon: Icons.access_time_filled_rounded,
                title: 'Ne Zaman Kılınır? (Vakti)',
                content: prayer.timing,
                gold: gold,
              ),

              const SizedBox(height: 16),

              // ── 3. Şartları ve Edepleri ──
              _buildDetailSection(
                icon: Icons.checklist_rounded,
                title: 'Kılınma Şartları & Edepleri',
                content: prayer.conditions,
                gold: gold,
                accentBorder: true,
              ),

              const SizedBox(height: 16),

              // ── 4. Fazileti & Manevi Hikmeti ──
              _buildDetailSection(
                icon: Icons.auto_awesome_rounded,
                title: 'Fazileti ve Hikmeti',
                content: prayer.virtues,
                gold: gold,
              ),

              // ── 5. Kazandırdığı Sevaplar & İlahi Müjdeler ──
              if (prayer.rewards.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildRewardsSection(prayer.rewards, gold),
              ],

              if (prayer.recommendedSurahs.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildBulletListSection(
                  icon: Icons.menu_book_rounded,
                  title: 'Tavsiye Edilen Sûreler',
                  items: prayer.recommendedSurahs,
                  gold: gold,
                ),
              ],

              const SizedBox(height: 20),

              // ── 5. Adım Adım Kılınışı ──
              Row(
                children: [
                  Icon(Icons.format_list_numbered_rounded, color: gold, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Adım Adım Kılınışı',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...prayer.steps.asMap().entries.map((e) => _buildStepCard(e.key + 1, e.value, gold)),

              // ── 6. Özel Dualar & Münacatlar ──
              if (prayer.specialDuas.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: gold, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Bu Namaza Özel Dua ve İstiğfarlar',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...prayer.specialDuas.map((d) => _buildSpecialDuaCard(d, gold, context)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    required Color gold,
    bool accentBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentBorder ? gold.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
          width: accentBorder ? 1.2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletListSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color gold,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: gold, fontSize: 14, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(List<String> rewards, Color gold) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BeyanColors.tone(0xFF033F34),
            BeyanColors.tone(0xFF01241E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: gold.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.workspace_premium_rounded, color: gold, size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Kazandırdığı Sevaplar & İlahi Müjdeler',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rewards.asMap().entries.map((entry) {
            final index = entry.key;
            final reward = entry.value;
            final parts = reward.split(': ');
            final title = parts.isNotEmpty ? parts[0] : '';
            final body = parts.length > 1 ? parts.sublist(1).join(': ') : '';

            return Padding(
              padding: EdgeInsets.only(bottom: index == rewards.length - 1 ? 0 : 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2, right: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: gold.withValues(alpha: 0.4), width: 0.8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: gold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          if (title.isNotEmpty) ...[
                            TextSpan(
                              text: '$title: ',
                              style: TextStyle(
                                color: gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                          TextSpan(
                            text: body.isNotEmpty ? body : reward,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.5,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepCard(int stepNum, NafilaStep step, Color gold) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold,
                ),
                child: Center(
                  child: Text(
                    '$stepNum',
                    style: TextStyle(color: BeyanColors.tone(0xFF01201B), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5, height: 1.4),
          ),
          if (step.recitationArabic != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    step.recitationArabic!,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: gold,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  if (step.recitationTranslit != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.recitationTranslit!,
                      style: const TextStyle(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic),
                    ),
                  ],
                  if (step.recitationMeaning != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.recitationMeaning!,
                      style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialDuaCard(NafilaSpecialDua dua, Color gold, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF012E26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gold.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dua.title,
                  style: TextStyle(color: gold, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                tooltip: 'Duayı Kopyala',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(
                    text: '${dua.title}\n\n${dua.arabic}\n\n${dua.transliteration}\n\nAnlamı: ${dua.meaning}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Dua panoya kopyalandı.'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: BeyanColors.tone(0xFF033E35),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dua.arabic,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 17,
              color: gold,
              height: 1.6,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            dua.transliteration,
            style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontStyle: FontStyle.italic, height: 1.35),
          ),
          const SizedBox(height: 6),
          Text(
            'Anlamı: ${dua.meaning}',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65), height: 1.35),
          ),
          if (dua.note != null) ...[
            const SizedBox(height: 6),
            Text(
              'Not: ${dua.note}',
              style: TextStyle(fontSize: 11, color: gold.withValues(alpha: 0.8), fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
