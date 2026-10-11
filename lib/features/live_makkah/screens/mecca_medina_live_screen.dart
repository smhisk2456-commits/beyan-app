import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 24/7 Mekke & Medine Uygulama İçi Canlı Yayın Ekranı (In-App Live Stream Player)
class MeccaMedinaLiveScreen extends StatefulWidget {
  const MeccaMedinaLiveScreen({super.key});

  @override
  State<MeccaMedinaLiveScreen> createState() => _MeccaMedinaLiveScreenState();
}

class _MeccaMedinaLiveScreenState extends State<MeccaMedinaLiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Saudi Quran TV (Makkah): UCos52azQNBgW63_9uDJoPDA
  // Saudi Sunnah TV (Madinah): UCROKYPep-UuODNwyipe6JMw
  static const String _makkahChannelId = 'UCos52azQNBgW63_9uDJoPDA';
  static const String _madinahChannelId = 'UCROKYPep-UuODNwyipe6JMw';

  late final WebViewController _makkahController;
  late final WebViewController _madinahController;

  bool _isMakkahLoading = true;
  bool _isMadinahLoading = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _initControllers();
  }

  void _initControllers() {
    _makkahController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isMakkahLoading = false);
          },
        ),
      )
      ..loadHtmlString(_buildHtmlStreamPlayer(_makkahChannelId));

    _madinahController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isMadinahLoading = false);
          },
        ),
      )
      ..loadHtmlString(_buildHtmlStreamPlayer(_madinahChannelId));
  }

  String _buildHtmlStreamPlayer(String channelId) {
    return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  html, body {
    width: 100%; height: 100%;
    background: #000000;
    overflow: hidden;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  .player-wrapper {
    position: relative;
    width: 100%;
    height: 100%;
  }
  iframe {
    width: 100%;
    height: 100%;
    border: none;
    display: block;
  }
</style>
</head>
<body>
  <div class="player-wrapper">
    <iframe 
      src="https://www.youtube-nocookie.com/embed/live_stream?channel=$channelId&autoplay=1&mute=0&playsinline=1&rel=0&modestbranding=1" 
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';
  }

  void _reloadCurrentStream() {
    HapticFeedback.lightImpact();
    if (_tabController.index == 0) {
      setState(() => _isMakkahLoading = true);
      _makkahController.loadHtmlString(_buildHtmlStreamPlayer(_makkahChannelId));
    } else {
      setState(() => _isMadinahLoading = true);
      _madinahController.loadHtmlString(_buildHtmlStreamPlayer(_madinahChannelId));
    }
  }

  Future<void> _openOfficialLiveChannel(String channelHandle) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('https://www.youtube.com/$channelHandle/live');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(
                  controller: _tabController.index == 0 ? _makkahController : _madinahController,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton.filled(
                  icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                  ),
                  onPressed: () => setState(() => _isFullScreen = false),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF011815),
      appBar: AppBar(
        title: const Text(
          'Mekke & Medine Canlı Yayın',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFDF7A)),
            tooltip: 'Yayını Yenile',
            onPressed: _reloadCurrentStream,
          ),
        ],
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
          _buildLiveTab(
            controller: _makkahController,
            isLoading: _isMakkahLoading,
            title: 'Kâbe-i Muazzama Canlı Yayın',
            subtitle: 'Suudi Arabistan Resmi Kur\'an TV 24/7 Canlı Yayın',
            badge: 'CANLI • MEKKE',
            accentColor: const Color(0xFFD4AF37),
            handle: '@SaudiQuranTv',
            description:
                'Beytullah\'ın etrafındaki tavafı ve Mescid-i Haram\'da kılınan vakit namazlarını 24 saat kesintisiz uygulama içinden canlı izleyin.',
            hadith: '«Yeryüzünde insanlar için kurulan ilk mabet, âlemlere bereket ve hidayet kaynağı olan Mekke\'deki Kâbe\'dir.» (Âl-i İmrân 96)',
          ),
          _buildLiveTab(
            controller: _madinahController,
            isLoading: _isMadinahLoading,
            title: 'Mescid-i Nebevi Canlı Yayın',
            subtitle: 'Suudi Arabistan Resmi Sünnet TV 24/7 Canlı Yayın',
            badge: 'CANLI • MEDİNE',
            accentColor: const Color(0xFF2DD4BF),
            handle: '@SaudiSunnahTv',
            description:
                'Peygamber Efendimiz\'in (s.a.v.) kabr-i şerifinin bulunduğu Mescid-i Nebevi Ravza-i Mutahhara atmosferini 24 saat kesintisiz canlı izleyin.',
            hadith: '«Evimle minberimin arası, cennet bahçelerinden bir bahçedir.» (Buhârî, Mescid-i Mekke 5)',
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab({
    required WebViewController controller,
    required bool isLoading,
    required String title,
    required String subtitle,
    required String badge,
    required Color accentColor,
    required String handle,
    required String description,
    required String hadith,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Uygulama İçi Video Oynatıcı Kartı ──────────────────────
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: WebViewWidget(controller: controller),
                  ),

                  // Yükleniyor İndikatörü
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF032620),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: accentColor),
                              const SizedBox(height: 12),
                              Text(
                                '$badge Bağlanıyor...',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Tam Ekran Butonu (Sağ Üst)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                      ),
                      tooltip: 'Tam Ekran İzle',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isFullScreen = true);
                      },
                    ),
                  ),

                  // Canlı Rozeti (Sol Üst)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── 2. Kontrol ve Aksiyon Butonları ─────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _reloadCurrentStream,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Yayını Yenile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFDF7A),
                    side: BorderSide(color: const Color(0xFFFFDF7A).withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openOfficialLiveChannel(handle),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('YouTube\'da Aç'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 3. Canlı Yayın Bilgi Kartı ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF032620),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.live_tv_rounded, color: accentColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hadith,
                    style: TextStyle(
                      color: const Color(0xFFFFDF7A).withValues(alpha: 0.95),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
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
