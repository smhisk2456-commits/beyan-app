import WidgetKit
import SwiftUI
import CoreLocation

// ════════════════════════════════════════════════════════════════
// Beyân – iPhone Kilit Ekranı Widget'ları
//
// 1) "Ayet"        → Sure adı + ayet no (kalın) ve Türkçe meal (3 satır)
// 2) "Namaz Vakti" → Şu anki vakit, sıradaki vakit ve canlı geri sayım
//
// Widget tamamen kendi kendine yeterlidir: App Group gerektirmez
// (ücretsiz Apple ID + Sideloadly ile de çalışır). Namaz vakitleri
// uygulamadaki ile aynı yöntemle (Diyanet / Hanefi) cihazda hesaplanır.
// ════════════════════════════════════════════════════════════════

// MARK: - Ortak Yardımcılar

private let hhmm: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "tr_TR")
    f.dateFormat = "HH:mm"
    return f
}()

extension View {
    /// iOS 17+ widget'larda zorunlu olan containerBackground uyumluluğu.
    @ViewBuilder
    func beyanWidgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) { Color.clear }
        } else {
            self
        }
    }
}

// MARK: - Konum

enum WidgetLocation {
    private static let latKey = "beyan_widget_lat"
    private static let lngKey = "beyan_widget_lng"

    /// Önce cihazın son bilinen konumu, sonra kayıtlı konum, en son İstanbul.
    static func coordinate() -> (lat: Double, lng: Double) {
        let defaults = UserDefaults.standard
        if let loc = CLLocationManager().location {
            defaults.set(loc.coordinate.latitude, forKey: latKey)
            defaults.set(loc.coordinate.longitude, forKey: lngKey)
            return (loc.coordinate.latitude, loc.coordinate.longitude)
        }
        if defaults.object(forKey: latKey) != nil {
            return (defaults.double(forKey: latKey), defaults.double(forKey: lngKey))
        }
        return (41.0082, 28.9784) // İstanbul
    }
}

// MARK: - Namaz Vakti Hesabı (Diyanet: Fecr 18°, İşa 17°, Hanefi ikindi)

enum PrayerKind: Int, CaseIterable {
    case imsak, gunes, ogle, ikindi, aksam, yatsi

    var name: String {
        switch self {
        case .imsak: return "İmsak"
        case .gunes: return "Güneş"
        case .ogle: return "Öğle"
        case .ikindi: return "İkindi"
        case .aksam: return "Akşam"
        case .yatsi: return "Yatsı"
        }
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
                asrTime(2, p[3]),                      // İkindi (Hanefi)
                sunAngleTime(0.833, p[4], ccw: false), // Akşam
                sunAngleTime(17, p[5], ccw: false)     // Yatsı
            ]
        }

        // Diyanet temkin düzeltmeleri (dakika)
        let adjustments: [Double] = [0, -7, 5, 4, 7, 0]

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

struct PrayerWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerEntry

    var body: some View {
        switch family {
        case .accessoryCircular: PrayerCircularView(entry: entry)
        case .accessoryInline: PrayerInlineView(entry: entry)
        default: PrayerRectangularView(entry: entry)
        }
    }
}

struct BeyanPrayerWidget: Widget {
    let kind = "BeyanPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerWidgetView(entry: entry).beyanWidgetBackground()
        }
        .configurationDisplayName("Namaz Vakti")
        .description("Şu anki vakit, sıradaki vakit ve canlı geri sayım.")
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

// MARK: - Ayet Widget'ı

struct VerseEntry: TimelineEntry {
    let date: Date
    let ref: String
    let text: String
}

struct VerseProvider: TimelineProvider {
    /// 15 dakikalık dilimlere göre ayet seçer (her dilimde farklı ayet).
    private static let slot: TimeInterval = 15 * 60

    private func verse(at date: Date) -> VerseEntry {
        let all = WidgetVerseData.all
        guard !all.isEmpty else {
            return VerseEntry(date: date, ref: "Bakara 2:153",
                              text: "Ey İnananlar! Sabır ve namazla yardım dileyin.")
        }
        let index = Int(date.timeIntervalSince1970 / Self.slot) % all.count
        return VerseEntry(date: date, ref: all[index].ref, text: all[index].text)
    }

    func placeholder(in context: Context) -> VerseEntry { verse(at: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
        completion(verse(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
        let now = Date()
        let slotStart = Date(timeIntervalSince1970: floor(now.timeIntervalSince1970 / Self.slot) * Self.slot)
        var entries = [verse(at: now)]
        for i in 1...96 { // 24 saat
            entries.append(verse(at: slotStart.addingTimeInterval(Double(i) * Self.slot)))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct VerseRectangularView: View {
    let entry: VerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(entry.ref)
                .font(.system(size: 15, weight: .bold))
                .lineLimit(1)
            Text(entry.text)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetAccentable()
    }
}

struct BeyanVerseWidget: Widget {
    let kind = "BeyanVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VerseProvider()) { entry in
            VerseRectangularView(entry: entry).beyanWidgetBackground()
        }
        .configurationDisplayName("Ayet")
        .description("Kilit ekranında her 15 dakikada bir yeni ayet ve meali.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Bundle

@main
struct BeyanWidgetBundle: WidgetBundle {
    var body: some Widget {
        BeyanVerseWidget()
        BeyanPrayerWidget()
    }
}
