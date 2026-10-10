import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart' as app_widgets;
import '../models/surah.dart';
import '../models/verse.dart';
import '../providers/quran_providers.dart';
import '../providers/quran_reading_providers.dart';
import '../services/quran_audio_service.dart';
import '../widgets/arabic_text_widget.dart';
import '../widgets/verse_card_widget.dart';
import '../widgets/quran_audio_player_bar.dart';

/// Sure Detay Ekranı – Seçilen surenin tüm ayetlerini ve tilavetini sunar.
class SurahDetailScreen extends ConsumerStatefulWidget {
  final Surah surah;
  final int? initialScrollToVerse;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.initialScrollToVerse,
  });

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _targetVerseKey = GlobalKey();
  bool _showScrollToTop = false;
  bool _hasScrolledToInitialVerse = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _scrollToInitialVerseIfNeeded(List<Verse> verses) {
    if (_hasScrolledToInitialVerse) return;
    final target = widget.initialScrollToVerse;
    if (target == null || target < 1) return;

    _hasScrolledToInitialVerse = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final targetIndex = verses.indexWhere((v) => v.verseNumber == target);
      if (targetIndex < 0) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      double estimatedOffset = 210.0; // SliverAppBar yüksekliği
      if (widget.surah.id != 9 && widget.surah.id != 1) {
        estimatedOffset += 110.0; // Besmele kartı
      }

      // Her bir ayetin gerçek metin uzunluğuna göre dinamik ve hassas kaydırma hesabı
      for (int i = 0; i < targetIndex; i++) {
        final v = verses[i];
        final arabicLines = (v.arabicText.length / 28.0).ceil().clamp(1, 40);
        final meaningLines = (v.turkishMeaning.length / 38.0).ceil().clamp(1, 40);
        estimatedOffset += 90.0 + (arabicLines * 46.0) + (meaningLines * 22.0) + 12.0;
      }

      // 1. Adım: Hedef ayetin hemen yakınına zıpla (viewport içine girmesini sağlar)
      _scrollController.jumpTo(estimatedOffset.clamp(0.0, maxScroll));

      // 2. Adım: Viewport'ta render edilen hedef kartı GlobalKey ile hizala
      void tryEnsureVisible([int attempts = 0]) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final targetCtx = _targetVerseKey.currentContext;
          if (targetCtx != null && targetCtx.mounted) {
            Scrollable.ensureVisible(
              targetCtx,
              alignment: 0.15,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
          } else if (attempts < 3) {
            tryEnsureVisible(attempts + 1);
          }
        });
      }

      tryEnsureVisible();
    });
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

  void _showFontSizeSheet(BuildContext context, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF032B25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final currentSize = ref.watch(arabicFontSizeProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      strings.arabicFontSizeTitle,
                      style: const TextStyle(
                        color: Color(0xFFFFDF7A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: currentSize,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text('A', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFFD4AF37),
                              inactiveTrackColor: Colors.white24,
                              thumbColor: const Color(0xFFFFDF7A),
                            ),
                            child: Slider(
                              value: currentSize,
                              min: 18.0,
                              max: 38.0,
                              divisions: 10,
                              label: '${currentSize.toInt()} pt',
                              onChanged: (val) {
                                ref.read(arabicFontSizeProvider.notifier).setFontSize(val);
                              },
                            ),
                          ),
                        ),
                        const Text('A', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReciterSheet(BuildContext context, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF032B25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final audioState = ref.watch(quranAudioProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings.reciterSelectionTitle,
                      style: const TextStyle(
                        color: Color(0xFFFFDF7A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...quranRecitersList.map((reciter) {
                      final isSel = audioState.selectedReciter.id == reciter.id;
                      return ListTile(
                        leading: Icon(
                          isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: const Color(0xFFD4AF37),
                        ),
                        title: Text(
                          reciter.nameTr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          reciter.nameAr,
                          style: const TextStyle(fontFamily: 'Amiri', color: Colors.white70),
                        ),
                        onTap: () {
                          ref.read(quranAudioProvider.notifier).setReciter(reciter);
                          Navigator.pop(ctx);
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final versesAsync = ref.watch(versesBySurahProvider(widget.surah.id));
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioState = ref.watch(quranAudioProvider);
    final isThisSurahPlaying = audioState.currentSurahId == widget.surah.id && audioState.isPlaying;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          versesAsync.when(
            loading: () => _buildLoadingScaffold(context, strings),
            error: (e, _) => _buildErrorScaffold(context, e.toString(), strings),
            data: (verses) => _buildContent(context, verses, isDark, isThisSurahPlaying, strings),
          ),
          // Alt Mini Tilavet Oynatıcısı
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: QuranAudioPlayerBar(),
          ),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton.small(
                onPressed: _scrollToTop,
                backgroundColor: const Color(0xFF033E35),
                foregroundColor: const Color(0xFFFFDF7A),
                child: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
            )
          : null,
    );
  }

  Widget _buildLoadingScaffold(BuildContext context, AppStrings strings) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surah.localizedName(strings.language.code))),
      body: app_widgets.LoadingWidget(message: strings.versesLoading),
    );
  }

  Widget _buildErrorScaffold(BuildContext context, String error, AppStrings strings) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surah.localizedName(strings.language.code))),
      body: app_widgets.AppErrorWidget(
        message: '${strings.versesLoadError}\n$error',
        onRetry: () => ref.invalidate(versesBySurahProvider(widget.surah.id)),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Verse> verses,
    bool isDark,
    bool isThisSurahPlaying,
    AppStrings strings,
  ) {
    if (!_hasScrolledToInitialVerse &&
        widget.initialScrollToVerse != null &&
        widget.initialScrollToVerse! >= 1) {
      _scrollToInitialVerseIfNeeded(verses);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Sure Başlığı AppBar ─────────────────────────────
        SliverAppBar(
          expandedHeight: 210,
          pinned: true,
          backgroundColor: AppColors.teal,
          actions: [
            // Kâri Seçimi Butonu
            IconButton(
              icon: const Icon(Icons.person_outline_rounded, color: Color(0xFFFFDF7A)),
              tooltip: strings.reciterSelectionTooltip,
              onPressed: () => _showReciterSheet(context, strings),
            ),
            // Tilavet Dinle Butonu
            IconButton(
              icon: Icon(
                isThisSurahPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                color: const Color(0xFFFFDF7A),
                size: 28,
              ),
              tooltip: isThisSurahPlaying
                  ? (strings.language == AppLanguage.english
                      ? 'Pause Recitation'
                      : (strings.language == AppLanguage.arabic ? 'إيقاف مؤقت' : 'Tilaveti Duraklat'))
                  : strings.listenSurahTooltip,
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (isThisSurahPlaying) {
                  ref.read(quranAudioProvider.notifier).togglePlayPause();
                } else {
                  ref.read(quranAudioProvider.notifier).playSurah(widget.surah.id, widget.surah.localizedName(strings.language.code));
                }
              },
            ),
            // Yazı Boyutu Butonu
            IconButton(
              icon: const Icon(Icons.format_size_rounded, color: Colors.white),
              tooltip: strings.fontSizeTooltip,
              onPressed: () => _showFontSizeSheet(context, strings),
            ),
          ],
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
                    const SizedBox(height: 30),
                    ArabicText(
                      widget.surah.nameArabic,
                      fontSize: 38.0,
                      lineHeight: 1.6,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.surah.localizedName(strings.language.code)}  ·  ${strings.language == AppLanguage.english ? widget.surah.nameArabic : widget.surah.nameEnglish}',
                      style: const TextStyle(color: Colors.white70, fontSize: 15, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(icon: Icons.format_list_numbered_rounded, label: strings.surahNumberBadge(widget.surah.id)),
                        const SizedBox(width: 8),
                        _StatBadge(icon: Icons.text_fields_rounded, label: widget.surah.localizedVerseCount(strings.language.code)),
                        const SizedBox(width: 8),
                        _StatBadge(icon: Icons.place_rounded, label: widget.surah.localizedRevelation(strings.language.code)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Besmele (Tevbe Suresi hariç) ───────────────────
        if (widget.surah.id != 9 && widget.surah.id != 1)
          SliverToBoxAdapter(
            child: _BismillahCard(isDark: isDark),
          ),

        // ── Ayet Listesi ────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final verse = verses[index];
              final isTarget = widget.initialScrollToVerse == verse.verseNumber;
              return RepaintBoundary(
                child: VerseCard(
                  key: isTarget ? _targetVerseKey : null,
                  verse: verse,
                  isHighlighted: isTarget,
                ),
              );
            },
            childCount: verses.length,
          ),
        ),

        // Alt boşluk (Mini oynatıcı çubuğu için)
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BismillahCard extends StatelessWidget {
  final bool isDark;
  const _BismillahCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: isDark ? 0.15 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.teal.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ArabicText.bismillah(
            color: isDark ? AppColors.arabicTextDark : AppColors.tealDark,
          ),
          const SizedBox(height: 6),
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
