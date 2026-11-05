# 🕌 BEYÂN (Namaz Vakitleri & İslami Yaşam) — Kapsamlı Proje Dosyası ve Claude Denetim İstemi (Audit Prompt)

> **Kullanım Notu:** Bu belgenin tamamını kopyalayıp Claude'a yapıştırabilirsiniz. Claude bu teknik brifingi okuyarak uygulamanın mimarisini, dosya yapısını, kullanılan paketleri ve olası darboğazları analiz edip size detaylı bir **Performans İyileştirme ve Hata Raporu (Bug Report)** sunacaktır.

---

```markdown
# 📌 CLAUDE İÇİN TEKNİK İNCELEME & PERFORMANS DENETİMİ TALİMATI

Sen, **Kıdemli Flutter & iOS Sistem Mimarı (Principal Mobile Architect)** ve **Mobil Performans / Optimizasyon Uzmanısın**. 
Aşağıda teknik detayları, mimarisi, bağımlılıkları ve modülleri paylaşılan **"Beyân: Namaz Vakitleri & Ezan"** isimli canlı App Store uygulamasını derinlemesine denetleyecek (code & architecture audit), tespit ettiğin performans darboğazlarını, potansiyel bellek sızıntılarını, widget rebuild yüklerini ve kritik mimari açıkları raporlayacaksın.

---

## 1. UYGULAMA KİMLİĞİ VE TEMEL BİLGİLER
- **Uygulama Adı:** Beyân: Namaz Vakitleri, Kur'an & İslami Yaşam
- **Paket Kimliği (Bundle ID):** `com.smhisk60.beyan` (App Store ID: `6820956134`)
- **Platformlar:** iOS (Öncelikli: iOS 16 – iOS 18+ / iOS 26 SDK) & Android
- **Yazılım Yığını:** Flutter (SDK `>=3.3.0 <4.0.0`, Dart 3.7+), Swift 6 (WidgetKit & Dynamic Island)
- **Mimari:** Feature-First Clean Architecture + Riverpod Durum Yönetimi (State Management)
- **Temel Prensip:** Tamamen çevrimdışı (offline-first) çalışabilme, lüks Apple tasarım dili (OLED siyahları, zümrüt yeşili, 24K altın, frosted glass paneller, haptik geri bildirimler) ve sıfır arka plan batarya tüketimi.

---

## 2. KULLANILAN TEKNOLOJİLER & BAĞIMLILIKLAR (pubspec.yaml)

### A. Durum Yönetimi (State Management)
- `flutter_riverpod: ^2.5.1`
- `riverpod_annotation: ^2.3.5`
- `riverpod_generator: ^2.4.3`

### B. Veritabanı & Çevrimdışı Depolama
- `sqflite: ^2.3.3+1` (Kur'an-ı Kerim tam metni, mealler, tefsir, dua kütüphanesi)
- `shared_preferences: ^2.2.3` (Kullanıcı tercihleri, kaza namazı sayaçları, zikir verileri)
- `flutter_secure_storage: ^11.2.0` (Hassas anahtarlar, API tokenları)
- `path_provider: ^2.1.3` & `path: ^1.9.0`

### C. Namaz Vakitleri & Coğrafi Konum
- `adhan: ^2.0.0+1` (Astronomik offline namaz hesabı: Diyanet, MWL, ISNA vb.)
- `geolocator: ^12.0.0` (GPS koordinat tespiti, otomatik şehir bulma)
- `geocoding: ^3.0.0` (Tersine coğrafi kodlama)
- `geomag: ^0.3.0` (Manyetik sapma hesabı - Gerçek Kuzey)
- `flutter_compass: ^0.8.1` (Kıble pusulası için manyetometre ve jiroskop)

### D. iOS Widget & Dynamic Island
- `home_widget: ^0.6.0` (Flutter ➔ iOS App Group veri senkronizasyonu)
- `ios/IslamicAppWidget/IslamicAppWidget.swift` (Native SwiftUI: Small, Medium, LockScreen, Live Activities)

### E. Ses Motoru & Bildirimler
- `audioplayers: ^6.8.1` (Ezan makamları - Hicaz, Rast, Segah, Saba, Uşşak; Kur'an tilaveti)
- `flutter_local_notifications: ^22.3.1` (Vakit bildirimleri, ezan alarmları, kerahet uyarıları)
- `timezone: ^0.11.1` & `flutter_timezone: ^5.1.1` (Zaman dilimi senkronizasyonu)
- `flutter_tts: ^4.2.5` (Metinden sese çeviri)

### F. UI & Tipografi & Görselleştirme
- `google_fonts: ^6.2.1` (Amiri, Playfair Display, Outfits vb.)
- `flutter_svg: ^2.0.10+1`
- `cached_network_image: ^3.3.1`
- `cupertino_icons: ^1.0.6`

### G. Gelir Modeli & Mağaza Entegrasyonu
- `in_app_purchase: ^3.2.0` (StoreKit 2: Beyân Pro Ömür Boyu / Aylık / Yıllık)
- `google_mobile_ads: ^5.1.0` (Yalnızca ücretsiz kullanıcılar için banner/geçiş reklamları)
- `in_app_review: ^2.0.12`

---

## 3. PROJE DİZİN YAPISI VE MODÜL HARİTASI

```
lib/
├── main.dart                          # App bootstrap, Riverpod ProviderScope, crash-proof init
├── core/
│   ├── database/                      # SQLite bağlantı yöneticisi, migration scriptleri
│   ├── localization/                  # TR, EN, AR dil paketleri ve dinamik çeviri yöneticisi
│   ├── services/                      # Background fetch, App Group sync, audio player servisleri
│   ├── theme/                         # BeyanColors (matematiksel HSL renk motoru), 7 lüks palet
│   │   ├── app_theme.dart             # Tema tanımları, tipografi, ThemeData
│   │   ├── beyan_colors.dart          # Matematiksel HSL renk dönüştürücü (BeyanColors.tone)
│   │   └── theme_provider.dart        # Dinamik vakit teması ve kullanıcı paleti durumu
│   ├── utils/                         # Tarih hesaplayıcılar, Hicri takvim motoru, güvenli pop
│   └── widgets/                       # Ortak butonlar, buzlu cam (frosted glass) kapsülleri
└── features/
    ├── ai_assistant/                  # Beyân AI: İslami Soru-Cevap & Tefsir Rehberi (Gemini)
    ├── bedside_clock/                 # Gece saati modu, ambiyans OLED ekranı
    ├── calendar/                      # Hicri & Miladi takvim, Kandil ve Dini Günler
    ├── dhikr/                         # Dijital tesbihat, haptik titreşimli zikirmatik
    ├── dua/                           # Dualar ve Zikirler kütüphanesi, arama, favoriler
    ├── elif_ba/                       # Sesli ve interaktif Kur'an elifbası & tecvid
    ├── home/                          # Ana ekran: Güneş arkı, namaz kartı, 4'lü hızlı dock
    ├── kaza/                          # Kaza namazı ve oruç takip motoru
    ├── live_makkah/                   # Kabe ve Medine 7/24 canlı yayın ekranı (YouTube iFrame)
    ├── monetization/                  # Paywall sayfası, StoreKit abonelikleri, Premium kilitleri
    ├── mosque_finder/                 # En yakın camiler haritası
    ├── notifications/                 # Ezan makamı önizleme ve alarm zamanlama
    ├── prayer_guide/                  # Adım adım görsel ve sesli namaz kılınış rehberi
    ├── prayer_times/                  # Adhan kütüphanesi entegrasyonu, vakit hesaplama servisleri
    ├── qibla/                         # Gerçek zamanlı kıble pusulası, manyetik filtreleme
    ├── quran/                         # Çevrimdışı Kur'an-ı Kerim okuyucu, meal, tefsir, ses senkronu
    ├── ramadan/                       # İmsakiye, iftara kalan süre sayacı
    ├── settings/                      # Tema, dil, ezan sesi, hesaplama metodu ayarları
    ├── spiritual_healing/             # Şifa ayetleri, ruqyah ve manevi reçeteler
    ├── splash/                        # Native LaunchScreen ile birebir senkronize açılış ekranı
    ├── verse_studio/                  # Sosyal medya için ayet/hadis görseli tasarım stüdyosu
    └── widget_service/                # iOS WidgetKit & Live Activities veri köprüsü
```

---

## 4. DİKKAT EDİLECEK KRİTİK ALANLAR VE DENETİM SORULARI

Aşağıdaki alanları detaylıca inceleyerek muhtemel mimari zafiyetleri ve performans kayıplarını ortaya çıkarmanı istiyorum:

### 1. Flutter Render & Rebuild Optimizasyonu (UI/UX Akıcılığı)
- `features/home/screens/home_screen.dart` ve `prayer_card_widget.dart` içinde her saniye çalışan geri sayım sayacı (`Timer.periodic` veya Riverpod akışı) tüm ana ekranı gereksiz yere rebuild ediyor mu?
- `RepaintBoundary` nerelerde eksik? Güneş arkı (solar arc) çizimi ve sürekli dönen/güncellenen widget'lar izole edilmiş mi?
- Riverpod sağlayıcılarında `ref.watch()` yerine `ref.watch(provider.select(...))` kullanılmadığı için gereksiz tetiklenen sayfalar var mı?

### 2. Bellek Yönetimi ve Sızıntılar (Memory Leaks)
- `audioplayers` (`AudioPlayer`), `StreamSubscription` (Pusula `flutter_compass`, Konum `geolocator`), ve `AnimationController` nesnelerinin `dispose()` süreçlerinde olası leak'ler nelerdir?
- Kur'an-ı Kerim okuyucusunda (`quran/`) 604 sayfalık SQLite verisi veya Arapça SVG/Font glifleri listelenirken bellek şişmesi (RAM spike) nasıl önlenir? Liste sanallaştırması (virtualization) yeterli mi?

### 3. Arka Plan Süreçleri ve Pil Tüketimi (Battery & Background)
- iOS üzerinde her vakitte güvenilir şekilde ezan çalabilmek için `flutter_local_notifications` nasıl yapılandırılmalı? iOS'un katı arka plan kısıtlamalarında (Low Power Mode, background app refresh) alarmın gecikmemesi için en iyi pratikler nelerdir?
- Kıble pusulasında jiroskop ve manyetometre verisi dinlenirken sensor throttling (sensör hız limitleme) uygulanmazsa pil hızlı biter. Burada önerilen frekans nedir?

### 4. iOS WidgetKit & Native Entegrasyon
- `home_widget` üzerinden App Group'a (`group.com.smhisk60.beyan`) veri yazılırken I/O kilitlenmeleri nasıl önlenir?
- WidgetKit `TimelineProvider` yapılandırmasında Apple'ın widget yenileme bütçesini (refresh budget) aşmamak için `TimelineEntry` politikası nasıl olmalıdır?

### 5. SQLite & Çevrimdışı Veri Performansı
- Kur'an aramalarında (FTS - Full Text Search) veya dua filtrelemelerinde SQLite index'leme stratejisi nasıl olmalı? `LIKE '%sorgu%'` sorgularının ana UI thread'ini dondurmaması (jank) için `compute()` / isolate kullanımı nerelerde gereklidir?

---

## 5. SENDEN İSTENEN RAPOR FORMATI

Lütfen raporunu aşağıdaki bölümlere ayırarak net, teknik ve uygulanabilir şekilde sun:

1. **Özet Skor Kartı (Executive Scorecard):**
   - Performans Skoru (1-100)
   - Bellek & Kaynak Verimliliği (1-100)
   - iOS Ekosistem Uyumu (1-100)
2. **Kritik Hata & Risk Tablosu (Bug & Bottleneck Matrix):**
   - `[Kritik / Yüksek / Orta / Düşük]` seviyelendirilmiş sorun listesi, etkilenecek dosya ve potansiyel sonuç.
3. **Detaylı Kod Düzeltme Önerileri (Before / After Snippets):**
   - Özellikle `HomeScreen` rebuild izolasyonu, `QuranReader` sanallaştırma, `Compass` throttling ve `WidgetKit` timeline yönetimi için somut Dart ve Swift kod örnekleri.
4. **Hızlı Kazanımlar (Quick Wins):**
   - Hemen 1 saat içinde uygulanıp %30+ performans kazandıracak pratik adımlar.
```
