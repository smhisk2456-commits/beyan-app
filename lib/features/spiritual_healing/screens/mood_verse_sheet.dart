import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/localization/app_strings.dart';
import '../../../main.dart';
import '../../quran/repositories/quran_repository.dart';
import '../../quran/screens/surah_detail_screen.dart';
import '../../verse_studio/screens/verse_card_studio_screen.dart';
import '../models/mood_verse_model.dart';

/// Ruh Haline Göre Âyet & Şifa Modal Bottom Sheet
class MoodVerseSheet extends ConsumerWidget {
  final MoodVerseData data;

  const MoodVerseSheet({
    super.key,
    required this.data,
  });

  static void show(BuildContext context, MoodVerseData data) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoodVerseSheet(data: data),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final lang = strings.language.code;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF02211C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFFD4AF37), width: 1.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 25,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 14),

            // Header (Mood Emoji + Title + Close)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.accentColor.withValues(alpha: 0.2),
                      border: Border.all(
                        color: data.accentColor.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        data.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.localizedTitle(lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data.surahRef,
                          style: const TextStyle(
                            color: Color(0xFFFFDF7A),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Divider(color: Colors.white10, height: 1),

            // Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Âyet-i Kerîme Arapça Kartı ────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF03332B), Color(0xFF01201A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            data.arabicText,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 20,
                              height: 1.8,
                              color: Color(0xFFFFDF7A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            height: 1,
                            width: 100,
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            data.localizedTranslation(lang),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Peygamber Efendimiz'in (s.a.v.) Duası ───────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF082721),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF2DD4BF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Color(0xFF2DD4BF), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Şifâ Duası (Hadis-i Şerif)',
                                style: TextStyle(
                                  color: Color(0xFF2DD4BF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            data.propheticDua,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              height: 1.45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Kalbe Ferahlık (Tefekkür) ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.favorite_rounded, color: Color(0xFFFFDF7A), size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Kalbe Ferahlık',
                                style: TextStyle(
                                  color: Color(0xFFFFDF7A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.localizedReflection(lang),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Eylem Butonları ────────────────────────────────────
                    Row(
                      children: [
                        // 1. Hikaye & Duvar Kağıdı Yap Butonu
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VerseCardStudioScreen(
                                    initialReference: data.surahRef,
                                    initialArabic: data.arabicText,
                                    initialMeaning: data.localizedTranslation(lang),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.style_rounded, size: 18),
                            label: const Text(
                              'Hikaye / Duvar Kağıdı',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF01201D),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 2. Kur'an'da Oku Butonu
                        IconButton.filled(
                          onPressed: () async {
                            final repo = QuranRepository();
                            final surah = await repo.getSurahById(data.surahId);
                            if (context.mounted && surah != null) {
                              Navigator.pop(context);
                              ref.read(selectedTabProvider.notifier).state = 2;
                              Navigator.of(context).popUntil((route) => route.isFirst);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahDetailScreen(
                                    surah: surah,
                                    initialScrollToVerse: data.verseNumber,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF0F3E33),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: const Color(0xFF2DD4BF).withValues(alpha: 0.4)),
                            ),
                          ),
                          tooltip: 'Kur\'an\'da Oku',
                        ),
                        const SizedBox(width: 6),

                        // 3. Paylaş Butonu
                        IconButton.filled(
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text: '${data.arabicText}\n\n"${data.localizedTranslation(lang)}"\n\n— ${data.surahRef}\n\nBeyân Uygulaması',
                              ),
                            );
                          },
                          icon: const Icon(Icons.share_rounded, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          tooltip: 'Paylaş',
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
    );
  }
}
