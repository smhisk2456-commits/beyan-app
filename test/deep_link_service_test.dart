import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService URI Parsing & Normalization', () {
    test('Namaz derin linki doğru algılanmalı', () {
      final uri = Uri.parse('beyan://prayer?homeWidget=true');
      expect(uri.scheme, equals('beyan'));
      expect(uri.host, equals('prayer'));
      expect(uri.queryParameters['homeWidget'], equals('true'));
    });

    test('Ayet derin linki query parametrelerini doğru taşımalı', () {
      final uri = Uri.parse('beyan://verse?homeWidget=true&surah=2&verse=153&ref=Bakara%202:153');
      expect(uri.scheme, equals('beyan'));
      expect(uri.host, equals('verse'));
      expect(uri.queryParameters['surah'], equals('2'));
      expect(uri.queryParameters['verse'], equals('153'));
      expect(uri.queryParameters['ref'], equals('Bakara 2:153'));
    });

    test('DeepLinkService singleton örneği geçerli olmalı', () {
      expect(DeepLinkService.instance, isNotNull);
      expect(DeepLinkService(), same(DeepLinkService.instance));
    });

    test('ref parametresindeki ayet bilgisi bayat query parametrelerini ezmeli (İnşirâh 94:6)', () {
      final uri = Uri.parse('beyan://verse?homeWidget=true&surah=2&verse=153&ref=%C4%B0n%C5%9Fir%C3%A2h%2094:6');
      final target = DeepLinkService.parseVerseTarget(uri);
      expect(target.surahId, equals(94));
      expect(target.verseNum, equals(6));
    });

    test('Bakara 2:153 doğru ayrıştırılmalı', () {
      final uri = Uri.parse('beyan://verse?homeWidget=true&surah=2&verse=153&ref=Bakara%202:153');
      final target = DeepLinkService.parseVerseTarget(uri);
      expect(target.surahId, equals(2));
      expect(target.verseNum, equals(153));
    });

    test('Tâhâ 20:25-26 aralık formatı ilk ayeti doğru almalı', () {
      final uri = Uri.parse('beyan://verse?homeWidget=true&surah=20&verse=25&ref=T%C3%A2h%C3%A2%2020:25-26');
      final target = DeepLinkService.parseVerseTarget(uri);
      expect(target.surahId, equals(20));
      expect(target.verseNum, equals(25));
    });

    test('Arapça rakamlı ref doğru dönüştürülüp ayrıştırılmalı', () {
      final uri = Uri.parse('beyan://verse?homeWidget=true&ref=%D8%A7%D9%84%D8%B1%D8%B9%D8%AF%20%D9%A1%D9%A3:%D9%A2%D9%A8');
      final target = DeepLinkService.parseVerseTarget(uri);
      expect(target.surahId, equals(13));
      expect(target.verseNum, equals(28));
    });

    test('Sadece query parametreleri olduğunda surahId ve verseNum alınmalı', () {
      final uri = Uri.parse('beyan://verse?homeWidget=true&surah=36&verse=1');
      final target = DeepLinkService.parseVerseTarget(uri);
      expect(target.surahId, equals(36));
      expect(target.verseNum, equals(1));
    });

    test('Sadece sure adı ve ayet numarası ("İnşirah 6") olduğunda doğru tespit edilmeli', () {
      final uri = Uri.parse('beyan://verse?homeWidget=true&ref=%C4%B0n%C5%9Firah%206');
      final target = DeepLinkService.parseVerseTarget(uri);
      expect(target.surahNameQuery, equals('İnşirah'));
      expect(target.verseNum, equals(6));
    });

    test('normalizeArabicDigits tüm 0-9 Arapça rakamlarını dönüştürmeli', () {
      expect(DeepLinkService.normalizeArabicDigits('٠١٢٣٤٥٦٧٨٩'), equals('0123456789'));
    });
  });
}
