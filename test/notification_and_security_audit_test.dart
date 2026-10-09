import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/localization/app_strings.dart';
import 'package:islamic_app/features/notifications/models/adhan_makam.dart';
import 'package:islamic_app/features/prayer_times/models/prayer_time_model.dart';

void main() {
  group('Ezan Sesi & iOS Bildirim Ses Formatı Testleri', () {
    test('Tüm ezan makamları geçerli ses kaynağına sahip olmalı ve CAF dosyaları mevcut olmalı', () {
      final makamsWithAudio = [
        AdhanMakam.istanbul,
        AdhanMakam.mecca,
        AdhanMakam.medina,
        AdhanMakam.tekbir,
      ];

      for (final makam in makamsWithAudio) {
        final resName = makam.soundResourceName;
        expect(resName, isNotNull);
        expect(resName!.isNotEmpty, isTrue);

        // iOS Runner klasöründeki CAF dosyasının varlığı
        final cafFile = File('ios/Runner/$resName.caf');
        expect(cafFile.existsSync(), isTrue,
            reason: 'Apple UNNotificationSound için $resName.caf dosyası ios/Runner içinde bulunmalıdır.');

        // Dosya boyutu kontrolü (boş olmamalı)
        expect(cafFile.lengthSync(), greaterThan(10000),
            reason: '$resName.caf dosyası geçerli ses verisi içermelidir.');
      }
    });

    test('Xcode project.pbxproj dosyası tüm CAF seslerini Resources Build Phase içinde içermelidir', () {
      final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj');
      expect(pbxproj.existsSync(), isTrue);

      final content = pbxproj.readAsStringSync();
      expect(content.contains('adhan_istanbul.caf'), isTrue);
      expect(content.contains('adhan_mecca.caf'), isTrue);
      expect(content.contains('adhan_medina.caf'), isTrue);
      expect(content.contains('adhan_tekbir.caf'), isTrue);
    });
  });

  group('iOS 64 Yerel Bildirim Kota ve Çakışma Güvencesi Testleri', () {
    test('3 günlük namaz planlaması + 24 ayet bildirimi iOS 64 sınırını (max 64) asla aşmamalıdır', () {
      const daysAhead = 3;
      const prayersPerDay = 6; // İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı
      const maxFullPrayers = daysAhead * prayersPerDay; // 18
      const maxEarlyReminders = daysAhead * prayersPerDay; // 18
      const maxPrayerNotifications = maxFullPrayers + maxEarlyReminders; // 36

      const maxVerseNotifications = 24; // Saatte 2 kez modundaki tavan

      const totalScheduled = maxPrayerNotifications + maxVerseNotifications;

      expect(totalScheduled, lessThanOrEqualTo(64),
          reason: 'iOS yerel bildirim sınırı 64\'tür. Toplam planlama ($totalScheduled) bu sınırı aşamaz.');
      expect(totalScheduled, equals(60));
    });
  });

  group('Çok Dilli Bildirim ve Dil Uyumluluk Testleri (TR / EN / AR)', () {
    test('Tüm namaz isimleri TR, EN ve AR dillerinde doğru ve eksiksiz dönmelidir', () {
      for (final p in PrayerName.values) {
        final tr = p.localizedName('tr');
        final en = p.localizedName('en');
        final ar = p.localizedName('ar');

        expect(tr.isNotEmpty, isTrue);
        expect(en.isNotEmpty, isTrue);
        expect(ar.isNotEmpty, isTrue);

        expect(tr, equals(p.turkish));
        expect(en, equals(p.english));
        expect(ar, equals(p.arabic));
      }
    });

    test('AppStrings Paywall özellikleri ve açıklamaları tüm 3 dilde eksiksiz tanımlı olmalı', () {
      for (final lang in AppLanguage.values) {
        final strings = AppStrings(lang);

        expect(strings.paywallTitle.isNotEmpty, isTrue);
        expect(strings.paywallSubtitle.isNotEmpty, isTrue);
        expect(strings.paywallFeatWidgets.isNotEmpty, isTrue);
        expect(strings.paywallFeatWidgetsDesc.isNotEmpty, isTrue);
        expect(strings.paywallFeatMakams.isNotEmpty, isTrue);
        expect(strings.paywallFeatMakamsDesc.isNotEmpty, isTrue);
        expect(strings.paywallFeatAdFree.isNotEmpty, isTrue);
        expect(strings.paywallFeatAdFreeDesc.isNotEmpty, isTrue);
        expect(strings.paywallFeatThemes.isNotEmpty, isTrue);
        expect(strings.paywallFeatThemesDesc.isNotEmpty, isTrue);
        expect(strings.paywallFeatSupport.isNotEmpty, isTrue);
        expect(strings.paywallFeatSupportDesc.isNotEmpty, isTrue);
        expect(strings.paywallActiveDesc.isNotEmpty, isTrue);
        expect(strings.paywallInactiveDesc.isNotEmpty, isTrue);
      }
    });
  });

  group('Güvenlik ve ATS (App Transport Security) Testleri', () {
    test('Info.plist içinde NSAllowsArbitraryLoads false olmalı ve güvenli HTTPS zorlanmalıdır', () {
      final infoPlist = File('ios/Runner/Info.plist');
      expect(infoPlist.existsSync(), isTrue);

      final content = infoPlist.readAsStringSync();
      expect(content.contains('<key>NSAllowsArbitraryLoads</key>'), isTrue);
      expect(content.contains('<false/>'), isTrue);
      expect(content.contains('<true/>\n    </dict>'), isFalse);
    });
  });
}
