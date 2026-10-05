import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/quran/models/models.dart';

/// Phase 2 – Model Unit Testleri
void main() {
  // ── Surah Model Testleri ────────────────────────────────────
  group('Surah Model', () {
    final testMap = {
      'id': 1,
      'name_arabic': 'الفاتحة',
      'name_turkish': 'Fatiha',
      'name_english': 'The Opening',
      'verse_count': 7,
      'revelation_type': 'meccan',
    };

    test('fromMap doğru şekilde ayrıştırır', () {
      final surah = Surah.fromMap(testMap);
      expect(surah.id, equals(1));
      expect(surah.nameArabic, equals('الفاتحة'));
      expect(surah.nameTurkish, equals('Fatiha'));
      expect(surah.verseCount, equals(7));
    });

    test('isMeccan getter doğru çalışır', () {
      final meccan = Surah.fromMap(testMap);
      expect(meccan.isMeccan, isTrue);
      expect(meccan.revelationLabel, equals('Mekki'));
    });

    test('Medeni sure doğru tanınır', () {
      final medani = Surah.fromMap({...testMap, 'revelation_type': 'medinan'});
      expect(medani.isMeccan, isFalse);
      expect(medani.revelationLabel, equals('Medeni'));
    });

    test('verseCountLabel doğru döner', () {
      final surah = Surah.fromMap(testMap);
      expect(surah.verseCountLabel, equals('7 ayet'));
    });

    test('eşitlik karşılaştırması id\'ye göre çalışır', () {
      final s1 = Surah.fromMap(testMap);
      final s2 = Surah.fromMap(testMap);
      expect(s1, equals(s2));
    });

    test('toMap fromMap ile simetrik çalışır', () {
      final surah = Surah.fromMap(testMap);
      final map = surah.toMap();
      expect(map['id'], equals(testMap['id']));
      expect(map['name_arabic'], equals(testMap['name_arabic']));
    });
  });

  // ── Verse Model Testleri ────────────────────────────────────
  group('Verse Model', () {
    final testMap = {
      'id': 1,
      'surah_id': 1,
      'verse_number': 1,
      'arabic_text': 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
      'transliteration': 'Bismillâhirrahmânirrahîm',
      'turkish_meaning': 'Rahman ve Rahim olan Allah\'ın adıyla',
    };

    test('fromMap doğru şekilde ayrıştırır', () {
      final verse = Verse.fromMap(testMap);
      expect(verse.surahId, equals(1));
      expect(verse.verseNumber, equals(1));
      expect(verse.arabicText, isNotEmpty);
      expect(verse.transliteration, isNotNull);
    });

    test('reference getter doğru format döner', () {
      final verse = Verse.fromMap(testMap);
      expect(verse.reference, equals('1:1'));
    });

    test('verseMarker Arapça semboller içerir', () {
      final verse = Verse.fromMap(testMap);
      expect(verse.verseMarker, contains('﴿'));
      expect(verse.verseMarker, contains('﴾'));
    });

    test('transliteration null olabilir', () {
      final map = {...testMap, 'transliteration': null};
      final verse = Verse.fromMap(map);
      expect(verse.transliteration, isNull);
    });
  });

  // ── DailyDua Model Testleri ─────────────────────────────────
  group('DailyDua Model', () {
    final testMap = {
      'id': 1,
      'arabic_text': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
      'transliteration': 'Rabbenâ âtinâ fiddünyâ haseneten',
      'turkish_meaning': 'Rabbimiz! Bize dünyada iyilik ver.',
      'reference': 'Bakara Suresi, 201. Ayet',
    };

    test('fromMap doğru şekilde ayrıştırır', () {
      final dua = DailyDua.fromMap(testMap);
      expect(dua.id, equals(1));
      expect(dua.arabicText, isNotEmpty);
      expect(dua.reference, contains('Bakara'));
    });

    test('eşitlik karşılaştırması id\'ye göre çalışır', () {
      final d1 = DailyDua.fromMap(testMap);
      final d2 = DailyDua.fromMap(testMap);
      expect(d1, equals(d2));
    });
  });
}
