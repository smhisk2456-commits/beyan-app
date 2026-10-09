/// Beyân Premium Üyelik Paketleri
enum PremiumTier {
  /// Aylık Abonelik
  monthly,

  /// Yıllık Abonelik (En Popüler - %45 Tasarruf)
  yearly,

  /// Ömür Boyu Tek Seferlik (Beyân Hâmisi)
  lifetime,
}

extension PremiumTierExtension on PremiumTier {
  String get productId {
    switch (this) {
      case PremiumTier.monthly:
        return 'beyan_premium_monthly';
      case PremiumTier.yearly:
        return 'beyan_premium_yearly';
      case PremiumTier.lifetime:
        return 'beyan_premium_lifetime';
    }
  }

  String get title {
    switch (this) {
      case PremiumTier.monthly:
        return 'Aylık Abonelik';
      case PremiumTier.yearly:
        return 'Yıllık Abonelik';
      case PremiumTier.lifetime:
        return 'Ömür Boyu Hâmî';
    }
  }

  String get defaultPriceText {
    switch (this) {
      case PremiumTier.monthly:
        return '₺49,99 / ay';
      case PremiumTier.yearly:
        return '₺249,99 / yıl';
      case PremiumTier.lifetime:
        return '₺499,99 (Tek Seferlik)';
    }
  }

  String get badgeText {
    switch (this) {
      case PremiumTier.monthly:
        return '';
      case PremiumTier.yearly:
        return '%58 İNDİRİM';
      case PremiumTier.lifetime:
        return 'EN DEĞERLİ';
    }
  }

  String get subtitle {
    switch (this) {
      case PremiumTier.monthly:
        return 'İstediğiniz zaman iptal edebilirsiniz';
      case PremiumTier.yearly:
        return 'Ayda yalnızca ~₺20,83 (3 Gün Ücretsiz Deneme)';
      case PremiumTier.lifetime:
        return 'Bir kez ödeyin, sonsuza dek reklamsız kullanın';
    }
  }
}
