import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart' as app_widgets;
import '../models/surah.dart';
import '../models/verse.dart';
import '../providers/quran_providers.dart';
import '../widgets/arabic_text_widget.dart';
import '../widgets/verse_card_widget.dart';

/// Sure Detay Ekranı – Seçilen surenin tüm ayetlerini gösterir.
///
/// Özellikler:
/// - Üst: Sure adı (Arapça, Türkçe, İngilizce) + istatistikler
/// - Besmele şeridi (Tevbe Suresi hariç)
/// - Ayet listesi: Arapça (RTL, Amiri, büyük punto) +
///                 Türkçe okunuş (transliterasyon, italik) +
///                 Türkçe meal
/// - Sayfa kaydırma hafızası (ScrollController)
/// - Kopya ve paylaşım butonu (ayet uzun basışı)
class SurahDetailScreen extends ConsumerStatefulWidget {
  final Surah surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.offset > 400;
    if (show != _showScrollToTop) {
      setState(() => _showScrollToTop = show);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(versesBySurahProvider(widget.surah.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: versesAsync.when(
        loading: () => _buildLoadingScaffold(context),
        error: (e, _) => _buildErrorScaffold(context, e.toString()),
        data: (verses) => _buildContent(context, verses, isDark),
      ),
      // Yukarı kaydır FAB
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            )
          : null,
    );
  }

  // ── Yükleniyor ─────────────────────────────────────────────
  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surah.nameTurkish)),
      body: const app_widgets.LoadingWidget(message: 'Ayetler yükleniyor...'),
    );
  }

  // ── Hata ───────────────────────────────────────────────────
  Widget _buildErrorScaffold(BuildContext context, String error) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surah.nameTurkish)),
      body: app_widgets.AppErrorWidget(
        message: 'Ayetler yüklenemedi.\n$error',
        onRetry: () => ref.invalidate(versesBySurahProvider(widget.surah.id)),
      ),
    );
  }

  // ── Ana İçerik ─────────────────────────────────────────────
  Widget _buildContent(
    BuildContext context,
    List<Verse> verses,
    bool isDark,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Sure Başlığı AppBar ─────────────────────────────
        _SurahAppBar(surah: widget.surah, isDark: isDark),

        // ── Besmele (Tevbe Suresi hariç) ───────────────────
        if (widget.surah.id != 9 && widget.surah.id != 1)
          SliverToBoxAdapter(
            child: _BismillahCard(isDark: isDark),
          ),

        // ── Ayet Listesi ────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _VerseItem(
              verse: verses[index],
              onLongPress: () => _showVerseOptions(
                context,
                verses[index],
              ),
            ),
            childCount: verses.length,
          ),
        ),

        // Alt boşluk
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // ── Ayet Seçenekleri (Kopyala / Paylaş) ───────────────────
  void _showVerseOptions(BuildContext context, Verse verse) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _VerseOptionsSheet(verse: verse),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Sure Başlığı SliverAppBar
// ════════════════════════════════════════════════════════════════

class _SurahAppBar extends StatelessWidget {
  final Surah surah;
  final bool isDark;
  const _SurahAppBar({required this.surah, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.teal,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF00695C), const Color(0xFF0D1B2A)]
                  : [AppColors.tealDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Arapça sure adı – büyük, ortalı
                ArabicText(
                  surah.nameArabic,
                  fontSize: 38.0,
                  lineHeight: 1.6,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                // Türkçe + İngilizce isim
                Text(
                  '${surah.nameTurkish}  ·  ${surah.nameEnglish}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // İstatistik rozetleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBadge(
                      icon: Icons.format_list_numbered_rounded,
                      label: '${surah.id}. Sure',
                    ),
                    const SizedBox(width: 10),
                    _StatBadge(
                      icon: Icons.text_fields_rounded,
                      label: surah.verseCountLabel,
                    ),
                    const SizedBox(width: 10),
                    _StatBadge(
                      icon: Icons.place_rounded,
                      label: surah.revelationLabel,
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
}

/// İstatistik rozeti.
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Besmele Kartı
// ════════════════════════════════════════════════════════════════

class _BismillahCard extends StatelessWidget {
  final bool isDark;
  const _BismillahCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(isDark ? 0.15 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.teal.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Besmele Arapçası – Amiri, merkezi, geniş
          ArabicText.bismillah(
            color: isDark ? AppColors.arabicTextDark : AppColors.tealDark,
          ),
          const SizedBox(height: 6),
          // Türkçe okunuş
          Text(
            'Bismillâhirrahmânirrahîm',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF033E35),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Ayet Listesi Satırı
// ════════════════════════════════════════════════════════════════

class _VerseItem extends StatelessWidget {
  final Verse verse;
  final VoidCallback onLongPress;

  const _VerseItem({required this.verse, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: VerseCard(verse: verse),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Ayet İşlem BottomSheet
// ════════════════════════════════════════════════════════════════

class _VerseOptionsSheet extends StatelessWidget {
  final Verse verse;
  const _VerseOptionsSheet({required this.verse});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tutaç
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Ayet referansı başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '${verse.reference}. Ayet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const Divider(),

            // Arapça metni kopyala
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Arapça Metni Kopyala'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: verse.arabicText));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Arapça metin kopyalandı'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            // Meali kopyala
            ListTile(
              leading: const Icon(Icons.translate_rounded),
              title: const Text('Türkçe Meali Kopyala'),
              onTap: () {
                Clipboard.setData(
                  ClipboardData(
                    text: '${verse.arabicText}\n\n'
                        '${verse.turkishMeaning}\n\n'
                        '[${verse.reference}]',
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meal kopyalandı'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

