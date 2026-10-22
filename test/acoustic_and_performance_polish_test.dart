import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/core/services/acoustic_audio_service.dart';
import 'package:islamic_app/core/widgets/luxury_page_route.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AcousticAudioService Testleri', () {
    test('Varsayılan ses ayarları aktif olmalı ve singleton doğru çalışmalı', () {
      final service1 = AcousticAudioService.instance;
      final service2 = AcousticAudioService();

      expect(identical(service1, service2), isTrue);
      expect(service1.isZikrSoundEnabled, isTrue);
      expect(service1.isPageFlipSoundEnabled, isTrue);
    });

    test('Ses açma ve kapama kontrolleri doğru güncellenmeli', () {
      final service = AcousticAudioService.instance;

      service.isZikrSoundEnabled = false;
      expect(service.isZikrSoundEnabled, isFalse);

      service.isZikrSoundEnabled = true;
      expect(service.isZikrSoundEnabled, isTrue);

      service.isPageFlipSoundEnabled = false;
      expect(service.isPageFlipSoundEnabled, isFalse);

      service.isPageFlipSoundEnabled = true;
      expect(service.isPageFlipSoundEnabled, isTrue);
    });

    test('playKukaBeadSound ses kapalıyken işlem yapmadan dönmeli', () async {
      final service = AcousticAudioService.instance;
      service.isZikrSoundEnabled = false;

      // Hata fırlatmadan sessizce tamamlanmalı
      await expectLater(service.playKukaBeadSound(), completes);
      service.isZikrSoundEnabled = true;
    });

    test('playParchmentPageFlip ses kapalıyken işlem yapmadan dönmeli', () async {
      final service = AcousticAudioService.instance;
      service.isPageFlipSoundEnabled = false;

      // Hata fırlatmadan sessizce tamamlanmalı
      await expectLater(service.playParchmentPageFlip(), completes);
      service.isPageFlipSoundEnabled = true;
    });
  });

  group('LuxuryPageRoute Testleri', () {
    test('Lüks geçiş rotası 320ms açılış ve 260ms kapanış süresine sahip olmalı', () {
      final route = LuxuryPageRoute(
        page: const Scaffold(body: Text('Test')),
      );

      expect(route.transitionDuration, const Duration(milliseconds: 320));
      expect(route.reverseTransitionDuration, const Duration(milliseconds: 260));
    });
  });
}
