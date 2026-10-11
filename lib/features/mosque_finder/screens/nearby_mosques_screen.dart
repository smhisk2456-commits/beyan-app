import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _isLoading = true;
  String _userLocationTitle = 'Konum alınıyor...';
  double _userLat = AppConstants.defaultLatitude;
  double _userLng = AppConstants.defaultLongitude;

  List<NearbyMosque> _allMosques = [];
  double? _maxDistanceFilter; // null: Tümü, 500, 1000, 3000, 5000
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNearbyMosques();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyMosques() async {
    setState(() => _isLoading = true);
    try {
      final loc = await PrayerTimeService.instance.getCurrentLocation();
      _userLat = loc.latitude;
      _userLng = loc.longitude;
      if (loc.isFromGPS) {
        _userLocationTitle = 'Mevcut Konumunuz (${_userLat.toStringAsFixed(2)}, ${_userLng.toStringAsFixed(2)})';
      } else {
        _userLocationTitle = '${loc.cityName} (Varsayılan Konum)';
      }

      final mosques = await _service.findNearbyMosques(
        userLat: _userLat,
        userLng: _userLng,
        radiusMeters: 5000,
      );

      if (mounted) {
        setState(() {
          _allMosques = mosques;
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
      backgroundColor: const Color(0xFF011815),
      appBar: AppBar(
        title: const Text(
          'Yakındaki Camiler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: Color(0xFFFFDF7A)),
            tooltip: 'Konumu Yenile',
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadNearbyMosques();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Radar Başlık Alanı ─────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF03312B), Color(0xFF01241F)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore_rounded, color: Color(0xFFFFDF7A), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoading ? 'Camiler Taranıyor...' : '${filtered.length} Cami Bulundu',
                          style: const TextStyle(
                            color: Color(0xFFFFDF7A),
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
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFFDF7A),
                      ),
                    ),
                ],
              ),
            ),

            // ── 2. Arama ve Filtre Çubukları ─────────────────────────
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
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFFDF7A), size: 20),
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
            const SizedBox(height: 8),

            // Mesafe Filtre Çipleri
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildDistFilterChip('Tümü', null),
                  _buildDistFilterChip('< 500 m', 500),
                  _buildDistFilterChip('< 1 km', 1000),
                  _buildDistFilterChip('< 3 km', 3000),
                  _buildDistFilterChip('< 5 km', 5000),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // ── 3. Cami Listesi ─────────────────────────────────────
            Expanded(
              child: _isLoading && _allMosques.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mosque_outlined, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'Bu filtrede cami bulunamadı',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: const Color(0xFFD4AF37),
                          backgroundColor: const Color(0xFF032620),
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
        selectedColor: const Color(0xFFD4AF37),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF032620),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
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
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFDF7A).withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.mosque_rounded, color: Color(0xFFFFDF7A), size: 20),
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
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFDF7A).withValues(alpha: 0.5)),
                ),
                child: Text(
                  mosque.formattedDistance,
                  style: const TextStyle(
                    color: Color(0xFFFFDF7A),
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
              Icon(Icons.navigation_rounded, size: 12, color: const Color(0xFF2DD4BF).withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(
                mosque.compassDirection,
                style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 11),
              ),

              const Spacer(),

              // Yol Tarifi Al Düğmesi
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
                  backgroundColor: const Color(0xFFD4AF37),
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
    );
  }
}
