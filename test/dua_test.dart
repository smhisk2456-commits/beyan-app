import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/features/dua/data/verified_duas_data.dart';
import 'package:islamic_app/features/dua/models/dua_model.dart';
import 'package:islamic_app/features/dua/providers/dua_providers.dart';

void main() {
  group('Dua Kütüphanesi Model ve Veri Testleri', () {
    test('Tüm 12 kategori tanımlı ve en az 1 dua içermeli', () {
      expect(DuaCategory.values.length, 12);

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

    test('Önemli dualar (Âyetü\'l-Kürsî, Nazar, Sübhaneke, Şifa, İnşirah) listede eksiksiz bulunmalı', () {
      final ayetelKursi = verifiedDuasList.where((d) => d.id == 'kuran_ayetel_kursi').toList();
      expect(ayetelKursi.isNotEmpty, isTrue);
      expect(ayetelKursi.first.title.contains('Ayetel Kürsi'), isTrue);
      expect(ayetelKursi.first.arabicText.contains('الْحَيُّ الْقَيُّومُ'), isTrue);

      final nazar = verifiedDuasList.where((d) => d.id == 'gunluk_nazar_duasi').toList();
      expect(nazar.isNotEmpty, isTrue);

      final subhaneke = verifiedDuasList.where((d) => d.id == 'gunluk_subhaneke').toList();
      expect(subhaneke.isNotEmpty, isTrue);

      final sifa = verifiedDuasList.where((d) => d.id == 'sikinti_sifa_duasi').toList();
      expect(sifa.isNotEmpty, isTrue);

      final insirah = verifiedDuasList.where((d) => d.id == 'kuran_insirah').toList();
      expect(insirah.isNotEmpty, isTrue);
    });

    test('Arama normalizasyonu ayetel kursi, nazar duası, subhaneke gibi sorguları doğru bulmalı', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // "ayetel kursi" araması
      container.read(duaSearchQueryProvider.notifier).state = 'ayetel kursi';
      var results = container.read(filteredDuasListProvider);
      expect(results.any((d) => d.id == 'kuran_ayetel_kursi'), isTrue);

      // "nazar duasi" araması
      container.read(duaSearchQueryProvider.notifier).state = 'nazar duasi';
      results = container.read(filteredDuasListProvider);
      expect(results.any((d) => d.id == 'gunluk_nazar_duasi'), isTrue);

      // "subhaneke" araması
      container.read(duaSearchQueryProvider.notifier).state = 'subhaneke';
      results = container.read(filteredDuasListProvider);
      expect(results.any((d) => d.id == 'gunluk_subhaneke'), isTrue);

      // "sifa duasi" araması
      container.read(duaSearchQueryProvider.notifier).state = 'sifa duasi';
      results = container.read(filteredDuasListProvider);
      expect(results.any((d) => d.id == 'sikinti_sifa_duasi'), isTrue);

      // "rabbi yessir" araması
      container.read(duaSearchQueryProvider.notifier).state = 'rabbi yessir';
      results = container.read(filteredDuasListProvider);
      expect(results.any((d) => d.id == 'sikinti_rabbi_yessir'), isTrue);
    });
  });
}
