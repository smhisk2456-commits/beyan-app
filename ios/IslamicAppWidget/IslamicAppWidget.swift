import WidgetKit
import SwiftUI
import ActivityKit
import Foundation
private let hhmm: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "tr_TR")
    f.dateFormat = "HH:mm"
    return f
}()

// MARK: - Konum

enum WidgetLocation {
    private static let latKey = "beyan_widget_lat"
    private static let lngKey = "beyan_widget_lng"

    static func coordinate() -> (lat: Double, lng: Double) {
        let defaults = UserDefaults(suiteName: "group.com.smhisk60.beyan") ?? UserDefaults.standard
        if defaults.object(forKey: latKey) != nil {
            let lat = defaults.double(forKey: latKey)
            let lng = defaults.double(forKey: lngKey)
            if lat != 0 && lng != 0 {
                return (lat, lng)
            }
        }
        return (41.0082, 28.9784) // İstanbul
    }
}

// MARK: - Çok Dilli Yerelleştirme (WidgetLocalization - 8 Dil)

enum WidgetLocalization {
    static var currentLanguage: String {
        let defaults = UserDefaults(suiteName: "group.com.smhisk60.beyan") ?? UserDefaults.standard
        if let lang = defaults.string(forKey: "widget_app_language"), !lang.isEmpty {
            return lang
        }
        if let pref = Locale.preferredLanguages.first {
            let prefix = String(pref.prefix(2)).lowercased()
            let supported = ["tr", "en", "ar", "id", "fr", "ur", "de", "ru"]
            if supported.contains(prefix) { return prefix }
        }
        return "en"
    }

    static func prayerName(for kind: PrayerKind) -> String {
        let lang = currentLanguage
        switch lang {
        case "en":
            switch kind {
            case .imsak: return "Fajr"
            case .gunes: return "Sunrise"
            case .ogle: return "Dhuhr"
            case .ikindi: return "Asr"
            case .aksam: return "Maghrib"
            case .yatsi: return "Isha"
            }
        case "id":
            switch kind {
            case .imsak: return "Subuh"
            case .gunes: return "Terbit"
            case .ogle: return "Dzuhur"
            case .ikindi: return "Ashar"
            case .aksam: return "Maghrib"
            case .yatsi: return "Isya"
            }
        case "ar":
            switch kind {
            case .imsak: return "الفجر"
            case .gunes: return "الشروق"
            case .ogle: return "الظهر"
            case .ikindi: return "العصر"
            case .aksam: return "المغرب"
            case .yatsi: return "العشاء"
            }
        case "fr":
            switch kind {
            case .imsak: return "Fajr"
            case .gunes: return "Lever"
            case .ogle: return "Dhuhr"
            case .ikindi: return "Asr"
            case .aksam: return "Maghrib"
            case .yatsi: return "Isha"
            }
        case "ur":
            switch kind {
            case .imsak: return "فجر"
            case .gunes: return "طلوع آفتاب"
            case .ogle: return "ظہر"
            case .ikindi: return "عصر"
            case .aksam: return "مغرب"
            case .yatsi: return "عشاء"
            }
        case "de":
            switch kind {
            case .imsak: return "Fadschr"
            case .gunes: return "Sonnenaufgang"
            case .ogle: return "Dhuhr"
            case .ikindi: return "Asr"
            case .aksam: return "Maghrib"
            case .yatsi: return "Ischaa"
            }
        case "ru":
            switch kind {
            case .imsak: return "Фаджр"
            case .gunes: return "Восход"
            case .ogle: return "Зухр"
            case .ikindi: return "Аср"
            case .aksam: return "Магриб"
            case .yatsi: return "Иша"
            }
        default: // "tr"
            switch kind {
            case .imsak: return "İmsak"
            case .gunes: return "Güneş"
            case .ogle: return "Öğle"
            case .ikindi: return "İkindi"
            case .aksam: return "Akşam"
            case .yatsi: return "Yatsı"
            }
        }
    }

    static var nextPrayerTitle: String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Next Prayer"
        case "id": return "Sholat Berikutnya"
        case "ar": return "الصلاة القادمة"
        case "fr": return "Prochaine Prière"
        case "ur": return "اگلی نماز"
        case "de": return "Nächstes Gebet"
        case "ru": return "Следующий намаз"
        default:   return "Sıradaki Namaz"
        }
    }

    static var countdownTitle: String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Countdown"
        case "id": return "Hitung Mundur"
        case "ar": return "العد التنازلي"
        case "fr": return "Compte à Rebours"
        case "ur": return "الٹی گنتی"
        case "de": return "Countdown"
        case "ru": return "Обратный отсчет"
        default:   return "Geri Sayım"
        }
    }

    static func timeUntil(prayer: String) -> String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Until \(prayer):"
        case "id": return "Menuju \(prayer):"
        case "ar": return "المتبقي لـ \(prayer):"
        case "fr": return "Jusqu'à \(prayer):"
        case "ur": return "\(prayer) تک:"
        case "de": return "Bis \(prayer):"
        case "ru": return "До \(prayer):"
        default:   return "\(prayer) Vaktine Kalan:"
        }
    }

    static func prayerTimeLabel(prayer: String, time: String) -> String {
        let lang = currentLanguage
        switch lang {
        case "en": return "\(prayer) Time: \(time)"
        case "id": return "Waktu \(prayer): \(time)"
        case "ar": return "وقت \(prayer): \(time)"
        case "fr": return "Heure de \(prayer): \(time)"
        case "ur": return "\(prayer) کا وقت: \(time)"
        case "de": return "\(prayer) Zeit: \(time)"
        case "ru": return "Время \(prayer): \(time)"
        default:   return "\(prayer) Saati: \(time)"
        }
    }

    static var verseOfTheDay: String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Verse of the Day"
        case "id": return "Ayat Hari Ini"
        case "ar": return "آية اليوم"
        case "fr": return "Verset du Jour"
        case "ur": return "آج کی آیت"
        case "de": return "Vers des Tages"
        case "ru": return "Аят Дня"
        default:   return "Günün Ayeti"
        }
    }

    static var verseOfTheDayLong: String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Verse of the Day"
        case "id": return "Ayat Suci Hari Ini"
        case "ar": return "آية اليوم الكريمة"
        case "fr": return "Saint Verset du Jour"
        case "ur": return "آج کی مقدس آیت"
        case "de": return "Vers des Tages"
        case "ru": return "Священный Аят Дня"
        default:   return "Günün Ayet-i Kerimesi"
        }
    }

    static var hijriCalendar: String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Hijri Calendar"
        case "id": return "Kalender Hijriah"
        case "ar": return "التقويم الهجري"
        case "fr": return "Calendrier Hégirien"
        case "ur": return "ہجری کیلنڈر"
        case "de": return "Hidschri-Kalender"
        case "ru": return "Хиджри Календарь"
        default:   return "Hicri Takvim"
        }
    }

    static var sunAndIshraq: String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Sunrise & Ishraq"
        case "id": return "Terbit & Isyraq"
        case "ar": return "الشروق والإشراق"
        case "fr": return "Lever du soleil & Ishraq"
        case "ur": return "طلوع و اشراق"
        case "de": return "Sonnenaufgang & Ischraq"
        case "ru": return "Восход и Ишрак"
        default:   return "Güneş & Kerâhet Vakti"
        }
    }

    static func sunInline(sunrise: String, ishraq: String) -> String {
        let lang = currentLanguage
        switch lang {
        case "en": return "☀️ Sunrise \(sunrise) • Ishraq \(ishraq)"
        case "id": return "☀️ Terbit \(sunrise) • Isyraq \(ishraq)"
        case "ar": return "☀️ الشروق \(sunrise) • الإشراق \(ishraq)"
        case "fr": return "☀️ Lever \(sunrise) • Ishraq \(ishraq)"
        case "ur": return "☀️ طلوع \(sunrise) • اشراق \(ishraq)"
        case "de": return "☀️ Sonnenaufgang \(sunrise) • Ischraq \(ishraq)"
        case "ru": return "☀️ Восход \(sunrise) • Ишрак \(ishraq)"
        default:   return "☀️ Güneş \(sunrise) • İşrak \(ishraq)"
        }
    }

    static func sunDetail(sunrise: String, ishraq: String) -> String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Sunrise: \(sunrise) • Ishraq: \(ishraq)"
        case "id": return "Terbit: \(sunrise) • Isyraq: \(ishraq)"
        case "ar": return "الشروق: \(sunrise) • الإشراق: \(ishraq)"
        case "fr": return "Lever: \(sunrise) • Ishraq: \(ishraq)"
        case "ur": return "طلوع: \(sunrise) • اشراق: \(ishraq)"
        case "de": return "Sonnenaufgang: \(sunrise) • Ischraq: \(ishraq)"
        case "ru": return "Восход: \(sunrise) • Ишрак: \(ishraq)"
        default:   return "Güneş: \(sunrise) • İşrak: \(ishraq)"
        }
    }

    static func duhaTime(ishraq: String) -> String {
        let lang = currentLanguage
        switch lang {
        case "en": return "Duha prayer starts: \(ishraq)"
        case "id": return "Mulai sholat Dhuha: \(ishraq)"
        case "ar": return "بداية صلاة الضحى: \(ishraq)"
        case "fr": return "Prière de Douha: \(ishraq)"
        case "ur": return "نماز چاشت کا وقت: \(ishraq)"
        case "de": return "Duha-Gebet ab: \(ishraq)"
        case "ru": return "Время намаза Духа: \(ishraq)"
        default:   return "Kerâhet çıkışı: \(ishraq) (Duhâ namazı)"
        }
    }

    static var fallbackVerse: (ref: String, text: String) {
        let lang = currentLanguage
        switch lang {
        case "en":
            return ("Al-Baqarah 2:153", "O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.")
        case "id":
            return ("Al-Baqarah 2:153", "Wahai orang-orang yang beriman! Mohonlah pertolongan (kepada Allah) dengan sabar dan sholat. Sungguh, Allah beserta orang-orang yang sabar.")
        case "ar":
            return ("البقرة ٢:١٥٣", "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ")
        case "fr":
            return ("Al-Baqarah 2:153", "Ô les croyants! Cherchez secours dans l'endurance et la prière. Car Allah est avec ceux qui sont endurants.")
        case "ur":
            return ("البقرۃ 2:153", "اے ایمان والو! صبر اور نماز سے مدد لو، بیشک اللہ صبر کرنے والوں کے ساتھ ہے۔")
        case "de":
            return ("Al-Baqarah 2:153", "O die ihr glaubt, sucht Hilfe in Geduld und Gebet! Gewiss, Allah ist mit den Standhaften.")
        case "ru":
            return ("Аль-Бакара 2:153", "О те, которые уверовали! Обратитесь за помощью к терпению и молитве. Воистину, Аллах — с терпеливыми.")
        default:
            return ("Bakara 2:153", "Ey iman edenler! Sabır ve namazla yardım dileyin. Şüphesiz Allah sabredenlerle beraberdir.")
        }
    }
}

// MARK: - Namaz Vakti Hesabı (Diyanet: Fecr 18°, İşa 17°, Hanefi ikindi)

enum PrayerKind: Int, CaseIterable {
    case imsak, gunes, ogle, ikindi, aksam, yatsi

    var name: String {
        return WidgetLocalization.prayerName(for: self)
    }

    var symbol: String {
        switch self {
        case .imsak: return "moon.haze.fill"
        case .gunes: return "sunrise.fill"
        case .ogle: return "sun.max.fill"
        case .ikindi: return "sun.min.fill"
        case .aksam: return "sunset.fill"
        case .yatsi: return "moon.stars.fill"
        }
    }
}

struct PrayerTime {
    let kind: PrayerKind
    let date: Date
}

private func dsin(_ d: Double) -> Double { sin(d * .pi / 180) }
private func dcos(_ d: Double) -> Double { cos(d * .pi / 180) }
private func dtan(_ d: Double) -> Double { tan(d * .pi / 180) }
private func darcsin(_ x: Double) -> Double { asin(x) * 180 / .pi }
private func darccos(_ x: Double) -> Double { acos(x) * 180 / .pi }
private func darctan2(_ y: Double, _ x: Double) -> Double { atan2(y, x) * 180 / .pi }
private func darccot(_ x: Double) -> Double { atan(1 / x) * 180 / .pi }
private func fixed(_ a: Double, _ b: Double) -> Double {
    let r = a - b * floor(a / b)
    return r < 0 ? r + b : r
}

struct PrayerCalculator {
    let lat: Double
    let lng: Double

    private func julian(_ year: Int, _ month: Int, _ day: Int) -> Double {
        var y = year
        var m = month
        if m <= 2 { y -= 1; m += 12 }
        let a = floor(Double(y) / 100)
        let b = 2 - a + floor(a / 4)
        return floor(365.25 * Double(y + 4716)) + floor(30.6001 * Double(m + 1)) + Double(day) + b - 1524.5
    }

    private func sunPosition(_ jd: Double) -> (decl: Double, eqt: Double) {
        let d = jd - 2451545.0
        let g = fixed(357.529 + 0.98560028 * d, 360)
        let q = fixed(280.459 + 0.98564736 * d, 360)
        let l = fixed(q + 1.915 * dsin(g) + 0.020 * dsin(2 * g), 360)
        let e = 23.439 - 0.00000036 * d
        let ra = darctan2(dcos(e) * dsin(l), dcos(l)) / 15
        let eqt = q / 15 - fixed(ra, 24)
        let decl = darcsin(dsin(e) * dsin(l))
        return (decl, eqt)
    }

    func times(for date: Date, timeZone: TimeZone) -> [PrayerTime] {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let c = cal.dateComponents([.year, .month, .day], from: date)
        let jDate = julian(c.year ?? 2026, c.month ?? 1, c.day ?? 1) - lng / (15 * 24)
        let dayStart = cal.startOfDay(for: date)
        let tzOffset = Double(timeZone.secondsFromGMT(for: dayStart.addingTimeInterval(12 * 3600))) / 3600

        func midDay(_ t: Double) -> Double {
            fixed(12 - sunPosition(jDate + t).eqt, 24)
        }
        func sunAngleTime(_ angle: Double, _ t: Double, ccw: Bool) -> Double {
            let decl = sunPosition(jDate + t).decl
            let noon = midDay(t)
            let v = (-dsin(angle) - dsin(decl) * dsin(lat)) / (dcos(decl) * dcos(lat))
            let span = darccos(min(1, max(-1, v))) / 15
            return noon + (ccw ? -span : span)
        }
        func asrTime(_ factor: Double, _ t: Double) -> Double {
            let decl = sunPosition(jDate + t).decl
            let angle = -darccot(factor + dtan(abs(lat - decl)))
            return sunAngleTime(angle, t, ccw: false)
        }

        var t: [Double] = [5, 6, 12, 13, 18, 18]
        for _ in 0..<2 {
            let p = t.map { $0 / 24 }
            t = [
                sunAngleTime(18, p[0], ccw: true),     // İmsak
                sunAngleTime(0.833, p[1], ccw: true),  // Güneş
                midDay(p[2]),                          // Öğle
                asrTime(1, p[3]),                      // İkindi (Diyanet resmi Asr-ı Evvel standardı)
                sunAngleTime(0.833, p[4], ccw: false), // Akşam
                sunAngleTime(17, p[5], ccw: false)     // Yatsı
            ]
        }

        // Diyanet resmi takvim temkin düzeltmeleri (dakika)
        let adjustments: [Double] = [0, -7, 5, 5, 8, 2]

        return PrayerKind.allCases.map { kind in
            let i = kind.rawValue
            let hours = t[i] + tzOffset - lng / 15
            var seconds = hours * 3600 + adjustments[i] * 60
            seconds = (seconds / 60).rounded() * 60
            return PrayerTime(kind: kind, date: dayStart.addingTimeInterval(seconds))
        }
    }
}

// MARK: - Namaz Vakti Widget'ı

struct PrayerEntry: TimelineEntry {
    let date: Date
    let current: PrayerTime
    let next: PrayerTime
}

struct PrayerProvider: TimelineProvider {
    private func schedule(around now: Date) -> [PrayerTime] {
        let loc = WidgetLocation.coordinate()
        let calc = PrayerCalculator(lat: loc.lat, lng: loc.lng)
        var all: [PrayerTime] = []
        for offset in -1...2 {
            if let day = Calendar.current.date(byAdding: .day, value: offset, to: now) {
                all += calc.times(for: day, timeZone: TimeZone.current)
            }
        }
        return all.sorted { $0.date < $1.date }
    }

    private func entry(at date: Date, in list: [PrayerTime]) -> PrayerEntry {
        let idx = list.lastIndex { $0.date <= date } ?? 0
        let nextIdx = min(idx + 1, list.count - 1)
        return PrayerEntry(date: date, current: list[idx], next: list[nextIdx])
    }

    func placeholder(in context: Context) -> PrayerEntry {
        let now = Date()
        return entry(at: now, in: schedule(around: now))
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        let now = Date()
        completion(entry(at: now, in: schedule(around: now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let now = Date()
        let list = schedule(around: now)
        var entries = [entry(at: now, in: list)]
        let limit = now.addingTimeInterval(24 * 3600)
        for p in list where p.date > now && p.date <= limit {
            entries.append(entry(at: p.date, in: list))
        }
        // Konum değişikliklerini yakalamak için 3 saatte bir yeniden hesapla
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(3 * 3600))))
    }
}

struct PrayerRectangularView: View {
    let entry: PrayerEntry

    private func row(_ p: PrayerTime) -> some View {
        HStack(spacing: 4) {
            Image(systemName: p.kind.symbol)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 16)
            Text("\(p.kind.name) \(hhmm.string(from: p.date))")
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            row(entry.current)
            row(entry.next)
            Text(entry.next.date, style: .timer)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
                .multilineTextAlignment(.leading)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetAccentable()
    }
}

struct PrayerCircularView: View {
    let entry: PrayerEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: entry.next.kind.symbol)
                    .font(.system(size: 13, weight: .semibold))
                Text(hhmm.string(from: entry.next.date))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding(4)
        }
        .widgetAccentable()
    }
}

struct PrayerInlineView: View {
    let entry: PrayerEntry

    var body: some View {
        Label("\(entry.next.kind.name) \(hhmm.string(from: entry.next.date))",
              systemImage: entry.next.kind.symbol)
    }
}

extension View {
    @ViewBuilder
    func beyanWidgetBackground(for family: WidgetFamily) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) {
                if family == .accessoryRectangular || family == .accessoryCircular || family == .accessoryInline {
                    Color.clear
                } else {
                    LinearGradient(
                        colors: [Color(red: 0.01, green: 0.22, blue: 0.19), Color(red: 0.00, green: 0.12, blue: 0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
        } else {
            if family == .accessoryRectangular || family == .accessoryCircular || family == .accessoryInline {
                self
            } else {
                self.background(
                    LinearGradient(
                        colors: [Color(red: 0.01, green: 0.22, blue: 0.19), Color(red: 0.00, green: 0.12, blue: 0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
    }
}

// MARK: - Namaz Vakti Widget Görünümleri

struct PrayerSystemSmallView: View {
    let entry: PrayerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Beyân")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                Spacer()
                Image(systemName: entry.next.kind.symbol)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }
            Spacer()
            Text(WidgetLocalization.nextPrayerTitle)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
            Text(entry.next.kind.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            HStack {
                Text(hhmm.string(from: entry.next.date))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(entry.next.date, style: .timer)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }
        }
        .padding(12)
    }
}

struct PrayerSystemMediumView: View {
    let entry: PrayerEntry

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    Text("Beyân")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                }
                Spacer()
                Text(WidgetLocalization.nextPrayerTitle)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                Text(entry.next.kind.name)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text(entry.next.date, style: .timer)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 6) {
                Text(hhmm.string(from: entry.next.date))
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Image(systemName: entry.current.kind.symbol)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                    Text("\(entry.current.kind.name) \(hhmm.string(from: entry.current.date))")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(14)
    }
}

struct PrayerWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular: PrayerCircularView(entry: entry)
            case .accessoryInline: PrayerInlineView(entry: entry)
            case .systemSmall: PrayerSystemSmallView(entry: entry)
            case .systemMedium: PrayerSystemMediumView(entry: entry)
            default: PrayerRectangularView(entry: entry)
            }
        }
        .beyanWidgetBackground(for: family)
        .widgetURL(URL(string: "beyan://prayer?homeWidget=true"))
    }
}

struct BeyanPrayerWidget: Widget {
    let kind = "BeyanPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("Namaz Vakti")
        .description("Şu anki vakit, sıradaki vakit ve canlı geri sayım.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

// MARK: - Ayet Widget'ı

struct VerseEntry: TimelineEntry {
    let date: Date
    let ref: String
    let text: String
}

struct DynamicVerseJsonItem: Codable {
    let ref: String
    let text: String
}

struct VerseProvider: TimelineProvider {
    private static let appGroupId = "group.com.smhisk60.beyan"

    private static func string(forKey key: String) -> String? {
        if let val = UserDefaults(suiteName: appGroupId)?.string(forKey: key), !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return val
        }
        if let val = UserDefaults.standard.string(forKey: key), !val.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return val
        }
        return nil
    }

    private static func bool(forKey key: String) -> Bool {
        if let defaults = UserDefaults(suiteName: appGroupId), defaults.object(forKey: key) != nil {
            return defaults.bool(forKey: key)
        }
        return UserDefaults.standard.bool(forKey: key)
    }

    private static func int(forKey key: String) -> Int {
        if let defaults = UserDefaults(suiteName: appGroupId), defaults.object(forKey: key) != nil {
            return defaults.integer(forKey: key)
        }
        return UserDefaults.standard.integer(forKey: key)
    }

    private static func slotDuration() -> TimeInterval {
        let intervalStr = Self.string(forKey: "widget_refresh_interval") ?? "1h"
        switch intervalStr {
        case "15m": return 15 * 60
        case "30m": return 30 * 60
        case "1h":  return 60 * 60
        case "1d":  return 24 * 3600
        default:    return 60 * 60
        }
    }

    private static func loadDynamicVerses() -> [(ref: String, text: String)] {
        if let jsonString = Self.string(forKey: "widget_verses_json"),
           let data = jsonString.data(using: .utf8),
           let items = try? JSONDecoder().decode([DynamicVerseJsonItem].self, from: data),
           !items.isEmpty {
            return items.map { ($0.ref, $0.text) }
        }
        return []
    }

    private static func allVerses() -> [(ref: String, text: String)] {
        let dynamic = loadDynamicVerses()
        if !dynamic.isEmpty {
            return dynamic
        }
        let lang = WidgetLocalization.currentLanguage
        if lang != "tr" {
            let localized = WidgetVerseData.multilingualFallbacks(for: lang)
            if !localized.isEmpty {
                return localized
            }
        }
        return WidgetVerseData.all
    }

    private func verse(at date: Date, preferApplied: Bool = false) -> VerseEntry {
        let isPinned = Self.bool(forKey: "widget_is_pinned")
        if (isPinned || preferApplied),
           let appliedRef = Self.string(forKey: "widget_applied_verse_ref"),
           let appliedText = Self.string(forKey: "widget_applied_verse_text"),
           !appliedRef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !appliedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return VerseEntry(date: date, ref: appliedRef, text: appliedText)
        }

        let pool = Self.allVerses()
        guard !pool.isEmpty else {
            let fallback = WidgetLocalization.fallbackVerse
            return VerseEntry(date: date, ref: fallback.ref, text: fallback.text)
        }

        let slot = Self.slotDuration()
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        let startOfDay = calendar.startOfDay(for: date)
        let slotIndex = Int(date.timeIntervalSince(startOfDay) / slot)
        let nonce = Self.int(forKey: "widget_apply_nonce")

        // Asla aynı sırayla tekrar etmeyen güçlü hash karıştırma algoritması
        let hash = abs((dayOfYear * 7919) ^ (year * 104729) ^ (slotIndex * 31) ^ (nonce * 17))
        let index = hash % pool.count
        let item = pool[index]
        return VerseEntry(date: date, ref: item.ref, text: item.text)
    }

    func placeholder(in context: Context) -> VerseEntry { verse(at: Date(), preferApplied: true) }

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
        completion(verse(at: Date(), preferApplied: true))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
        let now = Date()
        let isPinned = Self.bool(forKey: "widget_is_pinned")
        if isPinned,
           let appliedRef = Self.string(forKey: "widget_applied_verse_ref"),
           let appliedText = Self.string(forKey: "widget_applied_verse_text"),
           !appliedRef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !appliedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let singleEntry = VerseEntry(date: now, ref: appliedRef, text: appliedText)
            completion(Timeline(entries: [singleEntry], policy: .never))
            return
        }

        let slot = Self.slotDuration()
        let slotStart = Date(timeIntervalSince1970: floor(now.timeIntervalSince1970 / slot) * slot)
        var entries = [verse(at: now, preferApplied: true)]

        // 24 ila 48 aralık üretip widget kit döngüsüne sun
        let count = min(48, max(24, Int(86400 / slot)))
        for i in 1...count {
            let nextDate = slotStart.addingTimeInterval(Double(i) * slot)
            entries.append(verse(at: nextDate, preferApplied: false))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct VerseRectangularView: View {
    let entry: VerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            // Sûre Adı ve Âyet Numarası (Büyük ve kalın, görsel 1 ile birebir uyumlu)
            Text(entry.ref)
                .font(.system(size: 13.5, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            // Âyet Meali
            Text(entry.text)
                .font(.system(size: 10.5, weight: .medium))
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(3)
                .minimumScaleFactor(0.72)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetAccentable()
    }
}

struct VerseInlineView: View {
    let entry: VerseEntry

    var body: some View {
        Label("\(entry.ref): \(entry.text)", systemImage: "book.closed.fill")
    }
}

struct VerseSystemSmallView: View {
    let entry: VerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(WidgetLocalization.verseOfTheDay)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                Spacer()
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }
            Text(entry.ref)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Text(entry.text)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.88))
                .lineLimit(4)
                .minimumScaleFactor(0.85)
        }
        .padding(12)
    }
}

struct VerseSystemMediumView: View {
    let entry: VerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    Text(WidgetLocalization.verseOfTheDayLong)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                }
                Spacer()
                Text(entry.ref)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(entry.text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(3)
                .minimumScaleFactor(0.85)
        }
        .padding(14)
    }
}

struct VerseWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: VerseEntry

    private var targetUrl: URL? {
        let cleanRef = entry.ref
        var surahStr = ""
        var verseStr = ""

        let arabicToAscii: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"
        ]
        let normalizedRef = String(cleanRef.map { arabicToAscii[$0] ?? $0 })

        // 1. entry.ref içerisindeki sure ve ayet numarasını kesin regex ile bul (örn: "Bakara 2:153", "İnşirâh 94:6", "Tâhâ 20:25-26", "2:153")
        if let regex = try? NSRegularExpression(pattern: #"(\d+)\s*[:\.]\s*(\d+)"#) {
            let nsString = normalizedRef as NSString
            let results = regex.matches(in: normalizedRef, range: NSRange(location: 0, length: nsString.length))
            if let match = results.first, match.numberOfRanges >= 3 {
                surahStr = nsString.substring(with: match.range(at: 1))
                verseStr = nsString.substring(with: match.range(at: 2))
            }
        }

        // 2. Eğer entry.ref içinde numara bulunamadıysa, kaydedilen özel ayet bu ref ile eşleşiyorsa UserDefaults'a başvur
        if surahStr.isEmpty {
            let defaults = UserDefaults(suiteName: "group.com.smhisk60.beyan") ?? UserDefaults.standard
            let savedRef = defaults.string(forKey: "widget_applied_verse_ref") ?? ""
            let savedSurah = defaults.integer(forKey: "widget_applied_verse_surah")
            let savedVerse = defaults.integer(forKey: "widget_applied_verse_number")
            if savedSurah > 0 && (cleanRef == savedRef || cleanRef.isEmpty) {
                surahStr = String(savedSurah)
                verseStr = savedVerse > 0 ? String(savedVerse) : ""
            }
        }

        let encodedRef = cleanRef.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "beyan://verse?homeWidget=true&surah=\(surahStr)&verse=\(verseStr)&ref=\(encodedRef)")
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall: VerseSystemSmallView(entry: entry)
            case .systemMedium: VerseSystemMediumView(entry: entry)
            case .accessoryInline: VerseInlineView(entry: entry)
            default: VerseRectangularView(entry: entry)
            }
        }
        .beyanWidgetBackground(for: family)
        .widgetURL(targetUrl)
    }
}

struct BeyanVerseWidget: Widget {
    let kind = "BeyanVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
            VerseWidgetView(entry: entry)
        }
        .configurationDisplayName("Ayet & Meal")
        .description("Kilit ekranınızda ilham verici Kur'an ayeti ve meali.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Namaz Geri Sayımı Widget'ı (Canlı Sayaç)

struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                HStack(spacing: 3) {
                    Image(systemName: "timer")
                    Text("\(entry.next.kind.name) ")
                    Text(entry.next.date, style: .timer)
                }
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: 1) {
                        Image(systemName: entry.next.kind.symbol)
                            .font(.system(size: 12))
                        Text(entry.next.date, style: .timer)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                    }
                    .padding(2)
                }
                .widgetAccentable()
            case .systemSmall:
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(WidgetLocalization.countdownTitle)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        Spacer()
                        Image(systemName: "timer")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    }
                    Spacer()
                    Text(WidgetLocalization.timeUntil(prayer: entry.next.kind.name))
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.75))
                    Text(entry.next.date, style: .timer)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.white)
                    Text(WidgetLocalization.prayerTimeLabel(prayer: entry.next.kind.name, time: hhmm.string(from: entry.next.date)))
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                }
                .padding(12)
            default: // .accessoryRectangular
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 11, weight: .semibold))
                        Text(WidgetLocalization.timeUntil(prayer: entry.next.kind.name))
                            .font(.system(size: 11.5, weight: .bold))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white.opacity(0.85))
                    Text(entry.next.date, style: .timer)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                    Text(WidgetLocalization.prayerTimeLabel(prayer: entry.next.kind.name, time: hhmm.string(from: entry.next.date)))
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .widgetAccentable()
            }
        }
        .beyanWidgetBackground(for: family)
        .widgetURL(URL(string: "beyan://prayer?countdownWidget=true"))
    }
}

struct BeyanCountdownWidget: Widget {
    let kind = "BeyanCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Namaz Geri Sayımı")
        .description("Sıradaki vakte kalan süreyi canlı geri sayımla gösterir.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .accessoryCircular, .systemSmall])
    }
}

// MARK: - Hicri Takvim & Kandiller Widget'ı

enum HijriHelper {
    private static let monthsTr = [
        "", "Muharrem", "Safer", "Rebîülevvel", "Rebîülâhir",
        "Cemâziyelevvel", "Cemâziyelâhir", "Recep", "Şâban",
        "Ramazan", "Şevval", "Zilkade", "Zilhicce"
    ]
    private static let monthsId = [
        "", "Muharram", "Safar", "Rabiul Awal", "Rabiul Akhir",
        "Jumadil Awal", "Jumadil Akhir", "Rajab", "Sya'ban",
        "Ramadhan", "Syawal", "Dzulkaidah", "Dzulhijjah"
    ]
    private static let monthsEn = [
        "", "Muharram", "Safar", "Rabi' al-Awwal", "Rabi' al-Thani",
        "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban",
        "Ramadan", "Shawwal", "Dhu al-Qadah", "Dhu al-Hijjah"
    ]
    private static let monthsAr = [
        "", "محرم", "صفر", "ربيع الأول", "ربيع الآخر",
        "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان",
        "رمضان", "شوال", "ذو القعدة", "ذو الحجة"
    ]

    static func info(for date: Date) -> (day: Int, monthName: String, year: Int, specialNotice: String) {
        var cal = Calendar(identifier: .islamicUmmAlQura)
        cal.timeZone = TimeZone.current
        let day = cal.component(.day, from: date)
        let month = cal.component(.month, from: date)
        let year = cal.component(.year, from: date)

        let lang = WidgetLocalization.currentLanguage
        let months: [String] = {
            switch lang {
            case "id": return monthsId
            case "ar": return monthsAr
            case "tr": return monthsTr
            default:   return monthsEn
            }
        }()

        let monthName = (month >= 1 && month <= 12) ? months[month] : (months.count > 9 ? months[9] : "Ramadan")

        var notice = ""
        switch lang {
        case "id":
            if month == 9 {
                if day == 27 {
                    notice = "✨ Malam Lailatul Qadr"
                } else if day < 27 {
                    notice = "\(27 - day) hari menuju Lailatul Qadr"
                } else {
                    notice = "\(30 - day + 1) hari menuju Idul Fitri"
                }
            } else if month == 10 && day <= 3 {
                notice = "🎉 Hari Raya Idul Fitri"
            } else if month == 12 && day >= 10 && day <= 13 {
                notice = "🐑 Hari Raya Idul Adha"
            } else if month == 12 && day == 9 {
                notice = "🤲 Hari Arafah"
            } else if month == 8 && day == 15 {
                notice = "✨ Malam Nisfu Sya'ban"
            } else if month == 7 && day == 27 {
                notice = "✨ Isra Mi'raj"
            } else if month == 1 && day == 10 {
                notice = "Hari Asyura"
            } else if month == 3 && day == 12 {
                notice = "✨ Maulid Nabi Muhammad"
            } else {
                notice = "Tahun Baru Hijriah \(year)"
            }
        case "ar":
            if month == 9 {
                if day == 27 {
                    notice = "✨ ليلة القدر المباركة"
                } else if day < 27 {
                    notice = "بقي \(27 - day) يوم على ليلة القدر"
                } else {
                    notice = "بقي \(30 - day + 1) يوم على عيد الفطر"
                }
            } else if month == 10 && day <= 3 {
                notice = "🎉 عيد الفطر المبارك"
            } else if month == 12 && day >= 10 && day <= 13 {
                notice = "🐑 عيد الأضحى المبارك"
            } else if month == 12 && day == 9 {
                notice = "🤲 يوم عرفة"
            } else if month == 8 && day == 15 {
                notice = "✨ ليلة النصف من شعبان"
            } else if month == 7 && day == 27 {
                notice = "✨ ليلة الإسراء والمعراج"
            } else if month == 1 && day == 10 {
                notice = "يوم عاشوراء"
            } else if month == 3 && day == 12 {
                notice = "✨ المولد النبوي الشريف"
            } else {
                notice = "سنة هجرية مباركة \(year)"
            }
        case "tr":
            if month == 9 {
                if day == 27 {
                    notice = "✨ Mübarek Kadir Gecesi"
                } else if day < 27 {
                    notice = "Kadir Gecesine \(27 - day) gün kaldı"
                } else {
                    notice = "Ramazan Bayramına \(30 - day + 1) gün kaldı"
                }
            } else if month == 10 && day <= 3 {
                notice = "🎉 Ramazan Bayramı"
            } else if month == 12 && day >= 10 && day <= 13 {
                notice = "🐑 Kurban Bayramı"
            } else if month == 12 && day == 9 {
                notice = "🤲 Arefe Günü"
            } else if month == 8 && day == 15 {
                notice = "✨ Mübarek Berat Kandili"
            } else if month == 7 && day == 27 {
                notice = "✨ Mübarek Miraç Kandili"
            } else if month == 1 && day == 10 {
                notice = "Aşure Günü"
            } else if month == 3 && day == 12 {
                notice = "✨ Mevlid Kandili"
            } else {
                notice = "Mübarek Hicri \(year)"
            }
        default: // en, fr, de, ru, ur
            if month == 9 {
                if day == 27 {
                    notice = "✨ Blessed Laylat al-Qadr"
                } else if day < 27 {
                    notice = "\(27 - day) days to Laylat al-Qadr"
                } else {
                    notice = "\(30 - day + 1) days to Eid al-Fitr"
                }
            } else if month == 10 && day <= 3 {
                notice = "🎉 Eid al-Fitr"
            } else if month == 12 && day >= 10 && day <= 13 {
                notice = "🐑 Eid al-Adha"
            } else if month == 12 && day == 9 {
                notice = "🤲 Day of Arafah"
            } else if month == 8 && day == 15 {
                notice = "✨ Night of Mid-Sha'ban"
            } else if month == 7 && day == 27 {
                notice = "✨ Night of Isra & Mi'raj"
            } else if month == 1 && day == 10 {
                notice = "Day of Ashura"
            } else if month == 3 && day == 12 {
                notice = "✨ Mawlid al-Nabi"
            } else {
                notice = "Blessed Hijri \(year)"
            }
        }

        return (day, monthName, year, notice)
    }
}

struct HijriEntry: TimelineEntry {
    let date: Date
    let day: Int
    let monthName: String
    let year: Int
    let notice: String
}

struct HijriProvider: TimelineProvider {
    private func entry(at date: Date) -> HijriEntry {
        let info = HijriHelper.info(for: date)
        return HijriEntry(date: date, day: info.day, monthName: info.monthName, year: info.year, notice: info.specialNotice)
    }

    func placeholder(in context: Context) -> HijriEntry { entry(at: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (HijriEntry) -> Void) {
        completion(entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HijriEntry>) -> Void) {
        let now = Date()
        let cur = entry(at: now)
        let tomorrow = Calendar.current.startOfDay(for: now.addingTimeInterval(24 * 3600))
        completion(Timeline(entries: [cur], policy: .after(tomorrow)))
    }
}

struct HijriWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: HijriEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Text("🌙 \(entry.day) \(entry.monthName) \(String(entry.year))")
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: 0) {
                        Text("\(entry.day)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text(entry.monthName.prefix(4))
                            .font(.system(size: 9, weight: .semibold))
                            .lineLimit(1)
                    }
                    .padding(2)
                }
                .widgetAccentable()
            case .systemSmall:
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(WidgetLocalization.hijriCalendar)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        Spacer()
                        Image(systemName: "moon.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    }
                    Spacer()
                    Text("\(entry.day)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(entry.monthName) \(String(entry.year))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    Text(entry.notice)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .padding(12)
            default: // .accessoryRectangular
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        Text("\(entry.day) \(entry.monthName) \(String(entry.year))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    Text(entry.notice)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.88))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .widgetAccentable()
            }
        }
        .beyanWidgetBackground(for: family)
        .widgetURL(URL(string: "beyan://calendar?hijriWidget=true"))
    }
}

struct BeyanHijriWidget: Widget {
    let kind = "BeyanHijriWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HijriProvider()) { entry in
            HijriWidgetView(entry: entry)
        }
        .configurationDisplayName("Hicri Takvim & Kandil")
        .description("Hicri tarih, mübarek kandiller ve dini günleri takip edin.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline, .accessoryCircular, .systemSmall])
    }
}

// MARK: - Güneş & Kerâhet Vakti Widget'ı

struct SunEntry: TimelineEntry {
    let date: Date
    let sunrise: Date
    let ishraq: Date
}

struct SunProvider: TimelineProvider {
    private func entry(at date: Date) -> SunEntry {
        let loc = WidgetLocation.coordinate()
        let calc = PrayerCalculator(lat: loc.lat, lng: loc.lng)
        let list = calc.times(for: date, timeZone: TimeZone.current)
        let gunes = list.first { $0.kind == .gunes }?.date ?? date
        let ishraq = gunes.addingTimeInterval(45 * 60)
        return SunEntry(date: date, sunrise: gunes, ishraq: ishraq)
    }

    func placeholder(in context: Context) -> SunEntry { entry(at: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (SunEntry) -> Void) {
        completion(entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SunEntry>) -> Void) {
        let now = Date()
        let cur = entry(at: now)
        let nextDay = Calendar.current.startOfDay(for: now.addingTimeInterval(24 * 3600))
        completion(Timeline(entries: [cur], policy: .after(nextDay)))
    }
}

struct SunWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SunEntry

    var body: some View {
        Group {
            switch family {
            case .accessoryInline:
                Text(WidgetLocalization.sunInline(sunrise: hhmm.string(from: entry.sunrise), ishraq: hhmm.string(from: entry.ishraq)))
            default: // .accessoryRectangular
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        Text(WidgetLocalization.sunAndIshraq)
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                    Text(WidgetLocalization.sunDetail(sunrise: hhmm.string(from: entry.sunrise), ishraq: hhmm.string(from: entry.ishraq)))
                        .font(.system(size: 11.5, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                    Text(WidgetLocalization.duhaTime(ishraq: hhmm.string(from: entry.ishraq)))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.72))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .widgetAccentable()
            }
        }
        .beyanWidgetBackground(for: family)
        .widgetURL(URL(string: "beyan://prayer?sunWidget=true"))
    }
}

struct BeyanSunWidget: Widget {
    let kind = "BeyanSunWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SunProvider()) { entry in
            SunWidgetView(entry: entry)
        }
        .configurationDisplayName("Güneş & Kerâhet Vakti")
        .description("Güneş doğuşu, kerâhet çıkışı ve işrak namazı vaktini gösterir.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}

// MARK: - ActivityKit Live Activity & Dynamic Island (Apple Ekosistemi & Donanım)

struct BeyanPrayerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var prayerName: String
        var prayerTime: String
        var targetTimestamp: Double
        var cityName: String
        var isKerahat: Bool
        var triggerMinutes: Int?
    }

    var title: String
}

@available(iOSApplicationExtension 16.1, *)
struct BeyanLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BeyanPrayerAttributes.self) { context in
            let triggerMinutes: Int = {
                if let tm = context.state.triggerMinutes { return tm }
                let defaults = UserDefaults(suiteName: "group.com.smhisk60.beyan") ?? UserDefaults.standard
                let saved = defaults.integer(forKey: "live_activity_trigger_minutes")
                return saved != 0 ? saved : 45
            }()
            let remainingSeconds = context.state.targetTimestamp - Date().timeIntervalSince1970
            let remainingMinutes = remainingSeconds / 60.0
            let isWithinWindow = (triggerMinutes == -1) || (triggerMinutes == 0 && remainingSeconds <= 0) || (remainingMinutes <= Double(triggerMinutes))

            // Lock Screen / StandBy Banner UI
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [Color(red: 1.0, green: 0.87, blue: 0.48), Color(red: 0.72, green: 0.53, blue: 0.04)], center: .center, startRadius: 0, endRadius: 18))
                        .frame(width: 36, height: 36)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.01, green: 0.12, blue: 0.10))
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(context.state.prayerName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))

                        Text("• \(context.state.cityName)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Text("Vakit: \(context.state.prayerTime)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                if isWithinWindow {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(Date(timeIntervalSince1970: context.state.targetTimestamp), style: .timer)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))

                        Text("kaldı")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.prayerTime)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))

                        Text("\(triggerMinutes) dk kala başlar")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.01, green: 0.15, blue: 0.12), Color(red: 0.02, green: 0.22, blue: 0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .widgetURL(URL(string: "beyan://prayer"))
        } dynamicIsland: { context in
            let triggerMinutes: Int = {
                if let tm = context.state.triggerMinutes { return tm }
                let defaults = UserDefaults(suiteName: "group.com.smhisk60.beyan") ?? UserDefaults.standard
                let saved = defaults.integer(forKey: "live_activity_trigger_minutes")
                return saved != 0 ? saved : 45
            }()
            let remainingSeconds = context.state.targetTimestamp - Date().timeIntervalSince1970
            let remainingMinutes = remainingSeconds / 60.0
            let isWithinWindow = (triggerMinutes == -1) || (triggerMinutes == 0 && remainingSeconds <= 0) || (remainingMinutes <= Double(triggerMinutes))

            return DynamicIsland {
                // Expanded UI (Long press on island)
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
                        Text(context.state.prayerName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
                    }
                    .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if isWithinWindow {
                        Text(Date(timeIntervalSince1970: context.state.targetTimestamp), style: .timer)
                            .font(.system(size: 14, weight: .bold))
                            .monospacedDigit()
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
                            .padding(.trailing, 8)
                    } else {
                        Text("\(triggerMinutes) dk kala")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
                            .padding(.trailing, 8)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("Vakit: \(context.state.prayerTime)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(context.state.cityName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)
                }
            } compactLeading: {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
            } compactTrailing: {
                if isWithinWindow {
                    Text(Date(timeIntervalSince1970: context.state.targetTimestamp), style: .timer)
                        .monospacedDigit()
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
                        .frame(width: 44)
                } else {
                    Text(context.state.prayerTime)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
                        .frame(width: 44)
                }
            } minimal: {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.87, blue: 0.48))
            }
            .widgetURL(URL(string: "beyan://prayer"))
        }
    }
}

// MARK: - Bundle

@main
struct BeyanWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        BeyanVerseWidget()
        BeyanPrayerWidget()
        BeyanCountdownWidget()
        BeyanHijriWidget()
        BeyanSunWidget()
        if #available(iOSApplicationExtension 16.1, *) {
            BeyanLiveActivity()
        }
    }
}
