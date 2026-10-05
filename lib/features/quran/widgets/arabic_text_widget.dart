import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Arapça metinler için merkezi tipografi widget'ı.
///
/// Neden ayrı bir widget?
/// - Amiri fontu zorunluluğunu tek noktada garanti eder.
/// - `textDirection: TextDirection.rtl` her seferinde unutulmaz.
/// - Satır yüksekliği (height: 2.0) harekeler için standarttır.
/// - Tema değişimine karşı izole edilmiştir.
class ArabicText extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark
        ? AppColors.arabicTextDark
        : AppColors.arabicText;

    return Text(
      text,
      // Arapça için RTL yönü zorunludur.
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: fontSize,
        // Geniş satır aralığı → hareke işaretleri birbirine girmez
        height: lineHeight,
        fontWeight: fontWeight,
        color: color ?? defaultColor,
        // Arapça için kern ve ligatures
        letterSpacing: 0.3,
      ),
    );
  }
}
