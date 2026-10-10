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
  });
}
