import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/premium_product.dart';

/// Beyân Uygulama İçi Satın Alma (In-App Purchase) ve Premium Servisi
class PremiumService {
  static final PremiumService instance = PremiumService._internal();
  factory PremiumService() => instance;
  PremiumService._internal();

  static const String keyIsPremium = 'beyan_is_premium';
  static const String keyTier = 'beyan_premium_tier';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPremium = false;
  PremiumTier? _activeTier;
  final _changeController = StreamController<bool>.broadcast();

  bool get isPremium => _isPremium;
  PremiumTier? get activeTier => _activeTier;
  Stream<bool> get premiumStatusStream => _changeController.stream;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  /// Servisi başlatır, yerel SharedPreferences durumunu ve mağaza bağlantısını yükler.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(keyIsPremium) ?? false;
    final tierStr = prefs.getString(keyTier);
    if (tierStr != null) {
      try {
        _activeTier = PremiumTier.values.firstWhere((t) => t.name == tierStr);
      } catch (_) {}
    }

    // Satın alma akışını dinle
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint('InAppPurchase stream hatası: $error');
      },
    );

    // Mağazadaki ürünleri sorgula (çevrimiçi ise)
    await loadProducts();
  }

  /// Mağazadaki ürün listesini getirir.
  Future<void> loadProducts() async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('In-App Purchase mağazası şu anda kullanılamıyor.');
        return;
      }

      final ids = PremiumTier.values.map((t) => t.productId).toSet();
      final response = await _iap.queryProductDetails(ids);

      if (response.error != null) {
        debugPrint('Ürün sorgulama hatası: ${response.error}');
        return;
      }

      _products = response.productDetails;
    } catch (e) {
      debugPrint('Ürünler yüklenirken hata: $e');
    }
  }

  /// Belirtilen paketi satın alma sürecini başlatır.
  Future<bool> buyTier(PremiumTier tier) async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('Mağaza mevcut değil.');
        return false;
      }

      ProductDetails? product;
      try {
        product = _products.firstWhere((p) => p.id == tier.productId);
      } catch (_) {
        // Ürün mağazada henüz aktifleşmemişse (Sandbox/Geliştirici testi)
        product = null;
      }

      if (product == null) {
        debugPrint('Ürün detayları bulunamadı: ${tier.productId}');
        return false;
      }

      final purchaseParam = PurchaseParam(productDetails: product);

      if (tier == PremiumTier.lifetime) {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      return true;
    } catch (e) {
      debugPrint('Satın alma başlatma hatası: $e');
      return false;
    }
  }

  /// Önceki satın alımları geri yükler (Apple App Store kuralı).
  Future<bool> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('Satın alımları geri yükleme hatası: $e');
      return false;
    }
  }

  /// Satın alma akışındaki güncellemeleri işler.
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Satın alma doğrulandı
        PremiumTier tier = PremiumTier.yearly;
        for (final t in PremiumTier.values) {
          if (t.productId == purchase.productID) {
            tier = t;
            break;
          }
        }
        await _setPremium(true, tier: tier);

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Satın alma hatası: ${purchase.error}');
      }
    }
  }

  /// Premium durumunu günceller ve kaydeder.
  Future<void> _setPremium(bool premium, {PremiumTier? tier}) async {
    _isPremium = premium;
    _activeTier = tier;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsPremium, premium);
    if (tier != null) {
      await prefs.setString(keyTier, tier.name);
    } else {
      await prefs.remove(keyTier);
    }
    _changeController.add(premium);
  }

  /// Geliştirici ve test modu için Premium'u açıp kapatma (Testflight / Emülatör testi)
  Future<void> toggleDevPremium() async {
    final next = !_isPremium;
    await _setPremium(next, tier: next ? PremiumTier.lifetime : null);
  }

  void dispose() {
    _subscription?.cancel();
    _changeController.close();
  }
}
