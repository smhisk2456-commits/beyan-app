import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/elif_ba_lesson.dart';
import '../models/elif_ba_letter.dart';
import '../services/elif_ba_progress_service.dart';
import '../services/elif_ba_audio_service.dart';
import 'elif_ba_lesson_quiz_screen.dart';

class ElifBaHubScreen extends ConsumerStatefulWidget {
  const ElifBaHubScreen({super.key});

  @override
  ConsumerState<ElifBaHubScreen> createState() => _ElifBaHubScreenState();
}

class _ElifBaHubScreenState extends ConsumerState<ElifBaHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    ElifBaAudioService().stop();
    _tabController.dispose();
    super.dispose();
  }

  void _showLetterDetail(BuildContext context, ElifBaLetter letter, bool isDark) {
    HapticFeedback.lightImpact();
    ElifBaAudioService().playLetter(letter.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? BeyanColors.tone(0xFF022B24) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Large Letter Display (Tap to speak)
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ElifBaAudioService().playLetter(letter.id);
                  },
                  borderRadius: BorderRadius.circular(45),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [BeyanColors.tone(0xFFFFDF7A), BeyanColors.tone(0xFFB8860B)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.35),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          letter.arabic,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 52,
                            color: BeyanColors.tone(0xFF01201B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Icon(Icons.volume_up_rounded, size: 16, color: BeyanColors.tone(0xFF01201B)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Letter Name & Phonetic with Speaker Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${letter.nameTr}  (${letter.nameEn})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.volume_up_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 24),
                      tooltip: 'Sesli Dinle',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ElifBaAudioService().playLetter(letter.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Telaffuz: "${letter.phonetic}"',
                  style: TextStyle(
                    color: BeyanColors.tone(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // 4 Yazılış Formu (Yalın, Başta, Ortada, Sonda - Her biri tıklanınca seslendirir)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? BeyanColors.tone(0xFF063B32) : BeyanColors.tone(0xFFF1F8F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFormItem('Yalın', letter.isolated, letter.id),
                      _buildFormItem('Başta', letter.initial, letter.id),
                      _buildFormItem('Ortada', letter.medial, letter.id),
                      _buildFormItem('Sonda', letter.finalForm, letter.id),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mahreç Bilgisi
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? BeyanColors.tone(0xFF03221C) : BeyanColors.tone(0xFFE8F6F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.mic_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Mahreç (Çıkış Yeri):',
                            style: TextStyle(
                              color: BeyanColors.tone(0xFFFFDF7A),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        letter.mahraj,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Kur'an'dan Örnek Kelime (Tıklanınca kelimeyi seslendirir)
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ElifBaAudioService().speakArabic(letter.exampleWord);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Örnek Kelime: ', style: TextStyle(color: Colors.white60, fontSize: 13)),
                        Text(
                          letter.exampleWord,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: BeyanColors.tone(0xFFFFDF7A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.volume_up_rounded, size: 16, color: BeyanColors.tone(0xFFFFDF7A)),
                        const SizedBox(width: 4),
                        Text('(${letter.exampleMeaning})', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormItem(String label, String form, int letterId) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ElifBaAudioService().playLetter(letterId);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Text(
              form,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                color: BeyanColors.tone(0xFFFFDF7A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  void _onLessonTap(ElifBaLesson lesson, bool isUnlocked) {
    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önceki dersi tamamlayın.'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ElifBaLessonQuizScreen(lesson: lesson)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(elifBaProgressProvider);

    return Scaffold(
      backgroundColor: isDark ? BeyanColors.tone(0xFF021B16) : BeyanColors.tone(0xFFF4F8F6),
      appBar: AppBar(
        backgroundColor: isDark ? BeyanColors.tone(0xFF012720) : AppColors.teal,
        elevation: 0,
        title: const Text(
          'Sesli Elif-Bâ & Dua Eğitimi',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // XP Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: BeyanColors.tone(0xFFFFDF7A)),
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${progress.totalXp} XP',
                  style: TextStyle(
                    color: BeyanColors.tone(0xFFFFDF7A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Streak Badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orangeAccent),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 16),
                const SizedBox(width: 2),
                Text(
                  '${progress.streakDays}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BeyanColors.tone(0xFFFFDF7A),
          indicatorWeight: 3,
          labelColor: BeyanColors.tone(0xFFFFDF7A),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.alt_route_rounded), text: 'Öğrenim Haritası'),
            Tab(icon: Icon(Icons.grid_view_rounded), text: '28 Harf & Mahreç'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── 1. Tab: Duolingo Stili İlerleme Haritası ───────
          _buildRoadmap(isDark, progress),

          // ── 2. Tab: 28 Harf ve Mahreç Tablosu ─────────────
          _buildLetterGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildRoadmap(bool isDark, ElifBaProgressState progress) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: elifBaLessonsList.length,
      itemBuilder: (context, index) {
        final lesson = elifBaLessonsList[index];
        final isCompleted = progress.completedLessonIds.contains(lesson.id);
        final isPreviousCompleted = index == 0 || progress.completedLessonIds.contains(elifBaLessonsList[index - 1].id);
        final isUnlocked = isPreviousCompleted;

        return Column(
          children: [
            // Roadmap Node Card
            InkWell(
              onTap: () => _onLessonTap(lesson, isUnlocked),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [BeyanColors.tone(0xFF0F4D3F), BeyanColors.tone(0xFF09362C)]
                        : (isUnlocked
                            ? [BeyanColors.tone(0xFF135A4A), BeyanColors.tone(0xFF0A3D32)]
                            : [isDark ? BeyanColors.tone(0xFF07241E) : BeyanColors.tone(0xFFE5EDE9), isDark ? BeyanColors.tone(0xFF041814) : BeyanColors.tone(0xFFD6E2DD)]),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCompleted
                        ? BeyanColors.tone(0xFFFFDF7A)
                        : (isUnlocked
                            ? BeyanColors.tone(0xFFD4AF37)
                            : (isDark ? Colors.white12 : Colors.black12)),
                    width: isUnlocked || isCompleted ? 1.8 : 1,
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.15),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Node Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? BeyanColors.tone(0xFFFFDF7A)
                            : (isUnlocked
                                ? BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25)
                                : Colors.black26),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? BeyanColors.tone(0xFFFFDF7A) : BeyanColors.tone(0xFFD4AF37),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : (isUnlocked
                                  ? Icons.play_arrow_rounded
                                  : Icons.lock_outline_rounded),
                          color: isCompleted
                              ? BeyanColors.tone(0xFF01201B)
                              : (isUnlocked ? BeyanColors.tone(0xFFFFDF7A) : Colors.white38),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Lesson Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnlocked || isCompleted ? Colors.white : Colors.white38,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: isUnlocked || isCompleted ? Colors.white70 : Colors.white30,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.bolt_rounded, size: 14, color: BeyanColors.tone(0xFFFFDF7A)),
                              const SizedBox(width: 2),
                              Text(
                                '+${lesson.xpReward} XP',
                                style: TextStyle(
                                  color: BeyanColors.tone(0xFFFFDF7A),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${lesson.questions.length} Soru',
                                style: TextStyle(
                                  color: isUnlocked || isCompleted ? Colors.white60 : Colors.white24,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: isUnlocked || isCompleted ? BeyanColors.tone(0xFFFFDF7A) : Colors.white24,
                    ),
                  ],
                ),
              ),
            ),

            // Connecting line to next node
            if (index < elifBaLessonsList.length - 1)
              Container(
                width: 3,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? BeyanColors.tone(0xFFFFDF7A)
                      : (isDark ? BeyanColors.tone(0xFF0B3F34) : BeyanColors.tone(0xFFD0DDD8)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLetterGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: elifBaLettersList.length,
      itemBuilder: (context, index) {
        final letter = elifBaLettersList[index];
        return InkWell(
          onTap: () => _showLetterDetail(context, letter, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? BeyanColors.tone(0xFF06332A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: 13,
                    color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.6),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        letter.arabic,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 34,
                          color: BeyanColors.tone(0xFFFFDF7A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        letter.nameTr,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        letter.phonetic,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
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
    );
  }
}
