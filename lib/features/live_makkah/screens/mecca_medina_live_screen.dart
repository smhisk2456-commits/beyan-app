import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// 24/7 Mekke & Medine Canlı Yayın Ekranı
class MeccaMedinaLiveScreen extends StatefulWidget {
  const MeccaMedinaLiveScreen({super.key});

  @override
  State<MeccaMedinaLiveScreen> createState() => _MeccaMedinaLiveScreenState();
}

class _MeccaMedinaLiveScreenState extends State<MeccaMedinaLiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchOfficialStream(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF011815),
      appBar: AppBar(
        title: const Text(
          'Mekke & Medine Canlı Yayın',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFDF7A),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFFDF7A),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(
              icon: Icon(Icons.mosque_rounded),
              text: 'Kâbe-i Muazzama (Mekke)',
            ),
            Tab(
              icon: Icon(Icons.nightlight_round),
              text: 'Mescid-i Nebevi (Medine)',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveCard(
            title: 'Kâbe Canlı Yayın (Makkah Live)',
            subtitle: 'Suudi Arabistan Resmi Kur\'an TV 24/7 Kesintisiz Yayın',
            badge: 'CANLI • MEKKE',
            accentColor: const Color(0xFFD4AF37),
            imageUrl: 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=800&q=80',
            streamUrl: 'https://www.youtube.com/watch?v=kYvU7gU54dE', // Makkah Live
            description: 'Beytullah\'ın etrafındaki tavafı ve Mescid-i Haram\'da kılınan vakit namazlarını 24 saat canlı izleyin.',
          ),
          _buildLiveCard(
            title: 'Medine Canlı Yayın (Madinah Live)',
            subtitle: 'Suudi Arabistan Resmi Sünnet TV 24/7 Kesintisiz Yayın',
            badge: 'CANLI • MEDİNE',
            accentColor: const Color(0xFF2DD4BF),
            imageUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=800&q=80',
            streamUrl: 'https://www.youtube.com/watch?v=uK1m2rS5T6Y', // Madinah Live
            description: 'Peygamber Efendimiz\'in (s.a.v.) kabr-i şerifinin bulunduğu Mescid-i Nebevi\'yi 24 saat canlı izleyin.',
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required String imageUrl,
    required String streamUrl,
    required String description,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Video Önizleme Kartı (Canlı Rozetli)
          Container(
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF032620), Color(0xFF011512)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Arka plan silüeti / deseni
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.9,
                          colors: [
                            accentColor.withValues(alpha: 0.2),
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Canlı Rozeti (Sol Üst)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Büyük Oynat Butonu
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () => _launchOfficialStream(streamUrl),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.6),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),

                // Alt Canlı Yayın Başlığı
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      const Icon(Icons.hd_rounded, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Başlık & Açıklama
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Tam Ekran Canlı Yayını Aç Butonu
          ElevatedButton.icon(
            onPressed: () => _launchOfficialStream(streamUrl),
            icon: const Icon(Icons.tv_rounded, size: 20),
            label: const Text(
              'Canlı Yayını İzle (Resmi HD Yayın)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }
}
