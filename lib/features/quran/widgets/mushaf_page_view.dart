import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
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
  double _fontSize = 22.0;
  bool _showInlineTranslation = false;

  @override
  void initState() {
    super.initState();
    _pages = _partitionVersesIntoPages(widget.verses);
    final initialPage = _findInitialPageIndex();
    _currentPageIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
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
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF06221D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.surah.localizedName(strings.language.code)} • ${verse.verseNumber}. Âyet',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Color(0xFFD4AF37), size: 20),
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
                  color: isDark ? const Color(0xFF031A16) : const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                ),
                child: Text(
                  verse.arabicText,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 21,
                    height: 1.8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFDF7A),
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
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
    final isFirstSurahPage = _currentPageIndex == 0;
    final showBismillah = isFirstSurahPage && widget.surah.id != 9 && widget.surah.id != 1;

    return Column(
      children: [
        // ── Üst Mushaf Çubuğu (Görünüm Değiştir / Boyut / Sayfa Bilgisi) ──────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF031A16) : const Color(0xFFF6F3E9),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.25),
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
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.format_list_bulleted_rounded, size: 14, color: Color(0xFFD4AF37)),
                      SizedBox(width: 4),
                      Text(
                        'Ayet Listesi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
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
                color: const Color(0xFFD4AF37),
                tooltip: 'Yazı Boyutunu Küçült',
                onPressed: () {
                  if (_fontSize > 18.0) {
                    setState(() => _fontSize -= 2.0);
                  }
                },
              ),
              Text(
                '${_fontSize.toInt()}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
              ),
              IconButton(
                icon: const Icon(Icons.text_increase_rounded, size: 18),
                color: const Color(0xFFD4AF37),
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
                  color: _showInlineTranslation ? const Color(0xFFFFDF7A) : Colors.white60,
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

        // ── Ana Mushaf Sayfası (PageView ile Sağa/Sola Çevirmeli) ────────────
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: totalPages,
            onPageChanged: (idx) {
              HapticFeedback.selectionClick();
              setState(() {
                _currentPageIndex = idx;
              });
            },
            itemBuilder: (context, pageIndex) {
              final pageVerses = _pages[pageIndex];

              return Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF03221D), Color(0xFF011613)]
                          : const [Color(0xFFFDFBF7), Color(0xFFF5EFE3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.45 : 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // İç Tezhib Çerçeve Çizgisi
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.25 : 0.18),
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
                                    color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF034A3E),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  widget.surah.nameArabic,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF034A3E),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFFD4AF37), height: 12, thickness: 0.8),

                            // Besmele (1. Sayfada)
                            if (showBismillah) ...[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontFamily: 'Amiri',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFFFDF7A),
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: (activeVerseNumber == verse.verseNumber)
                                                        ? const Color(0xFFD4AF37).withValues(alpha: 0.35)
                                                        : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: verse.arabicText,
                                                          style: TextStyle(
                                                            fontFamily: 'Amiri',
                                                            fontSize: _fontSize,
                                                            height: 2.15,
                                                            letterSpacing: 0.2,
                                                            color: isDark
                                                                ? const Color(0xFFFFE082)
                                                                : const Color(0xFF012E2B),
                                                            fontWeight: (activeVerseNumber == verse.verseNumber)
                                                                ? FontWeight.bold
                                                                : FontWeight.w600,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: ' ﴿${verse.verseNumber}﴾ ',
                                                          style: TextStyle(
                                                            fontFamily: 'Amiri',
                                                            fontSize: _fontSize * 0.85,
                                                            color: const Color(0xFFD4AF37),
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    textDirection: TextDirection.rtl,
                                                    textAlign: TextAlign.justify,
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
                                      const Divider(color: Color(0xFFD4AF37), height: 16),
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
                            const Divider(color: Color(0xFFD4AF37), height: 12, thickness: 0.8),
                            Center(
                              child: Text(
                                '— ${pageIndex + 1} / $totalPages —',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD4AF37),
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
            },
          ),
        ),

        // ── Alt Sayfa Kontrol Çubuğu (Önceki/Sonraki Sayfa) ──────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF031A16) : const Color(0xFFF6F3E9),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.3 : 0.25),
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
                color: _currentPageIndex > 0 ? const Color(0xFFD4AF37) : Colors.white24,
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
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Sayfa ${_currentPageIndex + 1} / $totalPages',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),

              // Sonraki Sayfa
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                color: _currentPageIndex < totalPages - 1 ? const Color(0xFFD4AF37) : Colors.white24,
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
