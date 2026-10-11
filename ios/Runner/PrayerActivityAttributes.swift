import Foundation
#if canImport(ActivityKit)
import ActivityKit

public struct PrayerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var prayerName: String
        public var prayerTime: String
        public var targetDate: Date
        public var progress: Double

        public init(prayerName: String, prayerTime: String, targetDate: Date, progress: Double) {
            self.prayerName = prayerName
            self.prayerTime = prayerTime
            self.targetDate = targetDate
            self.progress = progress
        }
    }
    public var title: String

    public init(title: String) {
        self.title = title
    }
}
#endif
