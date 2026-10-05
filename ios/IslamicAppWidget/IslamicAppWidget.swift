import WidgetKit
import SwiftUI

// ════════════════════════════════════════════════════════════════
// MARK: - Veri Modeli
// ════════════════════════════════════════════════════════════════

struct WidgetVerse: Codable {
    let ref: String
    let text: String
}

struct PrayerWidgetEntry: TimelineEntry {
    let date: Date
    let nextPrayerName: String
    let nextPrayerTime: String
    let countdown: String
    let ayahRef: String
    let ayahText: String

    static var placeholder: PrayerWidgetEntry {
        PrayerWidgetEntry(
            date: Date(),
            nextPrayerName: "Öğle",
            nextPrayerTime: "13:22",
            countdown: "2s 15dk kaldı",
            ayahRef: "An-Nahl 114",
            ayahText: "Be grateful for Allah's favor if you truly worship Him."
        )
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - UserDefaults Yardımcısı
// ════════════════════════════════════════════════════════════════

struct WidgetDataReader {
    static let appGroupId = "group.com.example.islamicApp"
    static var userDefaults: UserDefaults? { UserDefaults(suiteName: appGroupId) }

    static func string(_ key: String, default def: String = "") -> String {
        userDefaults?.string(forKey: key) ?? def
    }
    
    static func int(_ key: String, default def: Int = 10) -> Int {
        let val = userDefaults?.integer(forKey: key) ?? def
        return val <= 0 ? def : val
    }

    static func verses() -> [WidgetVerse] {
        let jsonString = string("widget_verses_json", default: "[]")
        if let data = jsonString.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([WidgetVerse].self, from: data),
           !decoded.isEmpty {
            return decoded
        }
        return [WidgetVerse(ref: "Fatiha 1", text: "Bismillahirrahmanirrahim")]
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - Timeline Provider
// ════════════════════════════════════════════════════════════════

struct PrayerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerWidgetEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            let verses = WidgetDataReader.verses()
            let entry = PrayerWidgetEntry(
                date: Date(),
                nextPrayerName: WidgetDataReader.string("widget_next_prayer", default: "Namaz"),
                nextPrayerTime: WidgetDataReader.string("widget_next_prayer_time", default: "--:--"),
                countdown: WidgetDataReader.string("widget_countdown", default: ""),
                ayahRef: verses.first?.ref ?? "",
                ayahText: verses.first?.text ?? ""
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let verses = WidgetDataReader.verses()
        let interval = WidgetDataReader.int("widget_update_interval", default: 10)
        let currentDate = Date()
        
        let nextPrayerName = WidgetDataReader.string("widget_next_prayer", default: "Namaz")
        let nextPrayerTime = WidgetDataReader.string("widget_next_prayer_time", default: "--:--")
        let countdown = WidgetDataReader.string("widget_countdown", default: "")

        var entries: [PrayerWidgetEntry] = []
        
        // 50 ayet için her {interval} dakikada bir entry oluştur
        for (index, verse) in verses.enumerated() {
            guard let entryDate = Calendar.current.date(byAdding: .minute, value: index * interval, to: currentDate) else { continue }
            
            let entry = PrayerWidgetEntry(
                date: entryDate,
                nextPrayerName: nextPrayerName,
                nextPrayerTime: nextPrayerTime,
                countdown: countdown,
                ayahRef: verse.ref,
                ayahText: verse.text
            )
            entries.append(entry)
        }

        // Timeline bittiğinde (örn: 50 * 10 = 500 dk sonra) Flutter'dan tekrar güncellenmiş listeyi istemek için .atEnd
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - Kilit Ekranı Dikdörtgen Tasarım (Kullanıcı İstediği)
// ════════════════════════════════════════════════════════════════

struct IslamicAppWidgetLockScreenView: View {
    let entry: PrayerWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Üst Satır: Ayet Referansı + Ay İkonu
            HStack(alignment: .center) {
                Text(entry.ayahRef)
                    .font(.system(size: 13, weight: .bold))
                Spacer()
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 10))
            }
            
            // Alt Satır: Ayet Metni
            Text(entry.ayahText)
                .font(.system(size: 11, weight: .regular))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .widgetAccentable()
    }
}

// Diğer View'lar (Medium, Circular, Inline) buraya sadece compact şekilde ekleniyor.
struct IslamicAppWidgetMediumView: View {
    let entry: PrayerWidgetEntry
    var body: some View { Text("Ana ekran widget tasarımı") }
}
struct IslamicAppWidgetCircularView: View {
    let entry: PrayerWidgetEntry
    var body: some View { Text(entry.nextPrayerTime) }
}
struct IslamicAppWidgetInlineView: View {
    let entry: PrayerWidgetEntry
    var body: some View { Text("\(entry.nextPrayerName) \(entry.nextPrayerTime)") }
}

struct IslamicAppWidget: Widget {
    let kind = "IslamicAppWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerTimelineProvider()) { entry in
            IslamicAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kilit Ekranı Ayeti")
        .description("Belirlediğiniz dakika aralıklarıyla kilit ekranında ayetler.")
        .supportedFamilies([.systemMedium, .accessoryRectangular, .accessoryCircular, .accessoryInline])
    }
}

struct IslamicAppWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerWidgetEntry

    var body: some View {
        switch family {
        case .accessoryRectangular: IslamicAppWidgetLockScreenView(entry: entry)
        case .systemMedium: IslamicAppWidgetMediumView(entry: entry)
        case .accessoryCircular: IslamicAppWidgetCircularView(entry: entry)
        case .accessoryInline: IslamicAppWidgetInlineView(entry: entry)
        default: IslamicAppWidgetLockScreenView(entry: entry)
        }
    }
}

@main
struct IslamicAppWidgetBundle: WidgetBundle {
    var body: some Widget {
        IslamicAppWidget()
    }
}
