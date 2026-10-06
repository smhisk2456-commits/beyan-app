import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/features/monetization/models/premium_product.dart';
import 'package:islamic_app/features/monetization/providers/premium_provider.dart';
import 'package:islamic_app/features/monetization/services/ad_service.dart';
import 'package:islamic_app/features/monetization/services/premium_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Monetization Model Testleri', () {
    test('Tüm Premium paketleri doğru ID ve başlığa sahip olmalı', () {
      expect(PremiumTier.values.length, 3);

      expect(PremiumTier.monthly.productId, 'beyan_premium_monthly');
      expect(PremiumTier.yearly.productId, 'beyan_premium_yearly');
      expect(PremiumTier.lifetime.productId, 'beyan_premium_lifetime');

      expect(PremiumTier.monthly.title, 'Aylık Abonelik');
      expect(PremiumTier.yearly.title, 'Yıllık Abonelik');
      expect(PremiumTier.lifetime.title, 'Ömür Boyu Hâmî');

      expect(PremiumTier.yearly.badgeText, '%45 İNDİRİM');
      expect(PremiumTier.lifetime.badgeText, 'EN DEĞERLİ');
    });

    test('AdService singleton ve test reklam ID geçerli olmalı', () {
      final s1 = AdService.instance;
      final s2 = AdService();
      expect(identical(s1, s2), isTrue);

      final unitId = s1.bannerAdUnitId;
      expect(unitId, isNotNull);
    });

    test('PremiumState copyWith ve durum yönetimi doğru çalışmalı', () {
      const state = PremiumState(isPremium: false);
      expect(state.isPremium, isFalse);

      final updated = state.copyWith(
        isPremium: true,
        activeTier: PremiumTier.yearly,
      );
      expect(updated.isPremium, isTrue);
      expect(updated.activeTier, PremiumTier.yearly);
    });

    test('PremiumService SharedPreferences üzerinden varsayılan false dönmeli', () async {
      SharedPreferences.setMockInitialValues({});
      final service = PremiumService.instance;
      await service.initialize();

      expect(service.isPremium, isFalse);
      expect(service.activeTier, isNull);
    });
  });
}
