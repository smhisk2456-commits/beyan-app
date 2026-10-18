import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../models/premium_product.dart';
import '../providers/premium_provider.dart';
import '../services/premium_service.dart';

/// Ramazan-ı Şerif ve Kadir Gecesi %50 Özel Teklif Pop-up Ekranı
class RamadanSpecialOfferSheet extends ConsumerStatefulWidget {
  const RamadanSpecialOfferSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RamadanSpecialOfferSheet(),
    );
  }

  @override
  ConsumerState<RamadanSpecialOfferSheet> createState() =>
      _RamadanSpecialOfferSheetState();
}

class _RamadanSpecialOfferSheetState
    extends ConsumerState<RamadanSpecialOfferSheet> {
  bool _isLoading = false;

  Future<void> _purchaseLifetime() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      final success =
          await PremiumService.instance.buyTier(PremiumTier.lifetime);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satın alma başlatılamadı. Lütfen App Store / Play Store bağlantınızı kontrol edin.'),
            backgroundColor: Color(0xFF033E35),
          ),
        );
      } else if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    try {
      final success = await PremiumService.instance.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Satın alımlar başarıyla geri yüklendi.' : 'Önceki bir satın alım bulunamadı.'),
            backgroundColor: const Color(0xFF033E35),
          ),
        );
        if (success) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final isPremium = ref.watch(premiumProvider).isPremium;

    // Fiyat: Standart Ömür Boyu ₺499,99 -> %50 Ramazan İndirimi ile ₺249,99
    const originalPriceStr = '₺499,99';
    const discountedPriceStr = '₺249,99';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF021713),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFFFFDF7A), width: 1.8),
          left: BorderSide(color: Color(0xFFD4AF37), width: 0.8),
          right: BorderSide(color: Color(0xFFD4AF37), width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tutamaç
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Hilal ve Yıldız Lüks Başlık Rozeti ───────────────────────
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1C04), Color(0xFF140D02)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFDF7A), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFDF7A).withValues(alpha: 0.25),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🌙', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'RAMAZAN-I ŞERİF & KADİR GECESİ ÖZEL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFDF7A),
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Ömür Boyu Sahip Ol\n%50 Ramazan İndirimi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Bir kez ödeyin, bir daha asla abonelik ücreti ödemeyin. Tüm Ramazan widget\'ları, 30 cüz hatim takibi ve Kâbe ezan makamları ömür boyu sizin olsun.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // ── Ramazan Özel Avantajları ──────────────────────────────────
              _buildFeatureItem(
                icon: Icons.hourglass_top_rounded,
                title: 'İftar & Sahur Kilit Ekranı Canlı Takip',
                subtitle: 'İftara ve sahura ne kadar kaldığını telefon kilidini açmadan anlık görün.',
              ),
              _buildFeatureItem(
                icon: Icons.auto_stories_rounded,
                title: '30 Günde Hatim Takipçisi',
                subtitle: 'Tüm cüzlerinizi eksiksiz takip edin, sayfa numaraları ve hatim duasıyla tamamlayın.',
              ),
              _buildFeatureItem(
                icon: Icons.volume_up_rounded,
                title: 'Mekke & Medine Kâbe Ezan Makamları',
                subtitle: 'Harem-i Şerif ve Ravza-i Mutahhara müezzinlerinin sesleriyle vaktin huzurunu yaşayın.',
              ),
              _buildFeatureItem(
                icon: Icons.block_rounded,
                title: '%100 Reklamsız Huşû Deneyimi',
                subtitle: 'Sıfır reklam, sıfır dikkat dağıtıcı unsur ile saf ibadet ortamı.',
              ),
              const SizedBox(height: 14),

              // ── Fiyatlandırma Kutusu ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      const Color(0xFFFFDF7A).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFDF7A), width: 1.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ÖMÜR BOYU ERİŞİM',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFDF7A),
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tek Seferlik Ödeme',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              originalPriceStr,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white54,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Color(0xFFFF6B6B),
                                decorationThickness: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              discountedPriceStr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFDF7A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '%50 Ramazan İndirimi',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFFFDF7A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Satın Alma Butonu ────────────────────────────────────────
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5A47),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      '👑 Zaten Beyân Premium Üyesisiniz',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              else
                InkWell(
                  onTap: _isLoading ? null : _purchaseLifetime,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFDF7A),
                          Color(0xFFD4AF37),
                          Color(0xFF997A15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Color(0xFF071F1B),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Hemen ₺249,99\'a Sahip Ol ➔',
                              style: TextStyle(
                                color: Color(0xFF071F1B),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ── Geri Yükle & Belki Daha Sonra ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _restore,
                    child: Text(
                      strings.restorePurchases,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Text(
                    '•',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Belki Daha Sonra',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFDF7A).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Icon(icon, color: const Color(0xFFFFDF7A), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
