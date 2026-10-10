import WidgetKit
import SwiftUI
import ActivityKit
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
            Text("Sıradaki Namaz")
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
                Text("Sıradaki Namaz")
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
        .widgetURL(URL(string: "beyan://prayer"))
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

struct VerseProvider: TimelineProvider {
    private static let slot: TimeInterval = 15 * 60
    private static let appGroupId = "group.com.smhisk60.beyan"

    private static var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupId) ?? UserDefaults.standard
    }

    private func verse(at date: Date) -> VerseEntry {
        let defaults = Self.userDefaults
        if let appliedRef = defaults.string(forKey: "widget_applied_verse_ref"),
           let appliedText = defaults.string(forKey: "widget_applied_verse_text"),
           !appliedRef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !appliedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return VerseEntry(date: date, ref: appliedRef, text: appliedText)
        }

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
        let defaults = Self.userDefaults
        if let appliedRef = defaults.string(forKey: "widget_applied_verse_ref"),
           let appliedText = defaults.string(forKey: "widget_applied_verse_text"),
           !appliedRef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           !appliedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let singleEntry = VerseEntry(date: now, ref: appliedRef, text: appliedText)
            completion(Timeline(entries: [singleEntry], policy: .never))
            return
        }

        let slotStart = Date(timeIntervalSince1970: floor(now.timeIntervalSince1970 / Self.slot) * Self.slot)
        var entries = [verse(at: now)]
        for i in 1...96 {
            entries.append(verse(at: slotStart.addingTimeInterval(Double(i) * Self.slot)))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct VerseRectangularView: View {
    let entry: VerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.ref)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .lineLimit(1)
            Text(entry.text)
                .font(.system(size: 11, weight: .medium))
                .lineLimit(4)
                .minimumScaleFactor(0.65)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetAccentable()
    }
}

struct VerseSystemSmallView: View {
    let entry: VerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Günün Ayeti")
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
                    Text("Günün Ayet-i Kerimesi")
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
        let encodedRef = entry.ref.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "beyan://verse?ref=\(encodedRef)")
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall: VerseSystemSmallView(entry: entry)
            case .systemMedium: VerseSystemMediumView(entry: entry)
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
        .configurationDisplayName("Ayet")
        .description("Her 15 dakikada bir yeni ayet ve meali.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

// MARK: - Live Activity & Dynamic Island (ActivityKit)

@available(iOSApplicationExtension 16.1, *)
struct PrayerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var prayerName: String
        var prayerTime: String
        var targetDate: Date
        var progress: Double
    }
    var title: String
}

@available(iOSApplicationExtension 16.1, *)
struct PrayerLiveActivityBanner: View {
    let context: ActivityViewContext<PrayerActivityAttributes>

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    Text("Beyân • Sıradaki: \(context.state.prayerName)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Text(context.state.prayerTime)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }

            HStack {
                Text("Vakte Kalan Süre:")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(context.state.targetDate, style: .timer)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
            }

            ProgressView(value: context.state.progress)
                .tint(Color(red: 1.0, green: 0.85, blue: 0.45))
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(red: 0.01, green: 0.22, blue: 0.19), Color(red: 0.00, green: 0.12, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .widgetURL(URL(string: "beyan://prayer"))
    }
}

@available(iOSApplicationExtension 16.1, *)
struct BeyanLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            PrayerLiveActivityBanner(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        Text(context.state.prayerName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.prayerTime)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Kalan:")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text(context.state.targetDate, style: .timer)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                        }
                        ProgressView(value: context.state.progress)
                            .tint(Color(red: 1.0, green: 0.85, blue: 0.45))
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
                }
            } compactLeading: {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    .font(.system(size: 12))
            } compactTrailing: {
                Text(context.state.targetDate, style: .timer)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    .frame(width: 48)
            } minimal: {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.85, blue: 0.45))
                    .font(.system(size: 11))
            }
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
        if #available(iOSApplicationExtension 16.1, *) {
            BeyanLiveActivityWidget()
        }
    }
}
