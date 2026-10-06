/// Beyân - Önceden Tanımlı Şehirler ve Koordinatları (Çevrimdışı/Manuel Konum Seçimi İçin)
class CityItem {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const CityItem({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

final List<CityItem> predefinedCitiesList = [
  // Türkiye Şehirleri
  const CityItem(name: 'İstanbul', country: 'Türkiye', latitude: 41.0082, longitude: 28.9784),
  const CityItem(name: 'Ankara', country: 'Türkiye', latitude: 39.9334, longitude: 32.8597),
  const CityItem(name: 'İzmir', country: 'Türkiye', latitude: 38.4192, longitude: 27.1287),
  const CityItem(name: 'Bursa', country: 'Türkiye', latitude: 40.1885, longitude: 29.0610),
  const CityItem(name: 'Antalya', country: 'Türkiye', latitude: 36.8969, longitude: 30.7133),
  const CityItem(name: 'Adana', country: 'Türkiye', latitude: 37.0000, longitude: 35.3213),
  const CityItem(name: 'Konya', country: 'Türkiye', latitude: 37.8667, longitude: 32.4833),
  const CityItem(name: 'Gaziantep', country: 'Türkiye', latitude: 37.0662, longitude: 37.3833),
  const CityItem(name: 'Şanlıurfa', country: 'Türkiye', latitude: 37.1591, longitude: 38.7969),
  const CityItem(name: 'Kocaeli', country: 'Türkiye', latitude: 40.7654, longitude: 29.9408),
  const CityItem(name: 'Mersin', country: 'Türkiye', latitude: 36.8000, longitude: 34.6333),
  const CityItem(name: 'Diyarbakır', country: 'Türkiye', latitude: 37.9144, longitude: 40.2306),
  const CityItem(name: 'Hatay', country: 'Türkiye', latitude: 36.4018, longitude: 36.3498),
  const CityItem(name: 'Kayseri', country: 'Türkiye', latitude: 38.7312, longitude: 35.4787),
  const CityItem(name: 'Eskişehir', country: 'Türkiye', latitude: 39.7767, longitude: 30.5206),
  const CityItem(name: 'Samsun', country: 'Türkiye', latitude: 41.2867, longitude: 36.33),
  const CityItem(name: 'Trabzon', country: 'Türkiye', latitude: 41.0027, longitude: 39.7168),
  const CityItem(name: 'Erzurum', country: 'Türkiye', latitude: 39.9043, longitude: 41.2678),
  const CityItem(name: 'Malatya', country: 'Türkiye', latitude: 38.3552, longitude: 38.3095),
  const CityItem(name: 'Kahramanmaraş', country: 'Türkiye', latitude: 37.5858, longitude: 36.9371),
  const CityItem(name: 'Van', country: 'Türkiye', latitude: 38.4891, longitude: 43.4089),

  // İslam Dünyası & Manevi Merkezler
  const CityItem(name: 'Mekke-i Mükerreme', country: 'Suudi Arabistan', latitude: 21.4225, longitude: 39.8262),
  const CityItem(name: 'Medine-i Münevvere', country: 'Suudi Arabistan', latitude: 24.5247, longitude: 39.5692),
  const CityItem(name: 'Kudüs-ü Şerif', country: 'Filistin', latitude: 31.7683, longitude: 35.2137),
  const CityItem(name: 'Kahire', country: 'Mısır', latitude: 30.0444, longitude: 31.2357),
  const CityItem(name: 'Bağdat', country: 'Irak', latitude: 33.3152, longitude: 44.3661),
  const CityItem(name: 'Şam', country: 'Suriye', latitude: 33.5138, longitude: 36.2765),
  const CityItem(name: 'Saraybosna', country: 'Bosna-Hersek', latitude: 43.8563, longitude: 18.4131),
  const CityItem(name: 'Bakü', country: 'Azerbaycan', latitude: 40.4093, longitude: 49.8671),
  const CityItem(name: 'Taşkent', country: 'Özbekistan', latitude: 41.2995, longitude: 69.2401),
  const CityItem(name: 'Semerkant', country: 'Özbekistan', latitude: 39.6270, longitude: 66.9749),

  // Avrupa ve Dünya Şehirleri
  const CityItem(name: 'Londra', country: 'İngiltere', latitude: 51.5074, longitude: -0.1278),
  const CityItem(name: 'Berlin', country: 'Almanya', latitude: 52.5200, longitude: 13.4050),
  const CityItem(name: 'Köln', country: 'Almanya', latitude: 50.9375, longitude: 6.9603),
  const CityItem(name: 'Paris', country: 'Fransa', latitude: 48.8566, longitude: 2.3522),
  const CityItem(name: 'Viyana', country: 'Avusturya', latitude: 48.2082, longitude: 16.3738),
  const CityItem(name: 'Amsterdam', country: 'Hollanda', latitude: 52.3676, longitude: 4.9041),
  const CityItem(name: 'New York', country: 'ABD', latitude: 40.7128, longitude: -74.0060),
];
