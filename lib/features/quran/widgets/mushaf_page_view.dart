import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/services/acoustic_audio_service.dart';
import '../models/surah.dart';
import '../models/verse.dart';
import '../services/quran_audio_service.dart';

/// Beyân - Orijinal Mushaf Sayfa Görünümü (Sayfa Sayfa Çevirme)
/// Medine ve Diyanet baskısı lüks tezhibli hat görünümü.
class MushafPageView extends ConsumerStatefulWidget {
  final Surah surah;
  final List<Verse> verses;
  final int? initialVerseNumber;
  final VoidCallback onSwitchToListMode;

  const MushafPageView({
    super.key,
    required this.surah,
    required this.verses,
    this.initialVerseNumber,
    required this.onSwitchToListMode,
  });

  @override
  ConsumerState<MushafPageView> createState() => _MushafPageViewState();
}

class _MushafPageViewState extends ConsumerState<MushafPageView> {
  late PageController _pageController;
  late List<List<Verse>> _pages;
  int _currentPageIndex = 0;
  int _lastHapticMilestone = -1;
  double _fontSize = 22.0;
  bool _showInlineTranslation = false;

  @override
  void initState() {
    super.initState();
    _pages = _partitionVersesIntoPages(widget.verses);
    final initialPage = _findInitialPageIndex();
    _currentPageIndex = initialPage;
    _pageController = PageController(initialPage: initialPage)
      ..addListener(_onPageScrollTick);
  }

  void _onPageScrollTick() {
    if (!_pageController.hasClients || !_pageController.position.haveDimensions) return;
    final page = _pageController.page ?? _currentPageIndex.toDouble();
    final fraction = (page - page.floor()).abs();
    // Parmakla sayfa kıvrılırken %35 geçiş eşiğinde ince dokunsal sayfa gerilimi hissi
    final milestone = (fraction > 0.32 && fraction < 0.68) ? page.floor() : -1;
    if (milestone != -1 && milestone != _lastHapticMilestone) {
      _lastHapticMilestone = milestone;
      HapticFeedback.selectionClick();
    } else if (milestone == -1) {
      _lastHapticMilestone = -1;
    }
  }

  @override
  void didUpdateWidget(covariant MushafPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verses != widget.verses) {
      setState(() {
        _pages = _partitionVersesIntoPages(widget.verses);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _findInitialPageIndex() {
    if (widget.initialVerseNumber == null || _pages.isEmpty) return 0;
    for (int i = 0; i < _pages.length; i++) {
      if (_pages[i].any((v) => v.verseNumber == widget.initialVerseNumber)) {
        return i;
      }
    }
    return 0;
  }

  List<List<Verse>> _partitionVersesIntoPages(List<Verse> verses) {
    if (verses.isEmpty) return [];
    final pages = <List<Verse>>[];
    var currentPage = <Verse>[];
    var currentChars = 0;
    const targetCharsPerPage = 540;

    for (final v in verses) {
      final vLen = v.arabicText.length;
      if (currentChars + vLen > targetCharsPerPage && currentPage.isNotEmpty) {
        pages.add(currentPage);
        currentPage = [v];
        currentChars = vLen;
      } else {
        currentPage.add(v);
        currentChars += vLen;
      }
    }
    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }
    return pages;
  }

  Widget _buildMushafVerseRichText({
    required Verse verse,
    required bool isDark,
    required bool isActiveVerse,
    required int? activeWordIndex,
    required double wordProgress,
  }) {
    final defaultColor = isDark ? BeyanColors.tone(0xFFFFE082) : BeyanColors.tone(0xFF012E2B);
    if (!isActiveVerse || activeWordIndex == null) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: verse.arabicText,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: _fontSize,
                height: 2.15,
                letterSpacing: 0.2,
                color: defaultColor,
                fontWeight: isActiveVerse ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            TextSpan(
              text: ' ﴿${verse.verseNumber}﴾ ',
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: _fontSize * 0.85,
                color: BeyanColors.tone(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
      );
    }

    final words = verse.arabicText.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final clampedWordIdx = words.isNotEmpty ? activeWordIndex.clamp(0, words.length - 1) : 0;
    final wp = wordProgress.clamp(0.0, 1.0);
    final sweep = wp * 1.20 - 0.10;
    final leadStop = (sweep - 0.10).clamp(0.0, 1.0);
    final trailStop = (sweep + 0.10).clamp(0.0, 1.0);
    final litGold = isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF012E2B);
    final unlitColor = isDark ? Colors.white.withValues(alpha: 0.36) : Colors.black.withValues(alpha: 0.34);

    return Text.rich(
      TextSpan(
        children: [
          for (int i = 0; i < words.length; i++) ...[
            if (i == clampedWordIdx)
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        isDark ? const Color(0xFFFFF6CC) : BeyanColors.tone(0xFF012E2B),
                        litGold,
                        unlitColor,
                        unlitColor,
                      ],
                      stops: [0.0, leadStop, trailStop, 1.0],
                    ).createShader(bounds);
                  },
                  child: Text(
                    words[i],
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: _fontSize * 1.04,
                      height: 2.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              TextSpan(
                text: words[i],
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: _fontSize,
                  height: 2.15,
                  letterSpacing: 0.2,
                  color: i < clampedWordIdx ? defaultColor : unlitColor,
                  fontWeight: i < clampedWordIdx ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            if (i < words.length - 1)
              TextSpan(
                text: ' ',
                style: TextStyle(fontFamily: 'Amiri', fontSize: _fontSize, height: 2.15),
              ),
          ],
          TextSpan(
            text: ' ﴿${verse.verseNumber}﴾ ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: _fontSize * 0.85,
              color: BeyanColors.tone(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
  }

  void _onVerseTap(Verse verse, AppStrings strings) {
    HapticFeedback.lightImpact();
    _showVerseDetailSheet(context, verse, strings);
  }

  void _showVerseDetailSheet(BuildContext context, Verse verse, AppStrings strings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          decoration: BoxDecoration(
            color: isDark ? BeyanColors.tone(0xFF06221D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta != null && details.primaryDelta! > 6) {
                    Navigator.pop(ctx);
                  }
                },
                onTap: () => Navigator.pop(ctx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.surah.localizedName(strings.language.code)} • ${verse.verseNumber}. Âyet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: BeyanColors.tone(0xFFD4AF37),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.copy_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 20),
                    tooltip: strings.copyAndShare,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final text = '${verse.arabicText}\n\n'
                          '${verse.transliteration ?? ''}\n\n'
                          '${verse.localizedMeaning(strings.language.code)}\n\n'
                          '(${widget.surah.localizedName(strings.language.code)} ${verse.verseNumber})';
                      Clipboard.setData(ClipboardData(text: text));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.duaCopied),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? BeyanColors.tone(0xFF031A16) : const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2)),
                ),
                child: Text(
                  verse.arabicText,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 21,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                    color: BeyanColors.tone(0xFFFFDF7A),
                  ),
                ),
              ),
              if (verse.transliteration != null && verse.transliteration!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  verse.transliteration!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                verse.localizedMeaning(strings.language.code),
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final audioState = ref.watch(quranAudioProvider);
    final activeVerseNumber = audioState.activeVerseNumber;

    // Sayfalar boşsa
    if (_pages.isEmpty) {
      return Center(child: CircularProgressIndicator(color: BeyanColors.tone(0xFFD4AF37)));
    }

    // Sesli tilavet ilerlerken aktif ayet başka bir sayfadaysa sayfayı otomatik çevir
    ref.listen<QuranAudioState>(quranAudioProvider, (prev, next) {
      if (next.currentSurahId == widget.surah.id && next.isPlaying && next.activeVerseNumber != null) {
        final targetPageIdx = _pages.indexWhere((p) => p.any((v) => v.verseNumber == next.activeVerseNumber));
        if (targetPageIdx != -1 && targetPageIdx != _currentPageIndex && _pageController.hasClients) {
          _pageController.animateToPage(
            targetPageIdx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    final totalPages = _pages.length;

    return Column(
      children: [
        // ── Üst Mushaf Çubuğu (Görünüm Değiştir / Boyut / Sayfa Bilgisi) ──────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? BeyanColors.tone(0xFF031A16) : const Color(0xFFF6F3E9),
            border: Border(
              bottom: BorderSide(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.25),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Liste Görünümüne Geçiş Butonu
              InkWell(
                onTap: widget.onSwitchToListMode,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.format_list_bulleted_rounded, size: 14, color: BeyanColors.tone(0xFFD4AF37)),
                      const SizedBox(width: 4),
                      Text(
                        'Ayet Listesi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: BeyanColors.tone(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Yazı Boyutu A- / A+
              IconButton(
                icon: const Icon(Icons.text_decrease_rounded, size: 18),
                color: BeyanColors.tone(0xFFD4AF37),
                tooltip: 'Yazı Boyutunu Küçült',
                onPressed: () {
                  if (_fontSize > 18.0) {
                    setState(() => _fontSize -= 2.0);
                  }
                },
              ),
              Text(
                '${_fontSize.toInt()}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: BeyanColors.tone(0xFFD4AF37)),
              ),
              IconButton(
                icon: const Icon(Icons.text_increase_rounded, size: 18),
                color: BeyanColors.tone(0xFFD4AF37),
                tooltip: 'Yazı Boyutunu Büyüt',
                onPressed: () {
                  if (_fontSize < 32.0) {
                    setState(() => _fontSize += 2.0);
                  }
                },
              ),
              const SizedBox(width: 6),

              // Meal Aç/Kapat Butonu
              IconButton(
                icon: Icon(
                  _showInlineTranslation ? Icons.translate_rounded : Icons.g_translate_outlined,
                  color: _showInlineTranslation ? BeyanColors.tone(0xFFFFDF7A) : Colors.white60,
                  size: 20,
                ),
                tooltip: _showInlineTranslation ? 'Meal Gizle' : 'Meal Göster',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showInlineTranslation = !_showInlineTranslation);
                },
              ),
            ],
          ),
        ),

        // ── Ana Mushaf Sayfası (Parmak Hareketine Duyarlı 3B Gerçek Sayfa Çevirme) ────────────
        Expanded(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (_currentPageIndex == 0 &&
                        notification is OverscrollNotification &&
                        notification.overscroll < -20) {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).maybePop();
                      return true;
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.hardEdge,
                    itemCount: totalPages,
                    onPageChanged: (idx) {
                      AcousticAudioService.instance.playParchmentPageFlip();
                      setState(() {
                        _currentPageIndex = idx;
                      });
                    },
                    itemBuilder: (context, pageIndex) {
                      final pageVerses = _pages[pageIndex];
                      final pageShowBismillah =
                          pageIndex == 0 && widget.surah.id != 9 && widget.surah.id != 1;

              final pageCard = Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [BeyanColors.tone(0xFF03221D), BeyanColors.tone(0xFF011613)]
                          : const [Color(0xFFFDFBF7), Color(0xFFF5EFE3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.45 : 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Cilt Sırtı Gölgelendirmesi (Gerçek Kitap Oluk Hissi)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        width: 24,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withValues(alpha: isDark ? 0.32 : 0.08),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // İç Tezhib Çerçeve Çizgisi
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.25 : 0.18),
                              width: 1,
                            ),
                          ),
                        ),
                      ),

                      // Sayfa İçeriği
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Column(
                          children: [
                            // ── Üst Sayfa Başlığı (Cüz & Sure Adı) ─────────
                            Row(
                              children: [
                                Text(
                                  widget.surah.localizedName(strings.language.code),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF034A3E),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.swipe_rounded,
                                      size: 13,
                                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.surah.nameArabic,
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF034A3E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(color: BeyanColors.tone(0xFFD4AF37), height: 12, thickness: 0.8),

                            // Besmele (1. Sayfada)
                            if (pageShowBismillah) ...[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: BeyanColors.tone(0xFFFFDF7A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],

                            // ── Kesintisiz Akan Arapça Mushaf Metni ──────────
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          for (final verse in pageVerses) ...[
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              child: GestureDetector(
                                                onTap: () => _onVerseTap(verse, strings),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: (activeVerseNumber == verse.verseNumber)
                                                        ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.14)
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: _buildMushafVerseRichText(
                                                    verse: verse,
                                                    isDark: isDark,
                                                    isActiveVerse: activeVerseNumber == verse.verseNumber,
                                                    activeWordIndex: (activeVerseNumber == verse.verseNumber)
                                                        ? audioState.activeWordIndex
                                                        : null,
                                                    wordProgress: (activeVerseNumber == verse.verseNumber)
                                                        ? audioState.wordProgress
                                                        : 1.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.justify,
                                    ),

                                    // Meal görünümü açıkken altta Türkçe meal
                                    if (_showInlineTranslation) ...[
                                      const SizedBox(height: 14),
                                      Divider(color: BeyanColors.tone(0xFFD4AF37), height: 16),
                                      for (final v in pageVerses) ...[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: Text(
                                            '${v.verseNumber}. ${v.localizedMeaning(strings.language.code)}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              height: 1.35,
                                              color: isDark ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // ── Alt Sayfa Numarası (Mushaf Çerçevesi) ─────────
                            Divider(color: BeyanColors.tone(0xFFD4AF37), height: 12, thickness: 0.8),
                            Center(
                              child: Text(
                                '— ${pageIndex + 1} / $totalPages —',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: BeyanColors.tone(0xFFD4AF37),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              // Parmak hareketini anlık takip eden 3B Mushaf Sayfa Kıvrılma & Gölge Efekti
              return AnimatedBuilder(
                animation: _pageController,
                child: pageCard,
                builder: (context, child) {
                  double pageOffset = _currentPageIndex.toDouble();
                  if (_pageController.hasClients && _pageController.position.haveDimensions) {
                    pageOffset = _pageController.page ?? _currentPageIndex.toDouble();
                  }
                  final delta = (pageOffset - pageIndex).clamp(-1.0, 1.0);
                  if (delta.abs() < 0.001) return child!;

                  final absDelta = delta.abs();
                  // Tamamen ekran dışına çıkmış sayfayı derhal budayarak (culling) kenarda artık görüntü kalmasını önle
                  if (absDelta >= 0.999) {
                    return const SizedBox.shrink();
                  }

                  final isTurningAway = delta > 0;
                  final rotationY = delta * 0.62; // 3B perspektif açısı
                  final scale = 1.0 - (absDelta * 0.045);

                  final matrix = Matrix4.identity()
                    ..setEntry(3, 2, 0.0018) // 3B derinlik perspektifi
                    ..rotateY(rotationY)
                    ..scaleByDouble(scale, scale, 1.0, 1.0);

                  // 3B kıvrılan sayfanın yan marjinlere taşmasını ClipRect ile mutlak şekilde sınırla
                  return ClipRect(
                    child: Transform(
                      alignment: isTurningAway ? Alignment.centerLeft : Alignment.centerRight,
                      transform: matrix,
                      child: Stack(
                        children: [
                          child!,
                          // Parmakla çevrilirken oluşan dinamik kağıt kıvrımı ve gölgesi
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: isTurningAway ? Alignment.centerRight : Alignment.centerLeft,
                                      end: isTurningAway ? Alignment.centerLeft : Alignment.centerRight,
                                      stops: const [0.0, 0.25, 0.65, 1.0],
                                      colors: [
                                        Colors.black.withValues(alpha: (absDelta * 0.42).clamp(0.0, 0.42)),
                                        BeyanColors.tone(0xFFFFDF7A).withValues(alpha: (absDelta * 0.14).clamp(0.0, 0.14)),
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: (absDelta * 0.22).clamp(0.0, 0.22)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // iOS Sol Kenardan Sağa Kaydırarak Geri Dönme (Interactive Edge Swipe Pop)
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          width: 28,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! > 12) {
                HapticFeedback.lightImpact();
                Navigator.of(context).maybePop();
              }
            },
          ),
        ),
      ],
    ),
  ),
),

        // ── Alt Sayfa Kontrol Çubuğu (Önceki/Sonraki Sayfa) ──────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? BeyanColors.tone(0xFF031A16) : const Color(0xFFF6F3E9),
            border: Border(
              top: BorderSide(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.25),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Önceki Sayfa
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
                color: _currentPageIndex > 0 ? BeyanColors.tone(0xFFD4AF37) : Colors.white24,
                onPressed: _currentPageIndex > 0
                    ? () {
                        HapticFeedback.selectionClick();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),

              // Sayfa Göstergesi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Sayfa ${_currentPageIndex + 1} / $totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFD4AF37),
                  ),
                ),
              ),

              // Sonraki Sayfa
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                color: _currentPageIndex < totalPages - 1 ? BeyanColors.tone(0xFFD4AF37) : Colors.white24,
                onPressed: _currentPageIndex < totalPages - 1
                    ? () {
                        HapticFeedback.selectionClick();
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
