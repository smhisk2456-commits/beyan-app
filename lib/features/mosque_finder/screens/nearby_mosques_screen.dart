import 'dart:async';
import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_constants.dart';
import '../../prayer_times/services/prayer_time_service.dart';
import '../models/nearby_mosque_model.dart';
import '../services/nearby_mosques_service.dart';

/// Yakındaki Camiler & Harita Navigasyonu Ekranı
class NearbyMosquesScreen extends StatefulWidget {
  const NearbyMosquesScreen({super.key});

  @override
  State<NearbyMosquesScreen> createState() => _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends State<NearbyMosquesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final NearbyMosquesService _service = NearbyMosquesService.instance;
  StreamSubscription<Position>? _positionSub;

  bool _isLoading = true;
  bool _isGpsActive = false;
  bool _hasAccurateGpsLock = false;
  double? _gpsAccuracyMeters;
  String _userLocationTitle = 'Canlı GPS konumu alınıyor...';
  double _userLat = AppConstants.defaultLatitude;
  double _userLng = AppConstants.defaultLongitude;

  List<NearbyMosque> _allMosques = [];
  double? _maxDistanceFilter; // null: Tümü, 1000, 2000, 5000, 10000
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initSavedLocationAndLoad();
  }

  Future<void> _initSavedLocationAndLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sLat = prefs.getDouble('beyan_verified_gps_lat');
      final sLng = prefs.getDouble('beyan_verified_gps_lng');
      final sTitle = prefs.getString('beyan_verified_gps_title');
      final isDefaultFallback = sLat != null &&
          sLng != null &&
          (sLat - AppConstants.defaultLatitude).abs() < 0.0005 &&
          (sLng - AppConstants.defaultLongitude).abs() < 0.0005;
      if (sLat != null && sLng != null && !isDefaultFallback && mounted) {
        setState(() {
          _userLat = sLat;
          _userLng = sLng;
          _isGpsActive = true;
          if (sTitle != null && sTitle.isNotEmpty) {
            _userLocationTitle = '$sTitle (Canlı GPS 📍)';
          }
        });
      }
    } catch (_) {}
    if (!mounted) return;
    _loadNearbyMosques();
  }

  void _startLivePositionStream() {
    _positionSub?.cancel();
    try {
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 20,
        ),
      ).listen((pos) async {
        if (!mounted) return;
        // Eğer elimizde yüksek hassasiyetli (<= 45m) bir GPS kilidi varsa ve yeni gelen paket
        // baz istasyonu kaynaklı kaba bir sapmaysa (> 120m hata payı), hassas konumu ezme!
        if (_hasAccurateGpsLock && pos.accuracy > 120) {
          return;
        }
        final movedDist = NearbyMosque.calculateDistanceMeters(
          _userLat,
          _userLng,
          pos.latitude,
          pos.longitude,
        );
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
          _gpsAccuracyMeters = pos.accuracy;
          _isGpsActive = true;
          if (pos.accuracy <= 65) {
            _hasAccurateGpsLock = true;
          }
          if (_allMosques.isNotEmpty) {
            _allMosques = _allMosques.map((m) {
              final d = NearbyMosque.calculateDistanceMeters(pos.latitude, pos.longitude, m.latitude, m.longitude);
              final b = NearbyMosque.calculateBearing(pos.latitude, pos.longitude, m.latitude, m.longitude);
              return m.copyWith(distanceMeters: d, bearingDegrees: b);
            }).toList()
              ..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
          }
        });
        // Konum ilk tahminden >120 metre daha hassas bir noktaya oturduysa camileri yeniden tara
        if (movedDist > 120) {
          final mosques = await _service.findNearbyMosques(
            userLat: pos.latitude,
            userLng: pos.longitude,
            radiusMeters: 5000,
            forceRefresh: true,
          );
          if (mounted && mosques.isNotEmpty) {
            setState(() => _allMosques = mosques);
          }
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyMosques({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    try {
      // 1. Konum servisleri açık mı kontrol et
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cihaz konum servisi (GPS) kapalı. Lütfen GPS\'i açın.'),
            action: SnackBarAction(
              label: 'Ayarları Aç',
              textColor: BeyanColors.tone(0xFFFFDF7A),
              onPressed: () => Geolocator.openLocationSettings(),
            ),
            backgroundColor: BeyanColors.tone(0xFF032D26),
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // 2. İzin kontrolü ve talep
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.deniedForever && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Konum izni kalıcı reddedildi. Ayarlardan izin verin.'),
            action: SnackBarAction(
              label: 'Uygulama İzinleri',
              textColor: BeyanColors.tone(0xFFFFDF7A),
              onPressed: () => Geolocator.openAppSettings(),
            ),
            backgroundColor: BeyanColors.tone(0xFF032D26),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // 3. YÜKSEK HASSASİYETLİ (BEST ACCURACY) CANLI DONANIM GPS TESPİTİ
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        _startLivePositionStream();
        if (!_hasAccurateGpsLock) {
          try {
            final lastPos = await Geolocator.getLastKnownPosition();
            if (lastPos != null && (_gpsAccuracyMeters == null || lastPos.accuracy <= _gpsAccuracyMeters!)) {
              _userLat = lastPos.latitude;
              _userLng = lastPos.longitude;
              _gpsAccuracyMeters = lastPos.accuracy;
              _isGpsActive = true;
              if (lastPos.accuracy <= 65) {
                _hasAccurateGpsLock = true;
              }
            }
          } catch (_) {}
        }

        try {
          final livePos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            timeLimit: const Duration(seconds: 8),
          );
          if (!_hasAccurateGpsLock || livePos.accuracy <= (_gpsAccuracyMeters ?? 9999) + 35) {
            _userLat = livePos.latitude;
            _userLng = livePos.longitude;
            _gpsAccuracyMeters = livePos.accuracy;
            _isGpsActive = true;
            if (livePos.accuracy <= 65) {
              _hasAccurateGpsLock = true;
            }
          }
        } catch (_) {
          // Best accuracy zaman aşımına uğrarsa ve henüz hassas kilit yoksa high ile yedek dene
          if (!_hasAccurateGpsLock) {
            try {
              final fallbackPos = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
                timeLimit: const Duration(seconds: 4),
              );
              if (_gpsAccuracyMeters == null || fallbackPos.accuracy <= _gpsAccuracyMeters!) {
                _userLat = fallbackPos.latitude;
                _userLng = fallbackPos.longitude;
                _gpsAccuracyMeters = fallbackPos.accuracy;
                _isGpsActive = true;
                if (fallbackPos.accuracy <= 65) {
                  _hasAccurateGpsLock = true;
                }
              }
            } catch (_) {}
          }
        }
      }

      // 4. GPS hiç alınamamışsa (izin yoksa veya GPS kapalıysa) namaz servisinin şehrini kullan
      if (!_isGpsActive && _userLat == AppConstants.defaultLatitude && _userLng == AppConstants.defaultLongitude) {
        final loc = await PrayerTimeService.instance.getCurrentLocation();
        _userLat = loc.latitude;
        _userLng = loc.longitude;
        _userLocationTitle = '${loc.cityName} (${loc.isFromGPS ? "GPS Konumu 📍" : "Kayıtlı Şehir"})';
        _isGpsActive = loc.isFromGPS;
      }

      // 5. İlçe / Mahalle Ters Jeokodlama (Reverse Geocoding)
      if (_isGpsActive) {
        String readableLocation = 'Canlı GPS Konumu';
        try {
          final placemarks = await placemarkFromCoordinates(_userLat, _userLng).timeout(const Duration(seconds: 3));
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final subLoc = p.subLocality?.trim() ?? '';
            final street = p.thoroughfare?.trim() ?? '';
            final locality = p.locality?.trim() ?? '';
            final subAdmin = p.subAdministrativeArea?.trim() ?? '';
            final admin = p.administrativeArea?.trim() ?? '';

            final neighborhood = subLoc.isNotEmpty ? subLoc : street;
            final district = locality.isNotEmpty ? locality : subAdmin;

            if (neighborhood.isNotEmpty && district.isNotEmpty && neighborhood != district) {
              readableLocation = '$neighborhood, $district';
            } else if (district.isNotEmpty && admin.isNotEmpty && district != admin) {
              readableLocation = '$district, $admin';
            } else if (district.isNotEmpty) {
              readableLocation = district;
            } else if (admin.isNotEmpty) {
              readableLocation = admin;
            }
          }
        } catch (_) {}

        final accStr = _gpsAccuracyMeters != null && _gpsAccuracyMeters! > 0
            ? ' • ±${_gpsAccuracyMeters!.round()}m'
            : '';
        _userLocationTitle = '$readableLocation (Canlı GPS 📍$accStr)';

        // Widget ve konum önbelleğini canlı GPS ile güncelle
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setDouble('beyan_verified_gps_lat', _userLat);
          await prefs.setDouble('beyan_verified_gps_lng', _userLng);
          await prefs.setString('beyan_verified_gps_title', readableLocation);
          await prefs.setDouble('beyan_widget_lat', _userLat);
          await prefs.setDouble('beyan_widget_lng', _userLng);
          await prefs.setString('beyan_widget_city', readableLocation);
        } catch (_) {}
      }

      // 6. Çevredeki camileri ara (Dar mahalle kutusu + Photon + Overpass paralel)
      final mosques = await _service.findNearbyMosques(
        userLat: _userLat,
        userLng: _userLng,
        radiusMeters: 5000,
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          // MESAFE ZIPLAMA KORUMASI:
          // Eğer ekranda daha önce gerçek camiler listelenmişse ve yeni dönen liste sadece fallback ise
          // gerçek camileri koru ve mesafelerini anlık konuma göre yeniden hesapla
          if (_allMosques.any((m) => !m.isCuratedFallback) && mosques.every((m) => m.isCuratedFallback)) {
            _allMosques = _allMosques.map((m) {
              final dist = NearbyMosque.calculateDistanceMeters(_userLat, _userLng, m.latitude, m.longitude);
              final bearing = NearbyMosque.calculateBearing(_userLat, _userLng, m.latitude, m.longitude);
              return m.copyWith(distanceMeters: dist, bearingDegrees: bearing);
            }).toList()..sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
          } else {
            _allMosques = mosques;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<NearbyMosque> get _filteredMosques {
    return _allMosques.where((m) {
      final matchesSearch = _searchQuery.isEmpty ||
          m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (m.address ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesDist = _maxDistanceFilter == null || m.distanceMeters <= _maxDistanceFilter!;
      return matchesSearch && matchesDist;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMosques;

    return Scaffold(
      backgroundColor: BeyanColors.tone(0xFF011815),
      appBar: AppBar(
        title: const Text(
          'Yakındaki Camiler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location_rounded, color: BeyanColors.tone(0xFFFFDF7A)),
            tooltip: 'Konumu Yenile',
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadNearbyMosques(forceRefresh: true);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Radar Başlık Alanı ─────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [BeyanColors.tone(0xFF03312B), BeyanColors.tone(0xFF01241F)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.explore_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoading ? 'Camiler Taranıyor...' : '${filtered.length} Cami Bulundu',
                          style: TextStyle(
                            color: BeyanColors.tone(0xFFFFDF7A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _userLocationTitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: BeyanColors.tone(0xFFFFDF7A),
                      ),
                    ),
                ],
              ),
            ),

            // ── 2. Canlı Google Haritalarda Aç Butonu ────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _service.openGoogleMapsNearby(userLat: _userLat, userLng: _userLng);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [BeyanColors.tone(0xFF0F4C42), BeyanColors.tone(0xFF042E28)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.map_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Google Haritalar\'da Çevredeki Tüm Camiler',
                              style: TextStyle(
                                color: BeyanColors.tone(0xFFFFDF7A),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Google verileriyle canlı cami, mescid ve yol tariflerini aç',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 14),
                    ],
                  ),
                ),
              ),
            ),

            // ── GPS İzin Uyarısı (Gerekiyorsa) ─────────────────────────
            if (!_isGpsActive && !_isLoading)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'En yakın camileri canlı görmek için konum izni gereklidir.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Geolocator.openAppSettings();
                        _loadNearbyMosques();
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text('İzin Ver', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ),
                  ],
                ),
              ),

            // ── Çevrimdışı / Yedek Veri Bilgilendirmesi ─────────────────
            if (!_isLoading && _allMosques.isNotEmpty && _allMosques.every((m) => m.isCuratedFallback))
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'İnternetsiz modda seçkin tarihi camiler listeleniyor. Mahallenizdeki camiler için üstteki butondan Haritaları açabilirsiniz.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

            // ── 3. Arama Çubuğu ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Cami adına veya semte göre ara...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // ── 4. Mesafe Filtre Çipleri ─────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildDistFilterChip('Tümü', null),
                  _buildDistFilterChip('< 1 km', 1000),
                  _buildDistFilterChip('< 2 km', 2000),
                  _buildDistFilterChip('< 5 km', 5000),
                  _buildDistFilterChip('< 10 km', 10000),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ── 3. Cami Listesi ─────────────────────────────────────
            Expanded(
              child: _isLoading && _allMosques.isEmpty
                  ? Center(child: CircularProgressIndicator(color: BeyanColors.tone(0xFFD4AF37)))
                  : filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mosque_outlined, size: 52, color: Colors.white.withValues(alpha: 0.35)),
                                const SizedBox(height: 12),
                                const Text(
                                  'Bu Filtrede Cami Bulunamadı',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Filtreyi genişletebilir veya doğrudan Haritalar üzerinde çevrenizdeki tüm camileri inceleyebilirsiniz.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _maxDistanceFilter = null;
                                          _searchCtrl.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                      icon: const Icon(Icons.refresh_rounded, size: 16),
                                      label: const Text('Filtreyi Sıfırla'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: BeyanColors.tone(0xFFFFDF7A),
                                        side: BorderSide(color: BeyanColors.tone(0xFFFFDF7A)),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _service.openAllNearbyMosquesInMaps(userLat: _userLat, userLng: _userLng);
                                      },
                                      icon: const Icon(Icons.map_rounded, size: 16),
                                      label: const Text('Haritada Aç'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: BeyanColors.tone(0xFFD4AF37),
                                        foregroundColor: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: BeyanColors.tone(0xFFD4AF37),
                          backgroundColor: BeyanColors.tone(0xFF032620),
                          onRefresh: _loadNearbyMosques,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _buildMosqueCard(filtered[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistFilterChip(String label, double? dist) {
    final isSelected = _maxDistanceFilter == dist;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _maxDistanceFilter = dist),
        selectedColor: BeyanColors.tone(0xFFD4AF37),
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 11.5,
        ),
      ),
    );
  }

  Widget _buildMosqueCard(NearbyMosque mosque) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _service.openWalkingDirections(
          lat: mosque.latitude,
          lng: mosque.longitude,
          mosqueName: mosque.name,
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BeyanColors.tone(0xFF032620),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Cami İkonu
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Icon(Icons.mosque_rounded, color: BeyanColors.tone(0xFFFFDF7A), size: 20),
                ),
                const SizedBox(width: 12),

                // Cami Adı ve Adresi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mosque.address ?? 'Yakın Çevre',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Mesafe Rozeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: BeyanColors.tone(0xFFD4AF37).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BeyanColors.tone(0xFFFFDF7A).withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    mosque.formattedDistance,
                    style: TextStyle(
                      color: BeyanColors.tone(0xFFFFDF7A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Alt Bilgi Şeridi: Yürüme Süresi, Pusula Yönü ve Yol Tarifi Butonu
            Row(
              children: [
                // Yürüme Süresi
                Icon(Icons.directions_walk_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Text(
                  '~${mosque.estimatedWalkingMinutes} dk',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5),
                ),
                const SizedBox(width: 14),

                // Yön
                Icon(Icons.navigation_rounded, size: 12, color: BeyanColors.tone(0xFF2DD4BF).withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Text(
                  mosque.compassDirection,
                  style: TextStyle(color: BeyanColors.tone(0xFF2DD4BF), fontSize: 11),
                ),

                const Spacer(),

                // Yol Tarifi Al Düğmesi (Google Maps / Apple Maps)
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _service.openWalkingDirections(
                      lat: mosque.latitude,
                      lng: mosque.longitude,
                      mosqueName: mosque.name,
                    );
                  },
                  icon: const Icon(Icons.directions_rounded, size: 15),
                  label: const Text('Yol Tarifi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BeyanColors.tone(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
