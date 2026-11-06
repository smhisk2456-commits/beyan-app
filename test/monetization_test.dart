import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islamic_app/features/ai_assistant/services/ai_assistant_service.dart';
import 'package:islamic_app/features/monetization/models/premium_product.dart';
import 'package:islamic_app/features/monetization/providers/premium_provider.dart';
import 'package:islamic_app/features/monetization/services/ad_service.dart';
import 'package:islamic_app/features/monetization/services/premium_service.dart';

class _MockInAppPurchasePlatform extends InAppPurchasePlatform {
  @override
  Stream<List<PurchaseDetails>> get purchaseStream => const Stream.empty();
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) async =>
      ProductDetailsResponse(productDetails: [], notFoundIDs: identifiers.toList());
  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async => true;
  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam, bool autoConsume = true}) async => true;
  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}
  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}
  @override
  Future<String> countryCode() async => 'TR';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    InAppPurchasePlatform.instance = _MockInAppPurchasePlatform();
  });

  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('Monetization Model Testleri', () {
    test('Tüm Premium paketleri doğru ID ve başlığa sahip olmalı', () {
      expect(PremiumTier.values.length, 3);

      expect(PremiumTier.monthly.productId, 'beyan_premium_monthly');
      expect(PremiumTier.yearly.productId, 'beyan_premium_yearly');
      expect(PremiumTier.lifetime.productId, 'beyan_premium_lifetime');

      expect(PremiumTier.monthly.title, 'Aylık Abonelik');
      expect(PremiumTier.yearly.title, 'Yıllık Abonelik');
      expect(PremiumTier.lifetime.title, 'Ömür Boyu Hâmî');

      expect(PremiumTier.yearly.badgeText, '%60 İNDİRİM');
      expect(PremiumTier.lifetime.badgeText, 'EN DEĞERLİ');
    });

    test('AdService singleton ve test reklam ID geçerli olmalı', () {
      final s1 = AdService.instance;
      final s2 = AdService();
      expect(identical(s1, s2), isTrue);

      expect(AdService.iosRewardedInterstitialId, 'ca-app-pub-1904469452707859/4068589472');
      expect(AdService.iosTestRewardedInterstitialId, isNotEmpty);
      expect(AdService.androidTestRewardedInterstitialId, isNotEmpty);

      // Geçici reklamsız kullanım testi
      s1.updateAdFreeStatus(false);
      expect(s1.isAdFree, isFalse);
      s1.grantTemporaryAdFree(const Duration(hours: 1));
      expect(s1.isAdFree, isTrue);
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

    test('PremiumService varsayılan olarak kilitli olmalı ve deneme ile açılabilmeli', () async {
      SharedPreferences.setMockInitialValues({});
      final service = PremiumService.instance;

      expect(service.hasWidgetAccess, isTrue);
      expect(await service.shouldShowLaunchPaywall(), isFalse);

      // 3 Günlük ücretsiz deneme başlatıldığında Premium aktif olmalı
      await service.activateFreeTrial();
      expect(service.isPremium, isTrue);
      expect(service.isTrialActive, isTrue);
    });

    test('AiAssistantNotifier.grantBonusQuestions ödüllü reklam sonrası soru hakkını doğru artırmalı', () async {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      SharedPreferences.setMockInitialValues({
        'beyan_ai_daily_count': 3,
        'beyan_ai_daily_date': todayStr,
      });

      final notifier = AiAssistantNotifier();
      await notifier.refreshQuota(false);
      expect(notifier.state.remainingQuestions, 0);

      // +3 Soru hakkı ver
      await notifier.grantBonusQuestions(3);
      expect(notifier.state.remainingQuestions, 3);
    });
  });
}
