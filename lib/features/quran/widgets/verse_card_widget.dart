import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:islamic_app/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../quran/models/verse.dart';
import '../../quran/widgets/arabic_text_widget.dart';
import '../providers/quran_reading_providers.dart';
import '../services/quran_audio_service.dart';

/// Tek bir ayeti tam olarak gösteren lüks kart widget'ı.
class VerseCard extends ConsumerWidget {
  final Verse verse;
  final String? surahName;
  final bool showSurahReference;
  final bool isHighlighted;
  final bool isPlaying;
  final VoidCallback? onTap;
  final void Function(int wordIndex)? onWordTap;

  const VerseCard({
    super.key,
    required this.verse,
    this.surahName,
    this.showSurahReference = false,
    this.isHighlighted = false,
    this.isPlaying = false,
    this.onTap,
    this.onWordTap,
  });

  void _shareVerse(BuildContext context, AppStrings strings) {
    HapticFeedback.lightImpact();
    final isTr = strings.language == AppLanguage.turkish;
    final meaning = verse.localizedMeaning(strings.language.code);
    final header = isTr
        ? 'Sure No: ${verse.surahId}, Ayet: ${verse.verseNumber}'
        : 'Surah: ${verse.surahId}, Verse: ${verse.verseNumber}';
    final label = isTr ? 'Meali:' : 'Translation:';
    final text = '$header\n\n'
        '${verse.arabicText}\n\n'
        '$label $meaning\n\n'
        '— Beyân';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
            const SizedBox(width: 8),
            Text(strings.verseCopied(verse.reference)),
          ],
        ),
        backgroundColor: BeyanColors.tone(0xFF012E2B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Apple Music Live Lyrics tarzı Harf Harf (Character-by-Character) Okunuş Senkronizasyonu
  Widget _buildTransliterationText(
    BuildContext context,
    bool isDark,
    int? activeWordIndex,
    double wordProgress,
    double verseProgress,
  ) {
    final text = verse.transliteration;
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final baseLitColor = isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF012E2B);
    final completedColor = isDark ? BeyanColors.tone(0xFF80CBC4) : BeyanColors.tone(0xFF0A685A);
    final unlitColor = isDark ? Colors.white.withValues(alpha: 0.30) : Colors.black.withValues(alpha: 0.28);

    if (activeWordIndex == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: completedColor,
          height: 1.55,
        ),
        textAlign: TextAlign.left,
      );
    }

    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return const SizedBox.shrink();
    final clampedIndex = activeWordIndex.clamp(0, words.length - 1);
    final wp = wordProgress.clamp(0.0, 1.0);

    return Text.rich(
      TextSpan(
        children: [
          for (int i = 0; i < words.length; i++) ...[
            if (i < clampedIndex)
              TextSpan(
                text: words[i],
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  height: 1.55,
                  fontWeight: FontWeight.w600,
                  color: completedColor,
                ),
              )
            else if (i > clampedIndex)
              TextSpan(
                text: words[i],
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  height: 1.55,
                  fontWeight: FontWeight.normal,
                  color: unlitColor,
                ),
              )
            else ...[
              // Aktif kelimenin içindeki harfleri Apple Music Live Lyrics gibi harf harf aydınlat
              ...() {
                final word = words[i];
                final len = word.length;
                final exactPos = wp * len;
                final litChars = exactPos.floor().clamp(0, len);
                final frac = (exactPos - litChars).clamp(0.0, 1.0);

                final spans = <InlineSpan>[];
                if (litChars > 0) {
                  spans.add(
                    TextSpan(
                      text: word.substring(0, litChars),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontStyle: FontStyle.italic,
                        height: 1.55,
                        fontWeight: FontWeight.bold,
                        color: baseLitColor,
                        shadows: [
                          Shadow(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.55),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (litChars < len) {
                  spans.add(
                    TextSpan(
                      text: word.substring(litChars, litChars + 1),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontStyle: FontStyle.italic,
                        height: 1.55,
                        fontWeight: FontWeight.bold,
                        color: Color.lerp(unlitColor, baseLitColor, frac) ?? baseLitColor,
                        shadows: [
                          Shadow(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.45 * frac),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  );
                  if (litChars + 1 < len) {
                    spans.add(
                      TextSpan(
                        text: word.substring(litChars + 1),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: unlitColor,
                        ),
                      ),
                    );
                  }
                }
                return spans;
              }(),
            ],
            if (i < words.length - 1)
              const TextSpan(
                text: ' ',
                style: TextStyle(fontSize: 14.0, height: 1.55),
              ),
          ],
        ],
      ),
      textAlign: TextAlign.left,
    );
  }

  /// Meal metni için Apple Music tarzı harf harf (character-by-character) akan senkronizasyon
  Widget _buildLiveSyncedMeaningText(
    BuildContext context,
    String meaning,
    bool isDark,
    bool isActivePlaying,
    double verseProgress,
  ) {
    final defaultColor = isDark ? Colors.white70 : BeyanColors.tone(0xFF334E48);
    if (!isActivePlaying || meaning.isEmpty) {
      return Text(
        meaning,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: 14.0,
              color: defaultColor,
            ),
        textAlign: TextAlign.left,
      );
    }

    final prog = verseProgress.clamp(0.0, 1.0);
    final len = meaning.length;
    final exactChar = prog * len;
    final litCount = exactChar.floor().clamp(0, len);
    final charFrac = (exactChar - litCount).clamp(0.0, 1.0);

    final litColor = isDark ? Colors.white : BeyanColors.tone(0xFF012E2B);
    final activeCharColor = isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFFD4AF37);
    final dimColor = isDark ? Colors.white.withValues(alpha: 0.36) : Colors.black.withValues(alpha: 0.34);

    return Text.rich(
      TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: 14.0,
            ),
        children: [
          if (litCount > 0)
            TextSpan(
              text: meaning.substring(0, litCount),
              style: TextStyle(
                color: litColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (litCount < len) ...[
            TextSpan(
              text: meaning.substring(litCount, litCount + 1),
              style: TextStyle(
                color: Color.lerp(dimColor, activeCharColor, charFrac),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (litCount + 1 < len)
              TextSpan(
                text: meaning.substring(litCount + 1),
                style: TextStyle(
                  color: dimColor,
                ),
              ),
          ],
        ],
      ),
      textAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final strings = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arabicFontSize = ref.watch(arabicFontSizeProvider);
    final isBookmarked = ref.watch(bookmarkedVersesProvider).contains('${verse.surahId}:${verse.verseNumber}');
    final lastRead = ref.watch(lastReadProvider);
    final isLastRead = lastRead?.surahId == verse.surahId && lastRead?.verseNumber == verse.verseNumber;
    final shouldHighlight = isLastRead || isHighlighted || isPlaying;

    final memorizationState = ref.watch(quranMemorizationProvider);
    final isComparativeMealEnabled = ref.watch(comparativeMealProvider);
    final isLoopingThisVerse = ref.watch(
      quranAudioProvider.select((s) => s.loopVerseNumber == verse.verseNumber),
    );

    final allWords = verse.words;
    final revealedSet = memorizationState.revealedWordsByVerse[verse.verseNumber] ?? <int>{};
    final hiddenIndices = memorizationState.isActive
        ? Set<int>.from(List.generate(allWords.length, (i) => i)).difference(revealedSet)
        : null;

    // SADECE ve SADECE bu ayet çalıyorsa ses akış ilerlemesini dinle (diğer tüm ayetler 30 FPS rebuild'den kurtulur!)
    final int? activeWordIndex;
    final double verseProgress;
    final double wordProgress;
    if (isPlaying) {
      final activeAudio = ref.watch(
        quranAudioProvider.select((s) => (
          s.isWordHighlightEnabled ? s.activeWordIndex : null,
          s.verseProgress,
          s.wordProgress,
        )),
      );
      activeWordIndex = activeAudio.$1;
      verseProgress = activeAudio.$2;
      wordProgress = activeAudio.$3;
    } else {
      activeWordIndex = null;
      verseProgress = 0.0;
      wordProgress = 1.0;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isPlaying ? 3 : 0,
      shadowColor: isPlaying ? BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.3) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isPlaying
              ? BeyanColors.tone(0xFFFFDF7A)
              : (shouldHighlight
                  ? BeyanColors.tone(0xFFD4AF37)
                  : (isDark ? BeyanColors.tone(0xFF133B34) : BeyanColors.tone(0xFFE2EBE8))),
          width: isPlaying ? 2.2 : (shouldHighlight ? 1.8 : 1),
        ),
      ),
      color: isPlaying
          ? (isDark ? BeyanColors.tone(0xFF13423A) : BeyanColors.tone(0xFFE8F6F0))
          : (shouldHighlight
              ? (isDark ? BeyanColors.tone(0xFF0F362F) : BeyanColors.tone(0xFFF1F8F5))
              : (isDark ? BeyanColors.tone(0xFF0D2823) : Colors.white)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Ayet Header & İşlem Butonları (Taşma Korumalı Düzen) ──────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        // Daire içinde ayet numarası
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPlaying
                                ? BeyanColors.tone(0xFFFFDF7A)
                                : BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.2 : 0.1),
                            border: Border.all(
                              color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${verse.verseNumber}',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isPlaying
                                    ? BeyanColors.tone(0xFF012E2B)
                                    : (isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF033E35)),
                              ),
                            ),
                          ),
                        ),

                        // Referans Etiketi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            verse.reference,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: BeyanColors.tone(0xFFD4AF37),
                            ),
                          ),
                        ),

                        if (isPlaying)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFFFDF7A),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.graphic_eq_rounded, size: 11.5, color: BeyanColors.tone(0xFF012E2B)),
                                const SizedBox(width: 3.5),
                                Text(
                                  strings.language == AppLanguage.turkish
                                      ? 'Canlı Takip'
                                      : (strings.language == AppLanguage.arabic ? 'يتلى الآن' : 'Live Sync'),
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: BeyanColors.tone(0xFF012E2B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (isLastRead && !isPlaying)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: BeyanColors.tone(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              strings.lastReadBadge,
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 1. Bu Âyeti Sesli Oku / Duraklat Butonu
                  if (onTap != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_outline_rounded,
                        size: 21,
                        color: isPlaying ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFFD4AF37),
                      ),
                      tooltip: isPlaying
                          ? (strings.language == AppLanguage.turkish ? 'Duraklat' : 'Pause')
                          : (strings.language == AppLanguage.turkish ? 'Bu Âyetten Okumayı Başlat' : 'Play From This Verse'),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        if (isPlaying) {
                          ref.read(quranAudioProvider.notifier).togglePlayPause();
                        } else {
                          onTap!();
                        }
                      },
                    ),

                  // 2. Kaldığım Yer Olarak İşaretle
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      isLastRead ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                      size: 19,
                      color: isLastRead ? BeyanColors.tone(0xFFFFDF7A) : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    tooltip: strings.saveAsLastRead,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(lastReadProvider.notifier).savePosition(
                            surahId: verse.surahId,
                            surahName: surahName ?? strings.surahNumberBadge(verse.surahId),
                            verseNumber: verse.verseNumber,
                          );
                    },
                  ),

                  // 3. Favori Yer İmi
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      isBookmarked ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 19,
                      color: isBookmarked ? BeyanColors.tone(0xFFFFDF7A) : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    tooltip: isBookmarked ? strings.removeBookmark : strings.addBookmark,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(bookmarkedVersesProvider.notifier).toggleBookmark(verse.surahId, verse.verseNumber);
                    },
                  ),

                  // 4. Âyet Tekrar Döngüsü Butonu (3x, 5x, 10x, ∞)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(
                      isLoopingThisVerse ? Icons.repeat_one_on_rounded : Icons.repeat_one_rounded,
                      size: 19,
                      color: isLoopingThisVerse ? BeyanColors.tone(0xFFFFDF7A) : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    tooltip: isLoopingThisVerse
                        ? (strings.language == AppLanguage.turkish ? 'Âyet Tekrarını Kapat' : 'Stop Verse Loop')
                        : (strings.language == AppLanguage.turkish ? 'Bu Âyeti Tekrarla' : 'Loop This Verse'),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (isLoopingThisVerse) {
                        ref.read(quranAudioProvider.notifier).setLoopVerse(null);
                      } else {
                        ref.read(quranAudioProvider.notifier).setLoopVerse(verse.verseNumber);
                        if (ref.read(quranAudioProvider).loopRepeatCount <= 1) {
                          ref.read(quranAudioProvider.notifier).setLoopRepeat(3);
                        }
                      }
                    },
                  ),

                  // 5. Paylaş & Kopyala
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: Icon(Icons.share_outlined, size: 18, color: BeyanColors.tone(0xFFD4AF37)),
                    tooltip: strings.shareVerse,
                    onPressed: () => _shareVerse(context, strings),
                  ),
                ],
              ),

              // Ezber Modu Açıkken Ayet İlerleme Rozeti
              if (memorizationState.isActive) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded, size: 14, color: BeyanColors.tone(0xFFFFDF7A)),
                      const SizedBox(width: 6),
                      Text(
                        'Ezber Testi: ${revealedSet.length} / ${allWords.length} kelime açık',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: BeyanColors.tone(0xFFFFDF7A),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (revealedSet.length >= allWords.length) {
                            ref.read(quranMemorizationProvider.notifier).hideAllInVerse(verse.verseNumber);
                          } else {
                            ref.read(quranMemorizationProvider.notifier).revealAllInVerse(verse.verseNumber, allWords.length);
                          }
                        },
                        child: Text(
                          revealedSet.length >= allWords.length ? 'Hepsini Gizle' : 'Tümünü Aç',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: BeyanColors.tone(0xFFFFDF7A),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Ayet İlerleme Çizgisi (Canlı Okunurken)
              if (isPlaying) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: verseProgress.clamp(0.0, 1.0),
                    minHeight: 2.2,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(BeyanColors.tone(0xFFFFDF7A)),
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[
                const SizedBox(height: 14),
              ],

              // ── Arapça Metin (Apple Music Tarzı Kelime & Harf Harf Akış & Ezber Maskesi & Dokun-Atla) ──
              ArabicText(
                verse.arabicText,
                fontSize: arabicFontSize,
                lineHeight: 2.1,
                textAlign: TextAlign.right,
                highlightedWordIndex: activeWordIndex,
                highlightedWordProgress: wordProgress,
                hiddenWordIndices: hiddenIndices,
                onWordTap: (wordIdx) {
                  if (memorizationState.isActive) {
                    HapticFeedback.lightImpact();
                    ref.read(quranMemorizationProvider.notifier).revealWord(verse.verseNumber, wordIdx);
                  } else if (onWordTap != null) {
                    onWordTap!(wordIdx);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Arapça / Latin bölücü çizgi
              Divider(
                color: isDark ? BeyanColors.tone(0xFF1A3D36) : BeyanColors.tone(0xFFE8EEEC),
                thickness: 0.8,
                height: 1,
              ),
              const SizedBox(height: 12),

              // ── Türkçe Okunuş (Apple Music Live Lyrics Tarzı Harf Harf Akışlı) ─
              if (ref.watch(transliterationProvider) && verse.transliteration != null && verse.transliteration!.isNotEmpty) ...[
                _buildTransliterationText(context, isDark, activeWordIndex, wordProgress, verseProgress),
                const SizedBox(height: 10),
              ],

              // ── Birincil Meal (Canlı Okuma Sırasında Harf Harf Aydınlanan) ───
              _buildLiveSyncedMeaningText(
                context,
                verse.localizedMeaning(strings.language.code),
                isDark,
                isPlaying,
                verseProgress,
              ),

              // ── Çift Mealli Karşılaştırma Kutusu ──────────────────
              if (isComparativeMealEnabled) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? BeyanColors.tone(0xFF042B24) : BeyanColors.tone(0xFFE8F2EF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.compare_arrows_rounded, size: 14, color: BeyanColors.tone(0xFFD4AF37)),
                          const SizedBox(width: 5),
                          Text(
                            strings.language == AppLanguage.turkish
                                ? 'Saheeh International (İngilizce Karşılaştırmalı)'
                                : 'Turkish Translation (Diyanet Comparative)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: BeyanColors.tone(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.language == AppLanguage.turkish
                            ? (verse.meaningEn ?? verse.turkishMeaning)
                            : verse.turkishMeaning,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
