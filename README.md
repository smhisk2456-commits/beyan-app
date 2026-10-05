# İslami Uygulama 🕌

Çevrimdışı (offline) çalışan, namaz vakitlerini hesaplayan ve Kur'an-ı Kerim okuma özelliği sunan İslami mobil uygulama.

## Özellikler

- 📿 **Offline Kur'an** – İnternet bağlantısı gerektirmez
- 🕌 **Namaz Vakitleri** – Diyanet metoduna göre hesaplama (adhan kütüphanesi)
- 📍 **Konum Tabanlı** – GPS ile otomatik konum (fallback: İstanbul)
- 🔒 **Kilit Ekranı Widget'ı** – iOS ve Android kilit ekranına namaz vakti ve ayet
- 🌙 **Dark Mode** – Sistem temasına uyumlu

## Kurulum

### Gereksinimler

- Flutter SDK: 3.3.0 veya üzeri
- Dart SDK: 3.3.0 veya üzeri
- Android Studio / Xcode

### Adımlar

```bash
# 1. Amiri fontlarını assets/fonts/ klasörüne indirin
# Buradan: https://fonts.google.com/specimen/Amiri

# 2. Quran veritabanını assets/database/ klasörüne koyun
# quran.db (surah, verse, daily_dua tablolarını içermeli)

# 3. Bağımlılıkları yükleyin
flutter pub get

# 4. Kod üretimi çalıştırın (Riverpod için)
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Uygulamayı çalıştırın
flutter run
```

## Proje Yapısı

```
lib/
├── main.dart                          # Uygulama giriş noktası
├── core/
│   ├── database/                      # SQLite DatabaseHelper
│   ├── theme/                         # AppTheme, AppColors, AppTextStyles
│   ├── utils/                         # AppConstants, AppUtils
│   └── widgets/                       # Ortak widget'lar
└── features/
    ├── home/
    │   ├── screens/                   # Ana ekran
    │   └── widgets/                   # Namaz vakti kartı, vs.
    ├── prayer_times/
    │   ├── models/                    # PrayerTime modeli
    │   ├── providers/                 # Riverpod providers
    │   ├── services/                  # PrayerTimeService (adhan)
    │   └── screens/                   # Namaz vakitleri ekranı
    ├── quran/
    │   ├── models/                    # Surah, Verse, DailyDua
    │   ├── providers/                 # Riverpod providers
    │   ├── repositories/              # QuranRepository, DuaRepository
    │   ├── screens/                   # Sure listesi, Sure detay ekranı
    │   └── widgets/                   # Ayet widget'ı (Amiri fontu)
    └── widget_service/                # HomeWidget servisi
```

## Geliştirme Fazları

| Faz | Durum | Açıklama |
|-----|-------|----------|
| Phase 1 | ✅ Tamamlandı | Proje kurulumu ve klasör mimarisi |
| Phase 2 | ⏳ Bekliyor | Veritabanı ve modeller |
| Phase 3 | ⏳ Bekliyor | Namaz vakitleri servisi |
| Phase 4 | ⏳ Bekliyor | UI / Arayüz geliştirmesi |
| Phase 5 | ⏳ Bekliyor | Native widget'lar |

## Teknolojiler

| Teknoloji | Paket | Versiyon |
|-----------|-------|---------|
| State Management | flutter_riverpod | ^2.5.1 |
| Database | sqflite | ^2.3.3+1 |
| Prayer Times | adhan | ^1.1.0 |
| Location | geolocator | ^12.0.0 |
| Widgets | home_widget | ^0.6.0 |
| Background | workmanager | ^0.5.2 |
| Typography | google_fonts | ^6.2.1 |

## Veritabanı Şeması

```sql
-- Sureler
CREATE TABLE surah (
    id INTEGER PRIMARY KEY,
    name_arabic TEXT NOT NULL,
    name_turkish TEXT NOT NULL,
    name_english TEXT NOT NULL,
    verse_count INTEGER NOT NULL,
    revelation_type TEXT NOT NULL  -- 'meccan' veya 'medinan'
);

-- Ayetler
CREATE TABLE verse (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    surah_id INTEGER NOT NULL,
    verse_number INTEGER NOT NULL,
    arabic_text TEXT NOT NULL,
    transliteration TEXT,
    turkish_meaning TEXT NOT NULL,
    FOREIGN KEY (surah_id) REFERENCES surah(id)
);

-- Günlük Dualar
CREATE TABLE daily_dua (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    arabic_text TEXT NOT NULL,
    transliteration TEXT,
    turkish_meaning TEXT NOT NULL,
    reference TEXT NOT NULL
);
```

## Lisans

MIT License
