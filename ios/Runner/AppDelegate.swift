import UIKit
import Flutter
import UserNotifications
#if canImport(ActivityKit)
import ActivityKit
#endif

/// iOS ana AppDelegate.
/// Live Activities & Dynamic Island ve bildirim merkezi delegasyonu ayarlanmıştır.
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }
        GeneratedPluginRegistrant.register(with: self)

        // MARK: - Live Activity & Dynamic Island Method Channel
        let controller = window?.rootViewController as! FlutterViewController
        let liveActivityChannel = FlutterMethodChannel(
            name: "com.smhisk60.beyan/live_activity",
            binaryMessenger: controller.binaryMessenger
        )

        liveActivityChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            #if canImport(ActivityKit)
            if #available(iOS 16.1, *) {
                switch call.method {
                case "startLiveActivity":
                    guard let args = call.arguments as? [String: Any],
                          let prayerName = args["prayerName"] as? String,
                          let prayerTime = args["prayerTime"] as? String,
                          let targetTimestamp = args["targetTimestamp"] as? Double else {
                        result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing", details: nil))
                        return
                    }
                    let targetDate = Date(timeIntervalSince1970: targetTimestamp)
                    let progress = args["progress"] as? Double ?? 0.0

                    // Önceki etkinliği temizle
                    for activity in Activity<PrayerActivityAttributes>.activities {
                        Task { await activity.end(dismissalPolicy: .immediate) }
                    }

                    let attributes = PrayerActivityAttributes(title: "Beyân")
                    let contentState = PrayerActivityAttributes.ContentState(
                        prayerName: prayerName,
                        prayerTime: prayerTime,
                        targetDate: targetDate,
                        progress: progress
                    )

                    do {
                        let activity = try Activity.request(
                            attributes: attributes,
                            contentState: contentState,
                            pushType: nil
                        )
                        result(activity.id)
                    } catch {
                        result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
                    }

                case "updateLiveActivity":
                    guard let args = call.arguments as? [String: Any],
                          let prayerName = args["prayerName"] as? String,
                          let prayerTime = args["prayerTime"] as? String,
                          let targetTimestamp = args["targetTimestamp"] as? Double else {
                        result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing", details: nil))
                        return
                    }
                    let targetDate = Date(timeIntervalSince1970: targetTimestamp)
                    let progress = args["progress"] as? Double ?? 0.0

                    let updatedState = PrayerActivityAttributes.ContentState(
                        prayerName: prayerName,
                        prayerTime: prayerTime,
                        targetDate: targetDate,
                        progress: progress
                    )

                    for activity in Activity<PrayerActivityAttributes>.activities {
                        Task { await activity.update(using: updatedState) }
                    }
                    result(true)

                case "stopLiveActivity":
                    for activity in Activity<PrayerActivityAttributes>.activities {
                        Task { await activity.end(dismissalPolicy: .immediate) }
                    }
                    result(true)

                case "isLiveActivityActive":
                    let isActive = !Activity<PrayerActivityAttributes>.activities.isEmpty
                    result(isActive)

                default:
                    result(FlutterMethodNotImplemented)
                }
            } else {
                result(false)
            }
            #else
            result(false)
            #endif
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
