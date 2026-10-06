import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/city_model.dart';
import '../providers/prayer_time_providers.dart';
import '../services/prayer_time_service.dart';

/// Şehir ve Konum Seçici Bottom Sheet
class CitySelectorSheet extends StatefulWidget {
  final WidgetRef ref;

  const CitySelectorSheet({super.key, required this.ref});

  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CitySelectorSheet(ref: ref),
    );
  }

  @override
  State<CitySelectorSheet> createState() => _CitySelectorSheetState();
}

class _CitySelectorSheetState extends State<CitySelectorSheet> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = predefinedCitiesList.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.country.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF02211C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Şehir ve Konum Seçimi',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFDF7A),
            ),
          ),
          const SizedBox(height: 14),

          // Otomatik GPS seçeneği
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD4AF37),
                ),
                child: const Icon(Icons.my_location_rounded, color: Colors.black87, size: 20),
              ),
              title: const Text(
                'Otomatik GPS Konumu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: const Text(
                'Cihazınızın anlık konumunu otomatik kullanır',
                style: TextStyle(color: Colors.white60, fontSize: 11.5),
              ),
              tileColor: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 0.8),
              ),
              onTap: () async {
                HapticFeedback.lightImpact();
                await PrayerTimeService.instance.saveManualCity(null);
                widget.ref.read(prayerTimesNotifierProvider.notifier).refresh();
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 12),

          // Arama Kutusu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Şehir veya ülke ara...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFD4AF37), size: 20),
                filled: true,
                fillColor: const Color(0xFF03312A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: 10),

          // Şehir Listesi
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final city = filtered[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined, color: Color(0xFFD4AF37), size: 20),
                  title: Text(
                    city.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    city.country,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    await PrayerTimeService.instance.saveManualCity(city.name);
                    widget.ref.read(prayerTimesNotifierProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
