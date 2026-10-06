import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/dua/models/dua_model.dart';

void main() {
  group('Dua Kütüphanesi Model ve Veri Testleri', () {
    test('Tüm 10 kategori tanımlı ve en az 1 dua içermeli', () {
      expect(DuaCategory.values.length, 10);

      for (final cat in DuaCategory.values) {
        final matches = verifiedDuasList.where((d) => d.category == cat).toList();
        expect(
          matches.isNotEmpty,
          isTrue,
          reason: '${cat.trName} kategorisi en az 1 doğrulanmış dua içermelidir',
        );
      }
    });

    test('Her duanın başlık, Arapça metin, meal ve kaynak referansı doğrulanmış olmalı', () {
      for (final dua in verifiedDuasList) {
        expect(dua.id.isNotEmpty, isTrue);
        expect(dua.title.isNotEmpty, isTrue);
        expect(dua.arabicText.isNotEmpty, isTrue);
        expect(dua.turkishMeaning.isNotEmpty, isTrue);
        expect(dua.reference.isNotEmpty, isTrue);
      }
    });

    test('DuaItem serialization toMap ve fromMap simetrisi korunmalı', () {
      final sample = verifiedDuasList.first;
      final map = sample.toMap();
      final reconstructed = DuaItem.fromMap(map);

      expect(reconstructed.id, sample.id);
      expect(reconstructed.category, sample.category);
      expect(reconstructed.title, sample.title);
      expect(reconstructed.arabicText, sample.arabicText);
      expect(reconstructed.turkishMeaning, sample.turkishMeaning);
      expect(reconstructed.reference, sample.reference);
    });

    test('DuaItem copyWith ile favori durumu değiştirilebilmeli', () {
      final sample = verifiedDuasList.first;
      expect(sample.isFavorite, isFalse);

      final favorited = sample.copyWith(isFavorite: true);
      expect(favorited.isFavorite, isTrue);
      expect(favorited.id, sample.id);
    });
  });
}
