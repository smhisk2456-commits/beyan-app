import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_app/features/quran/models/quran_thematic_topic.dart';
import 'package:islamic_app/features/quran/screens/thematic_atlas_screen.dart';
import 'package:islamic_app/features/quran/screens/thematic_topic_detail_screen.dart';

void main() {
  group('Tematik Kur\'an Fihristi & Kavram Atlası Model Testleri', () {
    test('quranThematicTopicsList temel konuları ve doğrulanmış âyetleri içermelidir', () {
      expect(quranThematicTopicsList.length, greaterThanOrEqualTo(12));

      // Sabır, Rızık, Şifa, Tevbe, Aile ve Adalet konuları mevcut olmalı
      final topicIds = quranThematicTopicsList.map((t) => t.id).toSet();
      expect(topicIds.contains('sabir_ve_tevekkul'), isTrue);
      expect(topicIds.contains('rizik_ve_bereket'), isTrue);
      expect(topicIds.contains('sifa_ve_huzur'), isTrue);
      expect(topicIds.contains('tevbe_ve_magfiret'), isTrue);
      expect(topicIds.contains('zor_zamanlar_ve_insirah'), isTrue);
      expect(topicIds.contains('anne_baba_ve_aile'), isTrue);
      expect(topicIds.contains('adalet_ve_ihsan'), isTrue);
      expect(topicIds.contains('cennet_ve_ahiret'), isTrue);
      expect(topicIds.contains('dua_ve_munacat'), isTrue);

      for (final topic in quranThematicTopicsList) {
        expect(topic.titleTr.isNotEmpty, isTrue);
        expect(topic.subtitleTr.isNotEmpty, isTrue);
        expect(topic.verses.isNotEmpty, isTrue);
        expect(topic.contemplationNote.isNotEmpty, isTrue);
        expect(topic.searchKeywords.isNotEmpty, isTrue);

        for (final verse in topic.verses) {
          expect(verse.surahId, inInclusiveRange(1, 114));
          expect(verse.verseNumber, greaterThan(0));
          expect(verse.arabicText.isNotEmpty, isTrue);
          expect(verse.turkishMeaning.isNotEmpty, isTrue);
          expect(verse.insight.isNotEmpty, isTrue);
          expect(verse.reference.contains(verse.surahNameTr), isTrue);
        }
      }
    });

    test('matchesQuery aksan, büyük/küçük harf ve anahtar kelime duyarsız doğru eşleşmeli', () {
      final sabirTopic = quranThematicTopicsList.firstWhere((t) => t.id == 'sabir_ve_tevekkul');
      expect(sabirTopic.matchesQuery('sabır'), isTrue);
      expect(sabirTopic.matchesQuery('SABIR'), isTrue);
      expect(sabirTopic.matchesQuery('tevekkül'), isTrue);
      expect(sabirTopic.matchesQuery('metanet'), isTrue);
      expect(sabirTopic.matchesQuery('bakara'), isTrue);

      final sifaTopic = quranThematicTopicsList.firstWhere((t) => t.id == 'sifa_ve_huzur');
      expect(sifaTopic.matchesQuery('şifa'), isTrue);
      expect(sifaTopic.matchesQuery('SIFA'), isTrue);
      expect(sifaTopic.matchesQuery('huzur'), isTrue);
      expect(sifaTopic.matchesQuery('kalp'), isTrue);

      final rizikTopic = quranThematicTopicsList.firstWhere((t) => t.id == 'rizik_ve_bereket');
      expect(rizikTopic.matchesQuery('rızık'), isTrue);
      expect(rizikTopic.matchesQuery('bereket'), isTrue);
      expect(rizikTopic.matchesQuery('şükür'), isTrue);

      final aileTopic = quranThematicTopicsList.firstWhere((t) => t.id == 'anne_baba_ve_aile');
      expect(aileTopic.matchesQuery('anne'), isTrue);
      expect(aileTopic.matchesQuery('baba'), isTrue);
      expect(aileTopic.matchesQuery('evlat'), isTrue);
    });
  });

  group('Tematik Kur\'an Atlası Widget Testleri', () {
    testWidgets('ThematicAtlasScreen başlıkları ve kategori filtre çiplerini listeler', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ThematicAtlasScreen(),
          ),
        ),
      );
      await tester.pump();

      // Başlık ve arama çubuğu görünmeli
      expect(find.text('Tematik Kur\'an Fihristi'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Kategori filtre çipleri mevcut olmalı
      expect(find.textContaining('Tümü'), findsOneWidget);
      expect(find.text('Zor Zamanlar & Şifa'), findsOneWidget);
      expect(find.text('Ahlak & Aile'), findsOneWidget);
      expect(find.text('İbadet & Ahiret'), findsOneWidget);

      // Tematik kartlar ekranda belirmeli
      expect(find.text('Sabır ve Tevekkül'), findsOneWidget);
      expect(find.text('Rızık, Bereket ve Helal Kazanç'), findsOneWidget);
    });

    testWidgets('ThematicTopicDetailScreen âyetleri, Arapça metinleri ve hikmet kartlarını sunar', (tester) async {
      final sampleTopic = quranThematicTopicsList.firstWhere((t) => t.id == 'sabir_ve_tevekkul');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ThematicTopicDetailScreen(topic: sampleTopic),
          ),
        ),
      );
      await tester.pump();

      // Başlık ve Tefekkür kartı
      expect(find.text(sampleTopic.titleTr), findsWidgets);
      expect(find.text('Tefekkür & Hikmet Notu'), findsOneWidget);
      expect(find.text(sampleTopic.contemplationNote), findsOneWidget);

      // Âyet kartları ve butonlar
      expect(find.textContaining('Bakara Suresi'), findsWidgets);
      expect(find.textContaining('Dinle'), findsWidgets);
      expect(find.textContaining('Mushaf\'ta Aç'), findsWidgets);
    });
  });
}
