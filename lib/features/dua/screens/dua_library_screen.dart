import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../monetization/widgets/banner_ad_widget.dart';
import '../models/dua_model.dart';
import '../providers/dua_providers.dart';

/// Beyân - Dua Kütüphanesi Ekranı
/// 10 Kategorili Doğrulanmış Hadis ve Kur'an Duaları Külliyatı
class DuaLibraryScreen extends ConsumerStatefulWidget {
  const DuaLibraryScreen({super.key});

  @override
  ConsumerState<DuaLibraryScreen> createState() => _DuaLibraryScreenState();
}

class _DuaLibraryScreenState extends ConsumerState<DuaLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Dua Kütüphanesi',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              selectedCategory == null ? Icons.filter_alt_outlined : Icons.filter_alt,
              color: const Color(0xFFFFDF7A),
            ),
            tooltip: 'Kategori Filtresi',
            onPressed: () {
              if (selectedCategory != null) {
                ref.read(selectedDuaCategoryProvider.notifier).state = null;
              }
            },
          ),
        ],
      ),
      body: Column(
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
                  hintText: 'Dua, anlam veya kaynak ara...',
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
                  setState(() {});
                },
              ),
            ),
          ),

          // ── Kategori Çipleri (Yatay Kaydırılabilir) ────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCategoryChip(
                  label: 'Tümü (${duas.length})',
                  isSelected: selectedCategory == null,
                  onTap: () => ref.read(selectedDuaCategoryProvider.notifier).state = null,
                  isDark: isDark,
                ),
                ...DuaCategory.values.map((cat) {
                  return _buildCategoryChip(
                    label: cat.localizedName(strings.language.code),
                    isSelected: selectedCategory == cat,
                    onTap: () => ref.read(selectedDuaCategoryProvider.notifier).state = cat,
                    isDark: isDark,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── Dua Kartları Listesi ──────────────────────────────────────
          Expanded(
            child: duas.isEmpty
                ? Center(
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
                          'Aramanıza uygun dua bulunamadı',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: duas.length,
                    itemBuilder: (context, index) {
                      final dua = duas[index];
                      return _DuaCardItem(dua: dua, isDark: isDark);
                    },
                  ),
          ),

          // Alt banner reklam
          const BannerAdWidget(),
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
}

class _DuaCardItem extends ConsumerWidget {
  final DuaItem dua;
  final bool isDark;

  const _DuaCardItem({required this.dua, required this.isDark});

  void _copyDua(BuildContext context) {
    HapticFeedback.mediumImpact();
    final text = '${dua.title}\n\n'
        '${dua.arabicText}\n\n'
        'Okunuşu: ${dua.transliteration}\n\n'
        'Anlamı: ${dua.turkishMeaning}\n\n'
        'Kaynak: ${dua.reference}\n\n'
        '— Beyân İslami Yaşam Uygulaması';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A), size: 20),
            SizedBox(width: 8),
            Text('Dua panoya kopyalandı'),
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
    return Container(
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
                  child: Text(
                    dua.category.trName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
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
                  tooltip: dua.isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(favoriteDuasProvider.notifier).toggleFavorite(dua.id);
                  },
                ),
                // Kopyala butonu
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                  tooltip: 'Kopyala & Paylaş',
                  onPressed: () => _copyDua(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Başlık
            Text(
              dua.title,
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
              dua.turkishMeaning,
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
                    dua.reference,
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
    );
  }
}
