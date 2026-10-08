import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../quran/models/verse.dart';
import '../../quran/widgets/arabic_text_widget.dart';
import '../providers/quran_reading_providers.dart';

/// Tek bir ayeti tam olarak gösteren lüks kart widget'ı.
class VerseCard extends ConsumerWidget {
  final Verse verse;
  final bool showSurahReference;
  final VoidCallback? onTap;

  const VerseCard({
    super.key,
    required this.verse,
    this.showSurahReference = false,
    this.onTap,
  });

  void _shareVerse(BuildContext context, AppStrings strings) {
    HapticFeedback.lightImpact();
    final text = 'Sure No: ${verse.surahId}, Ayet: ${verse.verseNumber}\n\n'
        '${verse.arabicText}\n\n'
        'Meali: ${verse.turkishMeaning}\n\n'
        '— Beyân İslami Yaşam';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFFFDF7A), size: 18),
            const SizedBox(width: 8),
            Text(strings.verseCopied(verse.reference)),
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
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arabicFontSize = ref.watch(arabicFontSizeProvider);
    final isBookmarked = ref.watch(bookmarkedVersesProvider).contains('${verse.surahId}:${verse.verseNumber}');
    final lastRead = ref.watch(lastReadProvider);
    final isLastRead = lastRead?.surahId == verse.surahId && lastRead?.verseNumber == verse.verseNumber;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isLastRead
              ? const Color(0xFFFFDF7A)
              : (isDark ? const Color(0xFF133B34) : const Color(0xFFE2EBE8)),
          width: isLastRead ? 1.6 : 1,
        ),
      ),
      color: isLastRead
          ? (isDark ? const Color(0xFF0F362F) : const Color(0xFFF1F8F5))
          : (isDark ? const Color(0xFF0D2823) : Colors.white),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Ayet Header & İşlem Butonları ─────────────────
              Row(
                children: [
                  // Daire içinde ayet numarası
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.2 : 0.1),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${verse.verseNumber}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFFDF7A) : const Color(0xFF033E35),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  if (isLastRead)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        strings.lastReadBadge,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),

                  const Spacer(),

                  // Referans Etiketi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      verse.reference,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),

                  // Kaldığım Yer Olarak İşaretle
                  IconButton(
                    icon: Icon(
                      isLastRead ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                      size: 20,
                      color: isLastRead ? const Color(0xFFFFDF7A) : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    tooltip: strings.saveAsLastRead,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(lastReadProvider.notifier).savePosition(
                            surahId: verse.surahId,
                            surahName: strings.surahNumberBadge(verse.surahId),
                            verseNumber: verse.verseNumber,
                          );
                    },
                  ),

                  // Favori Yer İmi
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 20,
                      color: isBookmarked ? const Color(0xFFFFDF7A) : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    tooltip: isBookmarked ? strings.removeBookmark : strings.addBookmark,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(bookmarkedVersesProvider.notifier).toggleBookmark(verse.surahId, verse.verseNumber);
                    },
                  ),

                  // Paylaş & Kopyala
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 19, color: Color(0xFFD4AF37)),
                    tooltip: strings.shareVerse,
                    onPressed: () => _shareVerse(context, strings),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Arapça Metin ─────────────────────────────────
              ArabicText(
                verse.arabicText,
                fontSize: arabicFontSize,
                lineHeight: 2.1,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 14),

              // Arapça / Latin bölücü çizgi
              Divider(
                color: isDark ? const Color(0xFF1A3D36) : const Color(0xFFE8EEEC),
                thickness: 0.8,
                height: 1,
              ),
              const SizedBox(height: 12),

              // ── Türkçe Okunuş (Transliterasyon) ─────────────
              if (verse.transliteration != null && verse.transliteration!.isNotEmpty) ...[
                Text(
                  verse.transliteration!,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFF80CBC4) : const Color(0xFF0A685A),
                    height: 1.55,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
              ],

              // ── Türkçe Meal ──────────────────────────────────
              Text(
                verse.turkishMeaning,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      fontSize: 14.0,
                      color: isDark ? Colors.white70 : const Color(0xFF334E48),
                    ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
