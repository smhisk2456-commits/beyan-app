import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Arapça metinler için merkezi tipografi widget'ı.
///
/// Neden ayrı bir widget?
/// - Amiri fontu zorunluluğunu tek noktada garanti eder.
/// - `textDirection: TextDirection.rtl` her seferinde unutulmaz.
/// - Satır yüksekliği (height: 2.0) harekeler için standarttır.
/// - Tema değişimine karşı izole edilmiştir.
/// - Canlı tilavet sırasında kelime kelime öne çıkarma (karaoke) destekler.
class ArabicText extends StatefulWidget {
  final String text;
  final double fontSize;

  /// Harekelerin üst/alt satıra taşmaması için geniş tutulur.
  /// Varsayılan: 2.0 — küçülürse harekeler kesişebilir!
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

  /// Kelimeye tıklandığında tilavette o kelimeye atlama callback'i.
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
    if (oldWidget.text != widget.text || (oldWidget.onWordTap == null) != (widget.onWordTap == null)) {
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
    if (widget.highlightedWordIndex != null || widget.onWordTap != null) {
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

    // Canlı kelime takibi veya kelime dokunma yoksa standart ve hafif Text döndür
    if (widget.highlightedWordIndex == null && widget.onWordTap == null) {
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

    return Text.rich(
      TextSpan(
        children: [
          for (int i = 0; i < words.length; i++) ...[
            TextSpan(
              text: words[i],
              recognizer: _recognizers != null && i < _recognizers!.length ? _recognizers![i] : null,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: widget.fontSize,
                height: widget.lineHeight,
                letterSpacing: 0.3,
                fontWeight: (widget.highlightedWordIndex == i)
                    ? FontWeight.bold
                    : widget.fontWeight,
                color: (widget.highlightedWordIndex == null)
                    ? defaultColor
                    : (widget.highlightedWordIndex == i
                        ? (isDark ? const Color(0xFFFFDF7A) : const Color(0xFF012E2B))
                        : (i < widget.highlightedWordIndex!
                            ? (isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF0A443C))
                            : (isDark ? Colors.white38 : Colors.black38))),
                backgroundColor: (widget.highlightedWordIndex == i)
                    ? (isDark
                        ? const Color(0xFFD4AF37).withValues(alpha: 0.42)
                        : const Color(0xFFFFDF7A).withValues(alpha: 0.75))
                    : null,
              ),
            ),
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
