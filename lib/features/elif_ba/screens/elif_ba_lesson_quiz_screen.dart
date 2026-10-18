import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/elif_ba_lesson.dart';
import '../services/elif_ba_progress_service.dart';
import '../services/elif_ba_audio_service.dart';

class ElifBaLessonQuizScreen extends ConsumerStatefulWidget {
  final ElifBaLesson lesson;

  const ElifBaLessonQuizScreen({super.key, required this.lesson});

  @override
  ConsumerState<ElifBaLessonQuizScreen> createState() => _ElifBaLessonQuizScreenState();
}

class _ElifBaLessonQuizScreenState extends ConsumerState<ElifBaLessonQuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctAnswersCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final question = widget.lesson.questions[_currentQuestionIndex];
      if (question.autoPlayAudio) {
        _speakCurrentPrompt();
      }
    });
  }

  @override
  void dispose() {
    ElifBaAudioService().stop();
    super.dispose();
  }

  void _speakCurrentPrompt() {
    final question = widget.lesson.questions[_currentQuestionIndex];
    final target = (question.audioTarget != null && question.audioTarget!.isNotEmpty)
        ? question.audioTarget!
        : question.arabicPrompt;
    if (target.isNotEmpty) {
      ElifBaAudioService().speakArabic(target);
    }
  }

  void _handleOptionSelect(int index) {
    if (_hasAnswered) return;

    final question = widget.lesson.questions[_currentQuestionIndex];
    final isCorrect = index == question.correctOptionIndex;
    final selectedOpt = question.options[index];

    // Doğru ya da seçilen soru harfini hoca sesiyle dinlet
    final target = (question.audioTarget != null && question.audioTarget!.isNotEmpty)
        ? question.audioTarget!
        : question.arabicPrompt;
    if (target.isNotEmpty) {
      ElifBaAudioService().speakArabic(target);
    } else if (RegExp(r'[\u0600-\u06FF]').hasMatch(selectedOpt)) {
      ElifBaAudioService().speakArabic(selectedOpt);
    }

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (isCorrect) {
        _correctAnswersCount++;
      }
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex + 1 < widget.lesson.questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final nextQuestion = widget.lesson.questions[_currentQuestionIndex];
        if (nextQuestion.autoPlayAudio) {
          _speakCurrentPrompt();
        }
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    ref.read(elifBaProgressProvider.notifier).completeLesson(
          widget.lesson.id,
          widget.lesson.xpReward,
        );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF022B24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFFFDF7A), width: 1.5),
        ),
        title: const Column(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFDF7A), size: 48),
            SizedBox(height: 10),
            Text(
              'Tebrikler! Ders Tamamlandı',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFDF7A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.lesson.questions.length} sorudan $_correctAnswersCount tanesini doğru bildiniz.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDF7A).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFDF7A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFFFDF7A), size: 22),
                  const SizedBox(width: 6),
                  Text(
                    '+${widget.lesson.xpReward} XP Kazanıldı!',
                    style: const TextStyle(
                      color: Color(0xFFFFDF7A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDF7A),
                foregroundColor: const Color(0xFF01201B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Dialogu kapat
                Navigator.pop(context); // Hub ekranına dön
              },
              child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalQuestions = widget.lesson.questions.length;
    final question = widget.lesson.questions[_currentQuestionIndex];
    final isCorrect = _selectedOptionIndex == question.correctOptionIndex;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF01201B) : const Color(0xFFF6FAF8),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF01201B) : AppColors.teal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.lesson.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentQuestionIndex + (_hasAnswered ? 1 : 0)) / totalQuestions,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFDF7A)),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soru ${_currentQuestionIndex + 1} / $totalQuestions',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: Color(0xFFFFDF7A), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.lesson.xpReward} XP',
                          style: const TextStyle(
                            color: Color(0xFFFFDF7A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question Title
              Text(
                question.questionText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),

              // Large Arabic Prompt Card (Tıklayınca hoca sesiyle okur)
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _speakCurrentPrompt();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF04332B), const Color(0xFF07241E)]
                          : [const Color(0xFFE8F5F1), Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          question.arabicPrompt,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 54,
                            color: Color(0xFFFFDF7A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDF7A).withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up_rounded,
                            size: 18,
                            color: Color(0xFFFFDF7A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Options
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final opt = question.options[index];
                    final isSelected = _selectedOptionIndex == index;
                    final isOptionCorrect = index == question.correctOptionIndex;

                    Color cardBorderColor = isDark ? const Color(0xFF0D3830) : const Color(0xFFE2EBE8);
                    Color cardBgColor = isDark ? const Color(0xFF062B24) : Colors.white;

                    if (_hasAnswered) {
                      if (isOptionCorrect) {
                        cardBorderColor = Colors.greenAccent;
                        cardBgColor = Colors.green.withValues(alpha: 0.15);
                      } else if (isSelected && !isCorrect) {
                        cardBorderColor = Colors.redAccent;
                        cardBgColor = Colors.red.withValues(alpha: 0.15);
                      }
                    } else if (isSelected) {
                      cardBorderColor = const Color(0xFFFFDF7A);
                    }

                    return InkWell(
                      onTap: () => _handleOptionSelect(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cardBorderColor,
                            width: isSelected || (_hasAnswered && isOptionCorrect) ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF0F3E34) : const Color(0xFFE2EBE8),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index), // A, B, C, D
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFFFDF7A) : AppColors.teal,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (_hasAnswered && isOptionCorrect)
                              const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                            if (_hasAnswered && isSelected && !isCorrect)
                              const Icon(Icons.cancel_rounded, color: Colors.redAccent),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Feedback & Next Button
              if (_hasAnswered) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                        color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFFFFDF7A), size: 22),
                        tooltip: 'Tekrar Dinle',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _speakCurrentPrompt();
                        },
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF01201B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestionIndex + 1 < totalQuestions ? 'Sonraki Soru →' : 'Sonucu Gör ✨',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
