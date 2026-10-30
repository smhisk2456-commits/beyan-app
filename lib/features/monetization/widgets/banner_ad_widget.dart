import 'package:flutter/material.dart';

/// Eski ekran-içi banner widget'ı.
/// Tek ve birleşik alt banner mimarisi `BeyanBannerAdWidget` üzerinden
/// `main.dart` alt barında yönetildiği için sayfa içi yinelenen reklamları engellemek
/// ve Premium kullanıcılarda %100 sıfır alan kaplamasını garanti etmek amacıyla
/// sıfır yer kaplayacak şekilde (`SizedBox.shrink`) korunmaktadır.
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
