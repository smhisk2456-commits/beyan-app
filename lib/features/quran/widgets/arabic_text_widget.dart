import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Arapça metinler için merkezi tipografi widget'ı.
///
/// - Amiri fontu zorunluluğunu tek noktada garanti eder.
/// - `textDirection: TextDirection.rtl` her seferinde korunur.
/// - Canlı tilavet sırasında Apple Music Live Lyrics tarzı kelime içi harf harf (RTL) altın ışık akışı destekler.
class ArabicText extends StatefulWidget {
  final String text;
  final double fontSize;

  /// Harekelerin üst/alt satıra taşmaması için geniş tutulur.
  final double lineHeight;

  final Color? color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  /// Besmele gibi özel büyük metinler için true.
  final bool isBismillah;

  /// Canlı takipte öne çıkarılacak kelimenin 0 tabanlı indeksi.
  final int? highlightedWordIndex;

  /// Aktif kelimenin içindeki harf harf ilerleme oranı (0.0 -> 1.0, Apple Music Live Lyrics akışı).
  final double highlightedWordProgress;

  /// Ezber / Hafızlık modunda gizlenecek kelime indeksleri kümesi.
  final Set<int>? hiddenWordIndices;

  /// Kelimeye tıklandığında tilavette o kelimeye atlama veya kelimeyi açma callback'i.
  final void Function(int wordIndex)? onWordTap;

  const ArabicText(
    this.text, {
    super.key,
    this.fontSize = 26.0,
    this.lineHeight = 2.0,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.right,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.isBismillah = false,
    this.highlightedWordIndex,
    this.highlightedWordProgress = 1.0,
    this.hiddenWordIndices,
    this.onWordTap,
  });

  /// Sure başındaki besmele için fabrika constructor.
  factory ArabicText.bismillah({Key? key, Color? color}) {
    return ArabicText(
      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      key: key,
      fontSize: 24.0,
      lineHeight: 2.2,
      color: color,
      fontWeight: FontWeight.normal,
      textAlign: TextAlign.center,
      isBismillah: true,
    );
  }

  /// Widget header'ları için küçük Arapça metin.
  factory ArabicText.small(String text, {Key? key, Color? color}) {
    return ArabicText(
      text,
      key: key,
      fontSize: 18.0,
      lineHeight: 1.8,
      color: color,
    );
  }

  @override
  State<ArabicText> createState() => _ArabicTextState();
}

class _ArabicTextState extends State<ArabicText> {
  List<TapGestureRecognizer>? _recognizers;
  List<String> _words = const [];

  @override
  void initState() {
    super.initState();
    _initWordsAndRecognizers();
  }

  @override
  void didUpdateWidget(covariant ArabicText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        (oldWidget.onWordTap == null) != (widget.onWordTap == null) ||
        oldWidget.hiddenWordIndices != widget.hiddenWordIndices ||
        (oldWidget.highlightedWordIndex == null) != (widget.highlightedWordIndex == null)) {
      _disposeRecognizers();
      _initWordsAndRecognizers();
    }
  }

  void _disposeRecognizers() {
    if (_recognizers != null) {
      for (final r in _recognizers!) {
        r.dispose();
      }
      _recognizers = null;
    }
  }

  void _initWordsAndRecognizers() {
    if (widget.highlightedWordIndex != null ||
        widget.onWordTap != null ||
        widget.hiddenWordIndices != null) {
      _words = widget.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      if (widget.onWordTap != null) {
        _recognizers = List.generate(_words.length, (i) {
          return TapGestureRecognizer()..onTap = () => widget.onWordTap!(i);
        });
      }
    } else {
      _words = const [];
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = widget.color ?? (isDark ? AppColors.arabicTextDark : AppColors.arabicText);

    // Canlı kelime takibi, ezber modu veya kelime dokunma yoksa standart ve hafif Text döndür
    if (widget.highlightedWordIndex == null && widget.onWordTap == null && widget.hiddenWordIndices == null) {
      return Text(
        widget.text,
        textDirection: TextDirection.rtl,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: widget.fontSize,
          height: widget.lineHeight,
          fontWeight: widget.fontWeight,
          color: defaultColor,
          letterSpacing: 0.3,
        ),
      );
    }

    final words = _words.isNotEmpty
        ? _words
        : widget.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    final activeIdx = widget.highlightedWordIndex != null && words.isNotEmpty
        ? widget.highlightedWordIndex!.clamp(0, words.length - 1)
        : null;

    final litGold = isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF012E2B);
    final completedColor = isDark ? BeyanColors.tone(0xFFFFE599) : BeyanColors.tone(0xFF0A443C);
    final unlitColor = isDark ? Colors.white.withValues(alpha: 0.34) : Colors.black.withValues(alpha: 0.32);

    return Text.rich(
      TextSpan(
        children: [
          for (int i = 0; i < words.length; i++) ...[
            () {
              final isHidden = widget.hiddenWordIndices != null && widget.hiddenWordIndices!.contains(i);
              if (isHidden) {
                return TextSpan(
                  text: ' [ ··· ] ',
                  recognizer: _recognizers != null && i < _recognizers!.length ? _recognizers![i] : null,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: widget.fontSize * 0.82,
                    height: widget.lineHeight,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFFFDF7A),
                    backgroundColor: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.22),
                  ),
                );
              }

              // Apple Music Live Lyrics Tarzı Aktif Kelime: Sağdan Sola (RTL) Harf Harf Altın Işık Dolumu
              if (activeIdx != null && i == activeIdx) {
                final wp = widget.highlightedWordProgress.clamp(0.0, 1.0);
                final sweep = wp * 1.20 - 0.10;
                final leadStop = (sweep - 0.10).clamp(0.0, 1.0);
                final trailStop = (sweep + 0.10).clamp(0.0, 1.0);

                return WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: widget.onWordTap != null ? () => widget.onWordTap!(i) : null,
                    child: Transform.translate(
                      offset: const Offset(0, -1.2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        decoration: BoxDecoration(
                          color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.18 : 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              // Arapça sağdan sola okunduğu için harf harf dolum sağdan sola akar
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
                              fontSize: widget.fontSize * 1.03,
                              height: widget.lineHeight * 0.92,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.65),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Okunmuş veya Henüz Okunmamış Kelimeler
              return TextSpan(
                text: words[i],
                recognizer: _recognizers != null && i < _recognizers!.length ? _recognizers![i] : null,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: widget.fontSize,
                  height: widget.lineHeight,
                  letterSpacing: 0.3,
                  fontWeight: (activeIdx != null && i < activeIdx) ? FontWeight.w600 : widget.fontWeight,
                  color: activeIdx == null
                      ? defaultColor
                      : (i < activeIdx ? completedColor : unlitColor),
                  shadows: (activeIdx != null && i < activeIdx && isDark)
                      ? [
                          Shadow(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              );
            }(),
            if (i < words.length - 1)
              TextSpan(
                text: ' ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: widget.fontSize,
                  height: widget.lineHeight,
                ),
              ),
          ],
        ],
      ),
      textDirection: TextDirection.rtl,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
