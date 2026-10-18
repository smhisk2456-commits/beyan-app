import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/elif_ba/models/elif_ba_letter.dart';
import 'package:islamic_app/features/elif_ba/models/elif_ba_lesson.dart';

void main() {
  group('Elif-Bâ Harfleri ve Ses Dosyaları Testleri', () {
    test('Toplam 28 Arapça harf eksiksiz tanımlı olmalı', () {
      expect(elifBaLettersList.length, 28);
      for (int i = 0; i < elifBaLettersList.length; i++) {
        final letter = elifBaLettersList[i];
        expect(letter.id, i + 1);
        expect(letter.arabic.isNotEmpty, isTrue);
        expect(letter.nameTr.isNotEmpty, isTrue);
        expect(letter.phonetic.isNotEmpty, isTrue);
        expect(letter.mahraj.isNotEmpty, isTrue);
      }
    });

    test('28 harfin tümü için yerel hoca ses kaydı (MP3) mevcut olmalı', () {
      for (final letter in elifBaLettersList) {
        final file = File('assets/audio/letters/letter_${letter.id}.mp3');
        expect(file.existsSync(), isTrue, reason: 'Harf ${letter.id} (${letter.nameTr}) ses dosyası eksik!');
        expect(file.lengthSync(), greaterThan(1000), reason: 'Harf ${letter.id} ses dosyası bozuk veya çok küçük!');
      }
    });
  });

  group('Elif-Bâ Dersleri ve Soru Kalitesi Testleri', () {
    test('Tüm dersler mantıklı seviye ve sorulara sahip olmalı', () {
      expect(elifBaLessonsList.length, 4);

      for (final lesson in elifBaLessonsList) {
        expect(lesson.title.isNotEmpty, isTrue);
        expect(lesson.questions.length, greaterThanOrEqualTo(12), reason: '${lesson.title} en az 12 soru içermelidir');
        expect(lesson.xpReward, greaterThan(0));

        for (final q in lesson.questions) {
          expect(q.questionText.isNotEmpty, isTrue);
          expect(q.arabicPrompt.isNotEmpty, isTrue);
          expect(q.options.length, greaterThanOrEqualTo(4));
          expect(q.correctOptionIndex, inInclusiveRange(0, q.options.length - 1));
          expect(q.explanation.isNotEmpty, isTrue);

          // Sorunun cevabı şıklarda yer almalı ve boş olmamalı
          final correctOpt = q.options[q.correctOptionIndex];
          expect(correctOpt.trim().isNotEmpty, isTrue);
        }
      }
    });
  });
}
