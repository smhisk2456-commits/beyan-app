import UIKit
import Flutter
import UserNotifications
#if canImport(ActivityKit)
import ActivityKit
#endif

#if canImport(ActivityKit)
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
#endif

/// iOS ana AppDelegate.
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

        setupLiveActivityChannel()
        setupScreenChannel()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func setupScreenChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            DispatchQueue.main.async { [weak self] in
                self?.setupScreenChannel()
            }
            return
        }

        let channelNames = ["com.smhisk60.beyan/screen", "com.example.islamic_app/screen"]
        for channelName in channelNames {
            let channel = FlutterMethodChannel(
                name: channelName,
                binaryMessenger: controller.binaryMessenger
            )
            channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
                switch call.method {
                case "setKeepScreenOn":
                    let enabled = (call.arguments as? [String: Any])?["enabled"] as? Bool ?? false
                    DispatchQueue.main.async {
                        UIApplication.shared.isIdleTimerDisabled = enabled
                    }
                    result(true)
                default:
                    result(FlutterMethodNotImplemented)
                }
            }
        }
    }

    private func setupLiveActivityChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            DispatchQueue.main.async { [weak self] in
                self?.setupLiveActivityChannel()
            }
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.smhisk60.beyan/live_activity",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleLiveActivityCall(call: call, result: result)
        }
    }

    private func handleLiveActivityCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            switch call.method {
            case "startOrUpdateLiveActivity":
                guard let args = call.arguments as? [String: Any],
                      let prayerName = args["prayerName"] as? String,
                      let prayerTime = args["prayerTime"] as? String,
                      let targetTimestamp = args["targetTimestamp"] as? Double,
                      let cityName = args["cityName"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                    return
                }

                let isKerahat = args["isKerahat"] as? Bool ?? false
                let triggerMinutes = args["triggerMinutes"] as? Int ?? -1

                // Eğer canlı etkinlik devre dışı bırakılmışsa (-999), mevcutları durdur
                if triggerMinutes == -999 {
                    Task {
                        for activity in Activity<BeyanPrayerAttributes>.activities {
                            if #available(iOS 16.2, *) {
                                await activity.end(nil, dismissalPolicy: .immediate)
                            } else {
                                await activity.end(dismissalPolicy: .immediate)
                            }
                        }
                    }
                    result(true)
                    return
                }

                let contentState = BeyanPrayerAttributes.ContentState(
                    prayerName: prayerName,
                    prayerTime: prayerTime,
                    targetTimestamp: targetTimestamp,
                    cityName: cityName,
                    isKerahat: isKerahat,
                    triggerMinutes: triggerMinutes
                )

                guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                    result(FlutterError(code: "DISABLED", message: "Live Activities are disabled by user or system", details: nil))
                    return
                }

                let staleDate = Date(timeIntervalSince1970: targetTimestamp + 1800)

                // Sadece etkin (.active) canlı etkinlikleri bul; sonlanmış (.ended) olanları filtrele
                let activeActivities = Activity<BeyanPrayerAttributes>.activities.filter { $0.activityState == .active }

                if let existing = activeActivities.first {
                    Task {
                        if #available(iOS 16.2, *) {
                            await existing.update(ActivityContent<BeyanPrayerAttributes.ContentState>(state: contentState, staleDate: staleDate))
                        } else {
                            await existing.update(using: contentState)
                        }
                    }

                    if activeActivities.count > 1 {
                        for extra in activeActivities.dropFirst() {
                            Task {
                                if #available(iOS 16.2, *) {
                                    await extra.end(nil, dismissalPolicy: .immediate)
                                } else {
                                    await extra.end(dismissalPolicy: .immediate)
                                }
                            }
                        }
                    }
                    result(true)
                } else {
                    let attributes = BeyanPrayerAttributes(title: "Beyân Namaz Vakti")
                    do {
                        if #available(iOS 16.2, *) {
                            let content = ActivityContent(state: contentState, staleDate: staleDate)
                            _ = try Activity<BeyanPrayerAttributes>.request(
                                attributes: attributes,
                                content: content,
                                pushType: nil
                            )
                        } else {
                            _ = try Activity<BeyanPrayerAttributes>.request(
                                attributes: attributes,
                                contentState: contentState,
                                pushType: nil
                            )
                        }
                        result(true)
                    } catch {
                        result(FlutterError(code: "REQUEST_FAILED", message: error.localizedDescription, details: nil))
                    }
                }

            case "stopLiveActivity":
                Task {
                    for activity in Activity<BeyanPrayerAttributes>.activities {
                        if #available(iOS 16.2, *) {
                            await activity.end(nil, dismissalPolicy: .immediate)
                        } else {
                            await activity.end(dismissalPolicy: .immediate)
                        }
                    }
                    result(true)
                }

            case "isLiveActivitySupported":
                result(ActivityAuthorizationInfo().areActivitiesEnabled)

            default:
                result(FlutterMethodNotImplemented)
            }
            return
        }
        #endif

        if call.method == "isLiveActivitySupported" {
            result(false)
        } else {
            result(FlutterError(code: "UNSUPPORTED", message: "Live Activities require iOS 16.1+", details: nil))
        }
    }
}
