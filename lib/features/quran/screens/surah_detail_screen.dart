import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
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
import '../widgets/mushaf_page_view.dart';
import '../services/quran_download_service.dart';
import '../widgets/sleep_and_ambience_sheet.dart';

/// Kur'an Zen Okuma Zemini Temaları
enum ZenReadingTheme {
  standard,
  sepiaParchment,
  oledBlack,
}

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
  final GlobalKey _playingVerseKey = GlobalKey();
  bool _showScrollToTop = false;
  bool _hasScrolledToInitialVerse = false;
  bool _isMushafMode = false;
  bool _isZenMode = false;
  ZenReadingTheme _zenTheme = ZenReadingTheme.standard;
  int? _lastScrolledVerseNumber;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _scrollToVerseNumber(int verseNumber, List<Verse> verses) {
    if (_lastScrolledVerseNumber == verseNumber) return;
    _lastScrolledVerseNumber = verseNumber;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final playingCtx = _playingVerseKey.currentContext;
      if (playingCtx != null && playingCtx.mounted) {
        Scrollable.ensureVisible(
          playingCtx,
          alignment: 0.20,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
        return;
      }

      final targetIndex = verses.indexWhere((v) => v.verseNumber == verseNumber);
      if (targetIndex < 0) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      double estimatedOffset = 210.0;
      if (widget.surah.id != 9 && widget.surah.id != 1) {
        estimatedOffset += 110.0;
      }

      for (int i = 0; i < targetIndex; i++) {
        final v = verses[i];
        final arabicLines = (v.arabicText.length / 28.0).ceil().clamp(1, 40);
        final meaningLines = (v.turkishMeaning.length / 38.0).ceil().clamp(1, 40);
        estimatedOffset += 90.0 + (arabicLines * 46.0) + (meaningLines * 22.0) + 12.0;
      }

      final targetScroll = (estimatedOffset - 40.0).clamp(0.0, maxScroll);
      _scrollController.jumpTo(targetScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final ctx = _playingVerseKey.currentContext;
        if (ctx != null && ctx.mounted) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.20,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      });
    });
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
      backgroundColor: BeyanColors.tone(0xFF032B25),
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
                      style: TextStyle(
                        color: BeyanColors.tone(0xFFFFDF7A),
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
                              activeTrackColor: BeyanColors.tone(0xFFD4AF37),
                              inactiveTrackColor: Colors.white24,
                              thumbColor: BeyanColors.tone(0xFFFFDF7A),
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

  Widget _buildDownloadButton(BuildContext context, QuranAudioState audioState, AppStrings strings) {
    final reciter = audioState.selectedReciter;
    final isDownloaded = ref.watch(quranDownloadsProvider).contains('${reciter.id}_${widget.surah.id}');

    return IconButton(
      icon: Icon(
        isDownloaded ? Icons.download_done_rounded : Icons.download_for_offline_outlined,
        color: isDownloaded ? const Color(0xFF81C784) : BeyanColors.tone(0xFFFFDF7A),
      ),
      tooltip: isDownloaded
          ? (strings.language == AppLanguage.turkish ? 'Çevrimdışı Dinlemeye Hazır' : 'Downloaded for Offline')
          : (strings.language == AppLanguage.turkish ? 'Çevrimdışı Dinlemek İçin İndir' : 'Download for Offline'),
      onPressed: () async {
        HapticFeedback.mediumImpact();
        if (isDownloaded) {
          final deleted = await ref.read(quranDownloadsProvider.notifier).delete(
            reciterId: reciter.id,
            surahId: widget.surah.id,
          );
          if (context.mounted && deleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.surah.localizedName(strings.language.code)} çevrimdışı kaydı silindi.'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: BeyanColors.tone(0xFFFFDF7A)),
                  ),
                  const SizedBox(width: 10),
                  Text('${widget.surah.localizedName(strings.language.code)} (${reciter.nameTr}) indiriliyor...'),
                ],
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          final success = await ref.read(quranDownloadsProvider.notifier).download(
            reciterId: reciter.id,
            surahId: widget.surah.id,
            url: reciter.getSurahAudioUrl(widget.surah.id),
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? '✓ ${widget.surah.localizedName(strings.language.code)} çevrimdışı dinleme için indirildi!'
                      : 'İndirme başarısız oldu, lütfen internet bağlantınızı kontrol edin.',
                ),
                backgroundColor: success ? BeyanColors.tone(0xFF012E2B) : Colors.red[800],
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
    );
  }

  void _showReciterSheet(BuildContext context, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BeyanColors.tone(0xFF032B25),
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
                      style: TextStyle(
                        color: BeyanColors.tone(0xFFFFDF7A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...quranRecitersList.map((reciter) {
                      final isSel = audioState.selectedReciter.id == reciter.id;
                      final isDownloaded = ref.watch(quranDownloadsProvider).contains('${reciter.id}_${widget.surah.id}');

                      return ListTile(
                        leading: Icon(
                          isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: BeyanColors.tone(0xFFD4AF37),
                        ),
                        title: Text(
                          reciter.nameTr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              reciter.nameAr,
                              style: const TextStyle(fontFamily: 'Amiri', color: Colors.white70),
                            ),
                            if (isDownloaded) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'İndirildi',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF81C784), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isDownloaded ? Icons.download_done_rounded : Icons.download_for_offline_outlined,
                            color: isDownloaded ? const Color(0xFF81C784) : BeyanColors.tone(0xFFD4AF37),
                            size: 22,
                          ),
                          tooltip: isDownloaded ? 'Çevrimdışı İndirildi' : 'Çevrimdışı İndir',
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            if (isDownloaded) {
                              await ref.read(quranDownloadsProvider.notifier).delete(
                                reciterId: reciter.id,
                                surahId: widget.surah.id,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.surah.localizedName(strings.language.code)} (${reciter.nameTr}) indiriliyor...'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              final ok = await ref.read(quranDownloadsProvider.notifier).download(
                                reciterId: reciter.id,
                                surahId: widget.surah.id,
                                url: reciter.getSurahAudioUrl(widget.surah.id),
                              );
                              if (context.mounted && ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('✓ ${widget.surah.localizedName(strings.language.code)} çevrimdışı hazır!'),
                                    backgroundColor: BeyanColors.tone(0xFF012E2B),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
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
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final versesAsync = ref.watch(versesBySurahProvider(widget.surah.id));
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioState = ref.watch(quranAudioProvider);
    final isThisSurahPlaying = audioState.currentSurahId == widget.surah.id && audioState.isPlaying;

    ref.listen<QuranAudioState>(quranAudioProvider, (prev, next) {
      if (next.currentSurahId == widget.surah.id && next.isPlaying) {
        final verses = versesAsync.valueOrNull;
        if (verses != null && verses.isNotEmpty) {
          if (prev?.currentSurahId != next.currentSurahId) {
            ref.read(quranAudioProvider.notifier).setVerses(verses);
          }

          if (next.isLiveTrackingEnabled &&
              next.activeVerseNumber != null &&
              next.activeVerseNumber != prev?.activeVerseNumber) {
            _scrollToVerseNumber(next.activeVerseNumber!, verses);
          }
        }
      }
    });

    final zenBgColor = _isZenMode
        ? (_zenTheme == ZenReadingTheme.sepiaParchment
            ? const Color(0xFFF5EFE1)
            : (_zenTheme == ZenReadingTheme.oledBlack
                ? Colors.black
                : Theme.of(context).scaffoldBackgroundColor))
        : Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: zenBgColor,
      body: Stack(
        children: [
          versesAsync.when(
            loading: () => _buildLoadingScaffold(context, strings),
            error: (e, _) => _buildErrorScaffold(context, e.toString(), strings),
            data: (verses) => _buildContent(context, verses, isDark, isThisSurahPlaying, audioState, strings),
          ),
          // Alt Mini Tilavet Oynatıcısı (Zen modunda dikkati dağıtmamak için gizlenir)
          if (!_isZenMode)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: QuranAudioPlayerBar(),
            ),
          // Zen Modundan Çıkış ve Tema Değiştirme Kayan Hapı
          if (_isZenMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: SafeArea(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isZenMode = false);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: BeyanColors.tone(0xFFFFDF7A), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fullscreen_exit_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          strings.language == AppLanguage.turkish ? 'Zen Çıkış' : 'Exit Zen',
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A),
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (_showScrollToTop && !_isZenMode)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton.small(
                onPressed: _scrollToTop,
                backgroundColor: BeyanColors.tone(0xFF033E35),
                foregroundColor: BeyanColors.tone(0xFFFFDF7A),
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

  void _showReadingToolsSheet(BuildContext context, AppStrings strings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final audioState = ref.watch(quranAudioProvider);
            final isFavoriteSurah = ref.watch(favoriteSurahsProvider).contains(widget.surah.id);
            final isMemorization = ref.watch(quranMemorizationProvider).isActive;
            final isComparative = ref.watch(comparativeMealProvider);
            final isTr = strings.language == AppLanguage.turkish;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              decoration: BoxDecoration(
                color: BeyanColors.tone(0xFF01241F),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.45),
                  width: 1.2,
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isTr ? 'Okuma & Tilavet Araçları' : 'Reading & Recitation Tools',
                              style: TextStyle(
                                color: BeyanColors.tone(0xFFFFDF7A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildDownloadButton(context, audioState, strings),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Hızlı Butonlar (Favori, Kâri, Yazı Boyutu, Ambiyans/Uyku)
                      Row(
                        children: [
                          Expanded(
                            child: _buildToolActionTile(
                              icon: isFavoriteSurah ? Icons.star_rounded : Icons.star_outline_rounded,
                              label: isFavoriteSurah
                                  ? (isTr ? 'Favoride' : 'Favorited')
                                  : (isTr ? 'Favori Ekle' : 'Favorite'),
                              isActive: isFavoriteSurah,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                ref.read(favoriteSurahsProvider.notifier).toggleFavorite(widget.surah.id);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildToolActionTile(
                              icon: Icons.person_outline_rounded,
                              label: isTr ? 'Hafız Seç' : 'Reciter',
                              isActive: false,
                              onTap: () {
                                Navigator.pop(ctx);
                                _showReciterSheet(context, strings);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildToolActionTile(
                              icon: Icons.format_size_rounded,
                              label: isTr ? 'Yazı Boyutu' : 'Font Size',
                              isActive: false,
                              onTap: () {
                                Navigator.pop(ctx);
                                _showFontSizeSheet(context, strings);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildToolActionTile(
                              icon: Icons.bedtime_rounded,
                              label: isTr ? 'Uyku & Ses' : 'Ambience',
                              isActive: audioState.activeAmbience != null ||
                                  audioState.sleepTimerSecondsRemaining != null,
                              onTap: () {
                                Navigator.pop(ctx);
                                SleepAndAmbienceSheet.show(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Zen Okuma Zemini Seçimi (Standart / Sepya Kâğıt / OLED Siyah)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.palette_outlined, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isTr ? 'Okuma Zemini:' : 'Reading Theme:',
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              _buildZenThemePill(
                                label: 'Standart',
                                theme: ZenReadingTheme.standard,
                                isSelected: _zenTheme == ZenReadingTheme.standard,
                                onSelect: () => setState(() => _zenTheme = ZenReadingTheme.standard),
                              ),
                              const SizedBox(width: 5),
                              _buildZenThemePill(
                                label: 'Sepya 📜',
                                theme: ZenReadingTheme.sepiaParchment,
                                isSelected: _zenTheme == ZenReadingTheme.sepiaParchment,
                                onSelect: () => setState(() => _zenTheme = ZenReadingTheme.sepiaParchment),
                              ),
                              const SizedBox(width: 5),
                              _buildZenThemePill(
                                label: 'OLED 🌙',
                                theme: ZenReadingTheme.oledBlack,
                                isSelected: _zenTheme == ZenReadingTheme.oledBlack,
                                onSelect: () => setState(() => _zenTheme = ZenReadingTheme.oledBlack),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Anahtarlar (Switches)
                      _buildToolSwitchRow(
                        icon: Icons.visibility_off_rounded,
                        title: isTr ? 'Ezber & Hafızlık Testi (Kelimeleri Gizle)' : 'Memorization Mode (Blur Words)',
                        subtitle: isTr ? 'Kelimeleri buğular, dokundukça açarak ezberinizi sınar' : 'Tap blurred words to reveal and test memory',
                        value: isMemorization,
                        onChanged: (_) {
                          HapticFeedback.lightImpact();
                          ref.read(quranMemorizationProvider.notifier).toggleMode();
                        },
                      ),
                      _buildToolSwitchRow(
                        icon: Icons.compare_arrows_rounded,
                        title: isTr ? 'Çift Mealli Karşılaştırma Modu' : 'Comparative Translation Mode',
                        subtitle: isTr ? 'Diyanet ve Elmalılı Hamdi Yazır meallerini alt alta kıyaslar' : 'Compare two translations side by side',
                        value: isComparative,
                        onChanged: (_) {
                          HapticFeedback.lightImpact();
                          ref.read(comparativeMealProvider.notifier).toggle();
                        },
                      ),
                      _buildToolSwitchRow(
                        icon: Icons.auto_stories_rounded,
                        title: isTr ? 'Canlı Âyet Takibi (Otomatik Kaydırma)' : 'Live Verse Auto-Scroll',
                        subtitle: isTr ? 'Tilavet esnasında okunan âyete otomatik kaydırır' : 'Automatically scrolls to active verse',
                        value: audioState.isLiveTrackingEnabled,
                        onChanged: (_) {
                          HapticFeedback.lightImpact();
                          ref.read(quranAudioProvider.notifier).toggleLiveTracking();
                        },
                      ),
                      _buildToolSwitchRow(
                        icon: Icons.spellcheck_rounded,
                        title: strings.wordByWordLiveTracking,
                        subtitle: isTr ? 'Okunan Arapça kelimeyi altın renkle vurgular' : 'Highlights the active Arabic word in gold',
                        value: audioState.isWordHighlightEnabled,
                        onChanged: (_) {
                          HapticFeedback.lightImpact();
                          ref.read(quranAudioProvider.notifier).toggleWordHighlight();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildZenThemePill({
    required String label,
    required ZenReadingTheme theme,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        HapticFeedback.selectionClick();
        onSelect();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? BeyanColors.tone(0xFFD4AF37)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? BeyanColors.tone(0xFFFFDF7A)
                : Colors.white12,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildToolActionTile({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive
              ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? BeyanColors.tone(0xFFFFDF7A)
                : BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? BeyanColors.tone(0xFFFFDF7A) : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isActive ? BeyanColors.tone(0xFFFFDF7A) : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.5)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: BeyanColors.tone(0xFFFFDF7A),
              activeTrackColor: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Verse> verses,
    bool isDark,
    bool isThisSurahPlaying,
    QuranAudioState audioState,
    AppStrings strings,
  ) {
    final hasActiveToolBadge = ref.watch(quranMemorizationProvider).isActive ||
        ref.watch(comparativeMealProvider) ||
        audioState.activeAmbience != null ||
        audioState.sleepTimerSecondsRemaining != null;

    if (_isMushafMode) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            widget.surah.localizedName(strings.language.code),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: false,
          actions: [
            // 1. Ayet Listesi Görünümüne Geçiş
            IconButton(
              icon: Icon(Icons.format_list_bulleted_rounded, color: BeyanColors.tone(0xFFFFDF7A)),
              tooltip: strings.language == AppLanguage.turkish ? 'Ayet Listesi Görünümüne Geç' : 'Switch to Verse List',
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isMushafMode = false);
              },
            ),
            // 2. Tilavet Oynat/Durdur
            IconButton(
              icon: Icon(
                isThisSurahPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                color: BeyanColors.tone(0xFFFFDF7A),
                size: 27,
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (isThisSurahPlaying) {
                  ref.read(quranAudioProvider.notifier).togglePlayPause();
                } else {
                  ref.read(quranAudioProvider.notifier).setVerses(verses);
                  final sName = widget.surah.localizedName(strings.language.code);
                  if (widget.initialScrollToVerse != null &&
                      widget.initialScrollToVerse! > 1 &&
                      audioState.currentSurahId != widget.surah.id) {
                    ref.read(quranAudioProvider.notifier).seekToVerse(
                          widget.initialScrollToVerse!,
                          verses,
                          surahName: sName,
                        );
                  } else {
                    ref.read(quranAudioProvider.notifier).playSurah(widget.surah.id, sName);
                  }
                }
              },
            ),
            // 3. Tüm Okuma & Tilavet Araçları (Toplu, Ferah Menü)
            IconButton(
              icon: Badge(
                isLabelVisible: hasActiveToolBadge,
                backgroundColor: BeyanColors.tone(0xFFFFDF7A),
                child: const Icon(Icons.tune_rounded, color: Colors.white),
              ),
              tooltip: strings.language == AppLanguage.turkish ? 'Okuma & Tilavet Araçları' : 'Reading & Audio Tools',
              onPressed: () => _showReadingToolsSheet(context, strings),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: MushafPageView(
          surah: widget.surah,
          verses: verses,
          initialVerseNumber: widget.initialScrollToVerse,
          onSwitchToListMode: () => setState(() => _isMushafMode = false),
        ),
      );
    }

    if (!_hasScrolledToInitialVerse &&
        widget.initialScrollToVerse != null &&
        widget.initialScrollToVerse! >= 1) {
      _scrollToInitialVerseIfNeeded(verses);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Sure Başlığı AppBar (Ferah & Toplu Üst Bar) ─────────────────────────────
        SliverAppBar(
          expandedHeight: 210,
          pinned: true,
          backgroundColor: isDark ? BeyanColors.tone(0xFF01201B) : AppColors.teal,
          title: Text(
            widget.surah.localizedName(strings.language.code),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: false,
          actions: [
            // 1. Orijinal Mushaf Sayfa Moduna Geçiş Butonu
            IconButton(
              icon: Icon(Icons.auto_stories_rounded, color: BeyanColors.tone(0xFFFFDF7A)),
              tooltip: strings.language == AppLanguage.turkish ? 'Orijinal Mushaf Sayfa Modu' : 'Original Mushaf Page View',
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _isMushafMode = true);
              },
            ),
            // 2. Tilavet Dinle Butonu
            IconButton(
              icon: Icon(
                isThisSurahPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                color: BeyanColors.tone(0xFFFFDF7A),
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
                  ref.read(quranAudioProvider.notifier).setVerses(verses);
                  final sName = widget.surah.localizedName(strings.language.code);
                  if (widget.initialScrollToVerse != null &&
                      widget.initialScrollToVerse! > 1 &&
                      audioState.currentSurahId != widget.surah.id) {
                    ref.read(quranAudioProvider.notifier).seekToVerse(
                          widget.initialScrollToVerse!,
                          verses,
                          surahName: sName,
                        );
                  } else {
                    ref.read(quranAudioProvider.notifier).playSurah(widget.surah.id, sName);
                  }
                }
              },
            ),
            // 3. Tüm Okuma & Tilavet Araçları (Favori, Hafız, Ezber, Çift Meal, Uyku/Ambiyans, Boyut)
            IconButton(
              icon: Badge(
                isLabelVisible: hasActiveToolBadge,
                backgroundColor: BeyanColors.tone(0xFFFFDF7A),
                child: const Icon(Icons.tune_rounded, color: Colors.white),
              ),
              tooltip: strings.language == AppLanguage.turkish ? 'Okuma & Tilavet Araçları' : 'Reading & Audio Tools',
              onPressed: () => _showReadingToolsSheet(context, strings),
            ),
            // 4. Zen / Fokus Modu Butonu (Sinematik Mushaf)
            IconButton(
              icon: Icon(
                _isZenMode ? Icons.fullscreen_exit_rounded : Icons.spa_rounded,
                color: _isZenMode ? BeyanColors.tone(0xFFFFD54F) : BeyanColors.tone(0xFFFFDF7A),
              ),
              tooltip: _isZenMode
                  ? (strings.language == AppLanguage.turkish ? 'Zen Modundan Çık' : 'Exit Zen Mode')
                  : (strings.language == AppLanguage.turkish ? 'Zen / Odaklanma Modu' : 'Zen Focus Mode'),
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() => _isZenMode = !_isZenMode);
              },
            ),
            const SizedBox(width: 4),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [BeyanColors.tone(0xFF064E43), BeyanColors.tone(0xFF011B18)]
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
              final isPlayingVerse = isThisSurahPlaying && audioState.activeVerseNumber == verse.verseNumber;
              final sName = widget.surah.localizedName(strings.language.code);
              return RepaintBoundary(
                child: VerseCard(
                  key: isPlayingVerse ? _playingVerseKey : (isTarget ? _targetVerseKey : ValueKey('v_${verse.id}')),
                  verse: verse,
                  surahName: sName,
                  isHighlighted: isTarget,
                  isPlaying: isPlayingVerse,
                  onWordTap: (wordIdx) {
                    HapticFeedback.lightImpact();
                    ref.read(quranAudioProvider.notifier).seekToWord(
                          verse.verseNumber,
                          wordIdx,
                          verses,
                          surahName: sName,
                        );
                  },
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(quranAudioProvider.notifier).seekToVerse(
                          verse.verseNumber,
                          verses,
                          surahName: sName,
                        );
                  },
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
              color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF033E35),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
