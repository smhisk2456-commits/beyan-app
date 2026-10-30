import UIKit
import Flutter
import UserNotifications
import MediaPlayer
import AVFoundation
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
        setupNowPlayingChannel()

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

    // ── Kilit Ekranı ve Control Center Medya Kartı (Now Playing) ──
    private var nowPlayingChannel: FlutterMethodChannel?
    private var remoteCommandsConfigured = false

    private func setupNowPlayingChannel() {
        guard let controller = window?.rootViewController as? FlutterViewController else {
            DispatchQueue.main.async { [weak self] in
                self?.setupNowPlayingChannel()
            }
            return
        }

        let channel = FlutterMethodChannel(
            name: "com.smhisk60.beyan/now_playing",
            binaryMessenger: controller.binaryMessenger
        )
        self.nowPlayingChannel = channel

        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "updateNowPlaying":
                guard let args = call.arguments as? [String: Any] else {
                    result(false)
                    return
                }
                self?.handleUpdateNowPlaying(args: args)
                result(true)
            case "clearNowPlaying":
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        setupRemoteCommands()
    }

    private func setupRemoteCommands() {
        guard !remoteCommandsConfigured else { return }
        remoteCommandsConfigured = true

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.nowPlayingChannel?.invokeMethod("onRemotePlay", arguments: nil)
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.nowPlayingChannel?.invokeMethod("onRemotePause", arguments: nil)
            return .success
        }

        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.nowPlayingChannel?.invokeMethod("onRemoteTogglePlayPause", arguments: nil)
            return .success
        }

        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nowPlayingChannel?.invokeMethod("onRemoteNext", arguments: nil)
            return .success
        }

        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.nowPlayingChannel?.invokeMethod("onRemotePrevious", arguments: nil)
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let posEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.nowPlayingChannel?.invokeMethod("onRemoteSeek", arguments: ["positionSeconds": posEvent.positionTime])
                return .success
            }
            return .commandFailed
        }
    }

    private func handleUpdateNowPlaying(args: [String: Any]) {
        var info = [String: Any]()
        if let title = args["title"] as? String {
            info[MPMediaItemPropertyTitle] = title
        }
        if let artist = args["artist"] as? String {
            info[MPMediaItemPropertyArtist] = artist
        }
        if let albumTitle = args["albumTitle"] as? String {
            info[MPMediaItemPropertyAlbumTitle] = albumTitle
        }
        if let duration = args["durationSeconds"] as? Double, duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        if let position = args["positionSeconds"] as? Double {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = position
        }
        let isPlaying = args["isPlaying"] as? Bool ?? true
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        if let icon = UIImage(named: "AppIcon") ?? UIImage(named: "AppIcon60x60") {
            let artwork = MPMediaItemArtwork(boundsSize: icon.size) { _ in icon }
            info[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
