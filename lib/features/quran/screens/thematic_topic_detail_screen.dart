import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/beyan_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/luxury_page_route.dart';
import '../models/quran_thematic_topic.dart';
import '../models/surah.dart';
import '../providers/quran_providers.dart';
import '../services/quran_audio_service.dart';
import '../widgets/arabic_text_widget.dart';
import '../widgets/quran_audio_player_bar.dart';
import 'surah_detail_screen.dart';

/// Tematik Konu Detay Ekranı – Seçilen konuya ait tüm âyetleri, meallerini,
/// tefekkür hikmetlerini ve sesli tilavetlerini lüks arayüzle sunar.
class ThematicTopicDetailScreen extends ConsumerStatefulWidget {
  final QuranThematicTopic topic;

  const ThematicTopicDetailScreen({
    super.key,
    required this.topic,
  });

  @override
  ConsumerState<ThematicTopicDetailScreen> createState() => _ThematicTopicDetailScreenState();
}

class _ThematicTopicDetailScreenState extends ConsumerState<ThematicTopicDetailScreen> {
  int? _currentlyPlayingVerseIndex;

  void _openInMushaf(ThematicVerseEntry verse) async {
    HapticFeedback.lightImpact();
    final allSurahs = ref.read(allSurahsProvider).valueOrNull ?? [];
    Surah? targetSurah;
    for (final s in allSurahs) {
      if (s.id == verse.surahId) {
        targetSurah = s;
        break;
      }
    }

    if (targetSurah != null && mounted) {
      Navigator.push(
        context,
        LuxuryPageRoute(
          page: SurahDetailScreen(
            surah: targetSurah,
            initialScrollToVerse: verse.verseNumber,
          ),
        ),
      );
    }
  }

  void _playVerse(ThematicVerseEntry verse, int index) async {
    HapticFeedback.mediumImpact();
    final audioNotifier = ref.read(quranAudioProvider.notifier);
    final audioState = ref.read(quranAudioProvider);

    // Eğer bu sure ve âyet şu an çalıyorsa durdur/başlat
    if (audioState.currentSurahId == verse.surahId &&
        audioState.isPlaying &&
        audioState.activeVerseNumber == verse.verseNumber) {
      audioNotifier.togglePlayPause();
      setState(() => _currentlyPlayingVerseIndex = null);
      return;
    }

    setState(() => _currentlyPlayingVerseIndex = index);

    // Sure ayetlerini getir ve yalnızca bu seçili ayeti tekil aralık olarak çal
    final verses = await ref.read(quranRepositoryProvider).getVersesBySurah(verse.surahId);
    if (mounted) {
      audioNotifier.playVerseRange(
        verses,
        from: verse.verseNumber,
        to: verse.verseNumber,
        surahName: verse.surahNameTr,
      );
    }
  }

  void _copyVerse(ThematicVerseEntry verse, AppStrings strings) {
    HapticFeedback.lightImpact();
    final text = '${verse.arabicText}\n\n'
        '${verse.turkishMeaning}\n\n'
        '— ${verse.reference} (${widget.topic.titleTr})\n\n'
        'Beyân Kur\'an ve İbadet Uygulaması';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
            const SizedBox(width: 8),
            Text(strings.language == AppLanguage.turkish ? 'Âyet ve meali panoya kopyalandı' : 'Verse copied to clipboard'),
          ],
        ),
        backgroundColor: BeyanColors.tone(0xFF012E2B),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareVerse(ThematicVerseEntry verse) {
    HapticFeedback.lightImpact();
    final text = '${verse.arabicText}\n\n'
        '${verse.turkishMeaning}\n\n'
        '— ${verse.reference} (${widget.topic.titleTr})\n\n'
        'Beyân — İslami Yaşam & Kur\'an Rehberi';
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final effectivePalette = ref.watch(effectivePaletteProvider);
    BeyanColors.setPalette(effectivePalette);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = ref.watch(appStringsProvider);
    // Yüksek FPS için yalnızca gerekli audio state parçalarını izle (tüm audioState değil)
    final isPlayingAny = ref.watch(quranAudioProvider.select((s) => s.isPlaying));
    final currentSurahId = ref.watch(quranAudioProvider.select((s) => s.currentSurahId));
    final activeVerseNumber = ref.watch(quranAudioProvider.select((s) => s.activeVerseNumber));
    final topic = widget.topic;
    final topicColor = Color(topic.primaryColorHex);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Lüks Başlık SliverAppBar ───────────────────────────────────────
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: isDark ? BeyanColors.tone(0xFF011C18) : topicColor.withValues(alpha: 0.9),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  tooltip: strings.language == AppLanguage.turkish ? 'Geri Dön' : 'Back',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).maybePop();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.fromLTRB(54, 0, 16, 14),
                  title: Text(
                    topic.titleTr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Arka Plan Gradyanı
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              topicColor.withValues(alpha: isDark ? 0.45 : 0.85),
                              isDark ? BeyanColors.tone(0xFF011814) : BeyanColors.tone(0xFF01362E),
                            ],
                          ),
                        ),
                      ),
                      // Mihrab & İslami Geometri Halesi
                      Positioned(
                        right: -30,
                        top: 20,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: topicColor.withValues(alpha: 0.18),
                          ),
                        ),
                      ),
                      // İkon ve Başlık İçeriği
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.5),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Icon(topic.icon, color: BeyanColors.tone(0xFFFFDF7A), size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.4)),
                                          ),
                                          child: Text(
                                            '${topic.verses.length} Âyet-i Kerîme',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: BeyanColors.tone(0xFFFFDF7A),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          topic.subtitleTr,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.5,
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tefekkür & Hikmet Rehberi Kartı ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [BeyanColors.tone(0xFF032620), BeyanColors.tone(0xFF011814)]
                            : [const Color(0xFFFBF8EE), const Color(0xFFF3ECE0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.lightbulb_outline_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.language == AppLanguage.turkish ? 'Tefekkür & Hikmet Notu' : 'Contemplation Insight',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF034A3E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                topic.contemplationNote,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Âyetler Başlığı ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    children: [
                      Icon(Icons.auto_stories_rounded, size: 16, color: BeyanColors.tone(0xFFD4AF37)),
                      const SizedBox(width: 8),
                      Text(
                        strings.language == AppLanguage.turkish
                            ? 'Bu Konudaki Temel Âyetler'
                            : 'Key Verses on This Theme',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${topic.verses.length} Âyet',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: BeyanColors.tone(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Âyet Kartları Listesi ─────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final verse = topic.verses[index];
                      final isPlayingThis = (currentSurahId == verse.surahId &&
                          isPlayingAny &&
                          (_currentlyPlayingVerseIndex == index || activeVerseNumber == verse.verseNumber));

                      return _buildThematicVerseCard(
                        context: context,
                        verse: verse,
                        index: index,
                        isPlaying: isPlayingThis,
                        isDark: isDark,
                        strings: strings,
                        topicColor: topicColor,
                      );
                    },
                    childCount: topic.verses.length,
                  ),
                ),
              ),
            ],
          ),

          // Alt Mini Tilavet Çubuğu
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: QuranAudioPlayerBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildThematicVerseCard({
    required BuildContext context,
    required ThematicVerseEntry verse,
    required int index,
    required bool isPlaying,
    required bool isDark,
    required AppStrings strings,
    required Color topicColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? BeyanColors.tone(0xFF04201A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying
              ? BeyanColors.tone(0xFFFFDF7A)
              : BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.35 : 0.22),
          width: isPlaying ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: isPlaying ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Kart Üst Çubuğu (Sure Adı & Âyet Numarası & Mushaf'ta Aç Butonu) ────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? BeyanColors.tone(0xFF021613)
                  : BeyanColors.tone(0xFFF7F5EE),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              border: Border(
                bottom: BorderSide(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.25 : 0.18),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                // Numara Rozeti
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: topicColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: topicColor.withValues(alpha: 0.5)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: topicColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Sure ve Âyet Adı
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${verse.surahNameTr} Suresi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFF034A3E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ' • ${verse.verseNumber}. Âyet',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  verse.surahNameAr,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: BeyanColors.tone(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),

          // ── Arapça Mushaf Metni ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? BeyanColors.tone(0xFF011411).withValues(alpha: 0.6)
                    : const Color(0xFFFBF9F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: isDark ? 0.15 : 0.12),
                ),
              ),
              child: ArabicText(
                verse.arabicText,
                fontSize: 22,
                lineHeight: 2.1,
                textAlign: TextAlign.right,
                color: isDark ? const Color(0xFFF5EFE1) : const Color(0xFF1E293B),
              ),
            ),
          ),

          // ── Türkçe Meâl Metni ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              verse.turkishMeaning,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: isDark ? Colors.white.withValues(alpha: 0.88) : const Color(0xFF1F2937),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          // ── Bu Âyetin Mesajı / Hikmet Kutusu ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: topicColor.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: topicColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: topicColor, size: 15),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      verse.insight,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // ── Alt İşlem Düğmeleri (Dinle, Mushaf'ta Aç, Kopyala, Paylaş) ──────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                // 1. Dinle / Durdur
                TextButton.icon(
                  onPressed: () => _playVerse(verse, index),
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: isPlaying ? BeyanColors.tone(0xFFFFDF7A) : topicColor,
                    size: 20,
                  ),
                  label: Text(
                    isPlaying
                        ? (strings.language == AppLanguage.turkish ? 'Çalıyor' : 'Playing')
                        : (strings.language == AppLanguage.turkish ? 'Dinle' : 'Listen'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPlaying ? BeyanColors.tone(0xFFFFDF7A) : topicColor,
                    ),
                  ),
                ),

                // 2. Mushaf'ta Aç
                TextButton.icon(
                  onPressed: () => _openInMushaf(verse),
                  icon: Icon(Icons.menu_book_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 17),
                  label: Text(
                    strings.language == AppLanguage.turkish ? 'Mushaf\'ta Aç' : 'In Mushaf',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: BeyanColors.tone(0xFFD4AF37),
                    ),
                  ),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 3. Kopyala
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      color: isDark ? Colors.white60 : Colors.black54,
                      tooltip: strings.language == AppLanguage.turkish ? 'Kopyala' : 'Copy',
                      onPressed: () => _copyVerse(verse, strings),
                    ),

                    // 4. Paylaş
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 17),
                      color: isDark ? Colors.white60 : Colors.black54,
                      tooltip: strings.language == AppLanguage.turkish ? 'Paylaş' : 'Share',
                      onPressed: () => _shareVerse(verse),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
