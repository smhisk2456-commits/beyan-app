import 'package:islamic_app/core/theme/beyan_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/widgets/beyan_soft_permission_dialog.dart';
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
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
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
    final strings = widget.ref.watch(appStringsProvider);
    final filtered = predefinedCitiesList.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(q) || c.country.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: BeyanColors.tone(0xFF02211C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 1.5)),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! > 6) {
                Navigator.pop(context);
              }
            },
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.cityLocationTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: BeyanColors.tone(0xFFFFDF7A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                  color: Colors.white70,
                  tooltip: 'Kapat',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Otomatik GPS seçeneği
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BeyanColors.tone(0xFFD4AF37),
                ),
                child: const Icon(Icons.my_location_rounded, color: Colors.black87, size: 20),
              ),
              title: Text(
                strings.autoGpsTitle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: Text(
                strings.autoGpsDesc,
                style: const TextStyle(color: Colors.white60, fontSize: 11.5),
              ),
              tileColor: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: BeyanColors.tone(0xFFD4AF37), width: 0.8),
              ),
              onTap: () async {
                HapticFeedback.lightImpact();
                final perm = await Geolocator.checkPermission();
                if (perm == LocationPermission.denied) {
                  if (context.mounted) {
                    final proceed = await BeyanSoftPermissionDialog.show(
                      context,
                      type: BeyanSoftPermissionType.location,
                    );
                    if (!proceed) return;
                  }
                }
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
                hintText: strings.searchCityHint,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: BeyanColors.tone(0xFFD4AF37), size: 20),
                filled: true,
                fillColor: BeyanColors.tone(0xFF03312A),
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
            child: NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels <= 0 &&
                    notification.scrollDelta != null &&
                    notification.scrollDelta! < -10) {
                  Navigator.pop(context);
                  return true;
                }
                return false;
              },
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
              itemBuilder: (context, index) {
                final city = filtered[index];
                return ListTile(
                  leading: Icon(Icons.location_on_outlined, color: BeyanColors.tone(0xFFD4AF37), size: 20),
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
          ),
        ],
      ),
    );
  }
}
