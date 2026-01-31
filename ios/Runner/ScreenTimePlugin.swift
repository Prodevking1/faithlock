//
//  ScreenTimePlugin.swift
//  Runner
//
//  Created by Abdoul Rachid Tapsoba on 14/10/2025.
//


import Flutter
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity

// Mock FlutterMethodCall for internal testing
class MockFlutterMethodCall: FlutterMethodCall {
    init(method: String, arguments: Any?) {
        super.init()
        setValue(method, forKey: "method")
        setValue(arguments, forKey: "arguments")
    }
}

@available(iOS 16.0, *)
class ScreenTimePlugin: NSObject, FlutterPlugin {

    private let center = AuthorizationCenter.shared
    // Use named store to share with DeviceActivityMonitor extension
    private let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("faithlock"))

    // App Group for sharing data between app and extensions
    // CRITICAL: Must match ShieldActionExtension and AppGroupStorage.dart
    private let appGroupIdentifier = "group.com.appbiz.faithlock"
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

    // 🆕 CRITICAL: Store the FamilyActivitySelection in memory
    // ApplicationToken cannot be serialized, so we must keep it in memory
    private var currentSelection = FamilyActivitySelection()

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "faithlock/screentime",
            binaryMessenger: registrar.messenger()
        )
        let instance = ScreenTimePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isAuthorized":
            handleIsAuthorized(result: result)
        case "requestAuthorization":
            handleRequestAuthorization(result: result)
        case "presentAppPicker":
            handlePresentAppPicker(result: result)
        case "hasSelectedApps":
            handleHasSelectedApps(result: result)
        case "getSelectedApps":
            handleGetSelectedApps(result: result)
        case "startBlocking":
            // DEPRECATED: Now using DeviceActivity automatic scheduling
            result(FlutterError(
                code: "DEPRECATED",
                message: "startBlocking is deprecated. Use setupSchedules instead.",
                details: nil
            ))
        case "stopBlocking":
            handleStopBlocking(result: result)
        case "isMonitoring":
            handleIsMonitoring(result: result)
        case "getAuthorizationStatus":
            handleGetAuthorizationStatus(result: result)
        case "setupSchedules":
            handleSetupSchedules(call: call, result: result)
        case "removeAllSchedules":
            handleRemoveAllSchedules(result: result)
        case "temporaryUnlock":
            handleTemporaryUnlock(call: call, result: result)
        case "applyBlockingNow":
            handleApplyBlockingNow(result: result)
        case "debugShieldStatus":
            handleDebugShieldStatus(result: result)
        case "checkMonitorStatus":
            handleCheckMonitorStatus(result: result)
        case "getMonitorEventHistory":
            handleGetMonitorEventHistory(result: result)
        case "createTestSchedule":
            handleCreateTestSchedule(result: result)
        case "shouldNavigateToPrayer":
            handleShouldNavigateToPrayer(result: result)
        case "clearPrayerFlag":
            handleClearPrayerFlag(result: result)
        case "checkScheduleEnded":
            handleCheckScheduleEnded(result: result)
        case "clearScheduleEndedFlag":
            handleClearScheduleEndedFlag(result: result)
        case "applyShields":
            handleApplyShields(result: result)
        case "removeShields":
            handleRemoveShields(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Authorization

    private func handleIsAuthorized(result: @escaping FlutterResult) {
        let status = center.authorizationStatus
        result(status == .approved)
    }

    private func handleRequestAuthorization(result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            Task {
                do {
                    try await center.requestAuthorization(for: .individual)
                    let isApproved = center.authorizationStatus == .approved
                    await MainActor.run {
                        result(isApproved)
                    }
                } catch {
                    await MainActor.run {
                        result(FlutterError(
                            code: "AUTHORIZATION_ERROR",
                            message: "Failed to request authorization: \(error.localizedDescription)",
                            details: nil
                        ))
                    }
                }
            }
        } else {
            result(FlutterError(
                code: "IOS_VERSION_ERROR",
                message: "Screen Time API requires iOS 16.0 or later",
                details: nil
            ))
        }
    }

    private func handleGetAuthorizationStatus(result: @escaping FlutterResult) {
        let status = center.authorizationStatus
        switch status {
        case .notDetermined:
            result("Not Requested")
        case .denied:
            result("Denied")
        case .approved:
            result("Approved")
        @unknown default:
            result("Unknown")
        }
    }

    // MARK: - App Picker

    private func handlePresentAppPicker(result: @escaping FlutterResult) {
        // Check iOS version
        guard #available(iOS 16.0, *) else {
            result(FlutterError(
                code: "IOS_VERSION_ERROR",
                message: "App selection requires iOS 16.0 or later",
                details: nil
            ))
            return
        }

        // Check authorization
        guard center.authorizationStatus == .approved else {
            result(FlutterError(
                code: "NOT_AUTHORIZED",
                message: "Screen Time authorization required",
                details: nil
            ))
            return
        }

        // Present the picker on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Get the root view controller
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                result(FlutterError(
                    code: "NO_VIEW_CONTROLLER",
                    message: "Could not find root view controller",
                    details: nil
                ))
                return
            }

            // Load existing selection to show previously selected apps
            let existingSelection = self.loadSelectedApps()

            // Create and present picker with existing selection
            let pickerVC = FamilyActivityPickerViewController()
            pickerVC.setInitialSelection(existingSelection)
            pickerVC.modalPresentationStyle = .pageSheet

            if let sheet = pickerVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }

            pickerVC.setOnSelection { [weak self] selection in
                guard let self = self else { return }

                let hasSelection = !selection.applicationTokens.isEmpty ||
                                 !selection.categoryTokens.isEmpty ||
                                 !selection.webDomainTokens.isEmpty

                if hasSelection {
                    self.saveSelectedApps(selection)
                    self.applyShieldsImmediately(selection)
                    print("✅ App selection completed and shields applied")
                } else {
                    self.clearSelectedApps()
                    print("ℹ️ No apps selected, cleared existing selection")
                }
            }

            rootViewController.present(pickerVC, animated: true)
            result(true)
        }
    }

    private func saveSelectedApps(_ selection: FamilyActivitySelection) {
        currentSelection = selection

        let defaults = sharedDefaults ?? UserDefaults.standard

        if let encoded = try? JSONEncoder().encode(selection) {
            defaults.set(encoded, forKey: "familyActivitySelection")
            print("✅ Saved FamilyActivitySelection to App Group (\(selection.applicationTokens.count) apps)")
        } else {
            print("❌ Failed to encode FamilyActivitySelection")
        }

        defaults.set(selection.applicationTokens.count, forKey: "selectedAppsCount")
        defaults.set(selection.categoryTokens.count, forKey: "selectedCategoriesCount")
        defaults.set(selection.webDomainTokens.count, forKey: "selectedWebDomainsCount")
        defaults.set(Date(), forKey: "lastSelectionDate")
        defaults.synchronize()
    }

    private func clearSelectedApps() {
        currentSelection = FamilyActivitySelection()

        let defaults = sharedDefaults ?? UserDefaults.standard
        defaults.removeObject(forKey: "familyActivitySelection")
        defaults.set(0, forKey: "selectedAppsCount")
        defaults.set(0, forKey: "selectedCategoriesCount")
        defaults.set(0, forKey: "selectedWebDomainsCount")
        defaults.synchronize()

        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        let deviceActivityCenter = DeviceActivityCenter()
        deviceActivityCenter.stopMonitoring()

        print("🗑️ Cleared all selected apps and stopped all schedules")
    }

    private func applyShieldsImmediately(_ selection: FamilyActivitySelection) {
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
            print("🔒 Applied immediate shields to \(selection.applicationTokens.count) apps")
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
            print("🔒 Applied immediate shields to \(selection.categoryTokens.count) categories")
        }

        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
            print("🔒 Applied immediate shields to \(selection.webDomainTokens.count) web domains")
        }

        print("✅ Apps blocked immediately after selection")
    }

    private func handleApplyShields(result: @escaping FlutterResult) {
        let selection = loadSelectedApps()

        guard !selection.applicationTokens.isEmpty ||
              !selection.categoryTokens.isEmpty ||
              !selection.webDomainTokens.isEmpty else {
            result(FlutterError(
                code: "NO_APPS_SELECTED",
                message: "No apps selected to block",
                details: nil
            ))
            return
        }

        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
            print("🔒 Applied shields to \(selection.applicationTokens.count) apps")
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
            print("🔒 Applied shields to \(selection.categoryTokens.count) categories")
        }

        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
            print("🔒 Applied shields to \(selection.webDomainTokens.count) web domains")
        }

        print("✅ Shields applied - apps are now blocked")
        result(true)
    }

    private func handleRemoveShields(result: @escaping FlutterResult) {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        print("🔓 Shields removed - apps are now accessible")
        result(true)
    }

    private func loadSelectedApps() -> FamilyActivitySelection {
        // Try to load from App Group first (in case app restarted)
        if currentSelection.applicationTokens.isEmpty {
            let defaults = sharedDefaults ?? UserDefaults.standard
            if let selectionData = defaults.data(forKey: "familyActivitySelection"),
               let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData) {
                currentSelection = selection
                print("✅ Loaded FamilyActivitySelection from App Group (\(selection.applicationTokens.count) apps)")
            }
        }

        return currentSelection
    }

    private func handleHasSelectedApps(result: @escaping FlutterResult) {
        let selection = loadSelectedApps()
        let hasApps = !selection.applicationTokens.isEmpty ||
                     !selection.categoryTokens.isEmpty ||
                     !selection.webDomainTokens.isEmpty
        result(hasApps)
    }

    private func handleGetSelectedApps(result: @escaping FlutterResult) {
        let selection = loadSelectedApps()

        // Create response with counts (we can't get app names due to privacy)
        let response: [[String: Any]] = [
            [
                "type": "apps",
                "count": selection.applicationTokens.count,
                "description": "\(selection.applicationTokens.count) app(s) selected"
            ],
            [
                "type": "categories",
                "count": selection.categoryTokens.count,
                "description": "\(selection.categoryTokens.count) category(ies) selected"
            ],
            [
                "type": "webDomains",
                "count": selection.webDomainTokens.count,
                "description": "\(selection.webDomainTokens.count) website(s) selected"
            ]
        ]

        result(response)
    }

    // MARK: - Blocking

    private func handleStartBlocking(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let scheduleId = args["scheduleId"] as? String,
              let scheduleName = args["scheduleName"] as? String,
              let durationSeconds = args["durationSeconds"] as? Int else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Invalid arguments for startBlocking",
                details: nil
            ))
            return
        }

        // Check authorization
        guard center.authorizationStatus == .approved else {
            result(FlutterError(
                code: "NOT_AUTHORIZED",
                message: "Screen Time authorization not granted",
                details: nil
            ))
            return
        }

        // Apply blocking restrictions
        applyBlockingRestrictions()

        // Store blocking state
        let defaults = sharedDefaults ?? UserDefaults.standard
        defaults.set(true, forKey: "isBlocking")
        defaults.set(scheduleId, forKey: "currentScheduleId")
        defaults.set(scheduleName, forKey: "currentScheduleName")

        // Schedule auto-unlock after duration
        let unlockTime = Date().addingTimeInterval(TimeInterval(durationSeconds))
        defaults.set(unlockTime, forKey: "unlockTime")

        result(true)
    }

    private func handleStopBlocking(result: @escaping FlutterResult) {
        // Remove all restrictions
        if #available(iOS 16.0, *) {
            store.clearAllSettings()
        } else {
            // Manual clearing for iOS 15
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
            store.application.denyAppInstallation = false
            store.application.denyAppRemoval = false
            store.dateAndTime.requireAutomaticDateAndTime = false
            store.gameCenter.denyMultiplayerGaming = false
            store.gameCenter.denyAddingFriends = false
        }

        // Clear blocking state
        let defaults = sharedDefaults ?? UserDefaults.standard
        defaults.set(false, forKey: "isBlocking")
        defaults.removeObject(forKey: "currentScheduleId")
        defaults.removeObject(forKey: "currentScheduleName")
        defaults.removeObject(forKey: "unlockTime")

        result(true)
    }

    private func handleApplyBlockingNow(result: @escaping FlutterResult) {
        // Load selected apps
        let selection = loadSelectedApps()

        // Apply shields immediately
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }

        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
        }

        result(true)
    }

    private func handleIsMonitoring(result: @escaping FlutterResult) {
        let defaults = sharedDefaults ?? UserDefaults.standard
        let isBlocking = defaults.bool(forKey: "isBlocking")

        // Check if unlock time has passed
        if let unlockTime = defaults.object(forKey: "unlockTime") as? Date {
            if Date() >= unlockTime {
                // Auto unlock
                if #available(iOS 16.0, *) {
                    store.clearAllSettings()
                } else {
                    // Manual clearing for iOS 15
                    store.shield.applications = nil
                    store.shield.applicationCategories = nil
                    store.shield.webDomains = nil
                    store.application.denyAppInstallation = false
                    store.application.denyAppRemoval = false
                }
                defaults.set(false, forKey: "isBlocking")
                result(false)
                return
            }
        }

        result(isBlocking)
    }

    // MARK: - Helper Methods

    private func applyBlockingRestrictions() {
        let selection = loadSelectedApps()

        // Apply shields
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
        } else {
            store.shield.applications = nil
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
                selection.categoryTokens
            )
        } else {
            store.shield.applicationCategories = nil
        }

        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
        } else {
            store.shield.webDomains = nil
        }

        // Additional restrictions
        store.application.denyAppInstallation = true
        store.application.denyAppRemoval = true
        store.webContent.blockedByFilter = .all()
        store.dateAndTime.requireAutomaticDateAndTime = true
        store.gameCenter.denyMultiplayerGaming = true
        store.gameCenter.denyAddingFriends = true
    }

    // MARK: - DeviceActivity Schedules

    private func handleSetupSchedules(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 16.0, *) else {
            result(FlutterError(
                code: "IOS_VERSION_ERROR",
                message: "DeviceActivity schedules require iOS 16.0 or later",
                details: nil
            ))
            return
        }

        guard let args = call.arguments as? [[String: Any]] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Invalid schedule data",
                details: nil
            ))
            return
        }

        // Parse schedules from Flutter
        var schedules: [(name: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, enabled: Bool)] = []

        for scheduleDict in args {
            guard let name = scheduleDict["name"] as? String,
                  let startHour = scheduleDict["startHour"] as? Int,
                  let startMinute = scheduleDict["startMinute"] as? Int,
                  let endHour = scheduleDict["endHour"] as? Int,
                  let endMinute = scheduleDict["endMinute"] as? Int,
                  let enabled = scheduleDict["enabled"] as? Bool else {
                continue
            }

            if enabled {
                schedules.append((name, startHour, startMinute, endHour, endMinute, enabled))
            }
        }

        // Store schedules for DeviceActivityMonitor extension
        let defaults = sharedDefaults ?? UserDefaults.standard

        // Convert to encodable format
        let encodableSchedules = schedules.map { schedule in
            return [
                "name": schedule.name,
                "startHour": schedule.startHour,
                "startMinute": schedule.startMinute,
                "endHour": schedule.endHour,
                "endMinute": schedule.endMinute,
                "enabled": schedule.enabled
            ] as [String: Any]
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: encodableSchedules) {
            defaults.set(jsonData, forKey: "faithlock_schedules")
        }

        // Setup DeviceActivity monitoring for each schedule
        let deviceActivityCenter = DeviceActivityCenter()

        for schedule in schedules {
            let activityName = DeviceActivityName(schedule.name.replacingOccurrences(of: " ", with: "_"))

            let startComponents = DateComponents(hour: schedule.startHour, minute: schedule.startMinute)
            let endComponents = DateComponents(hour: schedule.endHour, minute: schedule.endMinute)

            let deviceSchedule = DeviceActivitySchedule(
                intervalStart: startComponents,
                intervalEnd: endComponents,
                repeats: true,
                warningTime: nil
            )

            do {
                // IMPORTANT: This triggers the DeviceActivityMonitor extension
                // The extension's intervalDidStart/intervalDidEnd methods will be called automatically
                try deviceActivityCenter.startMonitoring(activityName, during: deviceSchedule)
                print("✅ FaithLock: Started monitoring schedule '\(schedule.name)' - Extension will be activated automatically")
                print("   📅 Start: \(schedule.startHour):\(String(format: "%02d", schedule.startMinute))")
                print("   📅 End: \(schedule.endHour):\(String(format: "%02d", schedule.endMinute))")
            } catch {
                print("❌ FaithLock: Failed to start monitoring '\(schedule.name)': \(error)")
            }
        }

        if schedules.count > 0 {
            print("✅ FaithLock: \(schedules.count) enabled schedule(s) configured and monitoring started")
            print("ℹ️ Shields are already in store from app selection - DeviceActivityMonitor will manage them")
        } else {
            print("ℹ️ FaithLock: No enabled schedules - apps will not be blocked")
            print("💡 Enable at least one schedule to activate blocking")

            // ✅ CRITICAL: Remove any existing shields from store when no schedules are enabled
            print("🔓 Removing any existing shields from ManagedSettingsStore...")
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
            print("✅ All shields removed - apps are now accessible")
        }

        result(true)
    }

    private func handleRemoveAllSchedules(result: @escaping FlutterResult) {
        guard #available(iOS 16.0, *) else {
            result(true)
            return
        }

        let deviceActivityCenter = DeviceActivityCenter()

        // Stop all monitoring activities
        deviceActivityCenter.stopMonitoring()

        // Clear stored schedules
        let defaults = sharedDefaults ?? UserDefaults.standard
        defaults.removeObject(forKey: "faithlock_schedules")

        print("✅ FaithLock: Removed all schedules")

        // IMPORTANT: Remove shields immediately
        print("🔓 FaithLock: Removing all shields immediately...")
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        print("✅ FaithLock: All shields removed")

        result(true)
    }

    private func handleTemporaryUnlock(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 16.0, *) else {
            result(FlutterError(
                code: "IOS_VERSION_ERROR",
                message: "Temporary unlock requires iOS 16.0 or later",
                details: nil
            ))
            return
        }

        let deviceActivityCenter = DeviceActivityCenter()

        // Step 1: Stop ALL schedules
        deviceActivityCenter.stopMonitoring()

        // Step 2: Remove shields immediately
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        // Step 3: Restart ALL schedules
        let defaults = sharedDefaults ?? UserDefaults.standard
        guard let schedulesData = defaults.data(forKey: "faithlock_schedules"),
              let schedulesArray = try? JSONSerialization.jsonObject(with: schedulesData) as? [[String: Any]] else {
            print("⚠️ Prayer unlock: No schedules found to restart")
            result(true)
            return
        }

        // Parse schedules
        var schedules: [(name: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, enabled: Bool)] = []
        for scheduleDict in schedulesArray {
            guard let name = scheduleDict["name"] as? String,
                  let startHour = scheduleDict["startHour"] as? Int,
                  let startMinute = scheduleDict["startMinute"] as? Int,
                  let endHour = scheduleDict["endHour"] as? Int,
                  let endMinute = scheduleDict["endMinute"] as? Int,
                  let enabled = scheduleDict["enabled"] as? Bool,
                  enabled else {
                continue
            }
            schedules.append((name, startHour, startMinute, endHour, endMinute, enabled))
        }

        // Restart ALL enabled schedules
        var restartedCount = 0
        for schedule in schedules {
            let activityName = DeviceActivityName(schedule.name.replacingOccurrences(of: " ", with: "_"))
            let startComponents = DateComponents(hour: schedule.startHour, minute: schedule.startMinute)
            let endComponents = DateComponents(hour: schedule.endHour, minute: schedule.endMinute)

            let deviceSchedule = DeviceActivitySchedule(
                intervalStart: startComponents,
                intervalEnd: endComponents,
                repeats: true,
                warningTime: nil
            )

            do {
                try deviceActivityCenter.startMonitoring(activityName, during: deviceSchedule)
                restartedCount += 1
            } catch {
                print("❌ Failed to restart schedule '\(schedule.name)': \(error)")
            }
        }

        // DEBUG: Print restart summary
        if restartedCount > 0 {
            print("✅ Prayer unlock: Restarted \(restartedCount)/\(schedules.count) schedule(s)")
        } else {
            print("⚠️ Prayer unlock: No schedules were restarted")
        }

        result(true)
    }

    // MARK: - Debug Methods

    // MARK: - Monitor Diagnostic Methods

    /// Check if DeviceActivityMonitor extension is working
    private func handleCheckMonitorStatus(result: @escaping FlutterResult) {
        guard let defaults = sharedDefaults else {
            result([
                "isWorking": false,
                "message": "Cannot access App Group UserDefaults"
            ])
            return
        }

        var status: [String: Any] = [:]

        // Check if extension was ever initialized
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium

        if let extensionInit = defaults.string(forKey: "extensionLastInit"),
           let extensionInitDate = defaults.object(forKey: "extensionLastInitDate") as? Date {
            status["extensionLastInit"] = extensionInit
            status["extensionInitDate"] = formatter.string(from: extensionInitDate)
            print("✅ Extension was initialized: \(extensionInit) at \(formatter.string(from: extensionInitDate))")
        } else {
            status["extensionLastInit"] = nil
            status["extensionInitDate"] = nil
            print("⚠️ Extension NEVER initialized - iOS may not have loaded it")
        }

        // Check if monitor has ever been triggered
        if let lastEvent = defaults.string(forKey: "lastMonitorEvent"),
           let lastDate = defaults.object(forKey: "lastMonitorEventDate") as? Date,
           let lastActivity = defaults.string(forKey: "lastMonitorActivity") {

            status["isWorking"] = true
            status["lastEvent"] = lastEvent
            status["lastActivity"] = lastActivity
            status["lastEventDate"] = formatter.string(from: lastDate)
            status["minutesAgo"] = Int(Date().timeIntervalSince(lastDate) / 60)
            status["message"] = "✅ Monitor is working! Last event: \(lastEvent)"

        } else {
            status["isWorking"] = false
            status["message"] = "⚠️ Monitor never triggered. Either no schedule active or monitor extension not working."
        }

        // Add current time for reference
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        status["currentHour"] = components.hour ?? 0
        status["currentMinute"] = components.minute ?? 0

        result(status)
    }

    /// Get monitor event history
    private func handleGetMonitorEventHistory(result: @escaping FlutterResult) {
        guard let defaults = sharedDefaults else {
            result([])
            return
        }

        guard let history = defaults.array(forKey: "monitorEventHistory") as? [[String: Any]] else {
            result([])
            return
        }

        // Convert timestamps to readable dates
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium

        let readableHistory = history.map { event -> [String: Any] in
            var readable = event
            if let timestamp = event["timestamp"] as? TimeInterval {
                let date = Date(timeIntervalSince1970: timestamp)
                readable["dateString"] = formatter.string(from: date)
            }
            return readable
        }

        result(readableHistory)
    }

    /// Create a test schedule that starts in 3 minutes, lasts 15 minutes (iOS minimum)
    private func handleCreateTestSchedule(result: @escaping FlutterResult) {
        // Calculate start time (3 minutes from now - iOS needs buffer time)
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .minute, value: 3, to: now)!
        let endDate = calendar.date(byAdding: .minute, value: 18, to: now)! // 3 + 15 = 18 minutes from now (iOS requires minimum 15 minutes)

        let startComponents = calendar.dateComponents([.hour, .minute], from: startDate)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endDate)

        let testSchedule: [String: Any] = [
            "name": "TEST_MONITOR",
            "startHour": startComponents.hour!,
            "startMinute": startComponents.minute!,
            "endHour": endComponents.hour!,
            "endMinute": endComponents.minute!,
            "enabled": true
        ]

        print("========================================")
        print("🧪 CREATING TEST SCHEDULE (iOS requires 15 min minimum + buffer)")
        print("========================================")
        print("⏰ Current time: \(calendar.component(.hour, from: now)):\(String(format: "%02d", calendar.component(.minute, from: now)))")
        print("⏰ Will start in 3 minutes at: \(startComponents.hour!):\(String(format: "%02d", startComponents.minute!))")
        print("⏰ Will end in 18 minutes at: \(endComponents.hour!):\(String(format: "%02d", endComponents.minute!))")
        print("📱 Watch for notifications when monitor triggers!")
        print("📱 Apps will be blocked for 15 minutes minimum")
        print("⚠️ iOS needs 2-3 min buffer before schedule starts")
        print("========================================")

        // Setup the test schedule
        let mockCall = MockFlutterMethodCall(method: "setupSchedules", arguments: [testSchedule])
        handleSetupSchedules(call: mockCall, result: result)
    }

    private func handleDebugShieldStatus(result: @escaping FlutterResult) {
        // Simplified debug - check critical state only
        let selection = loadSelectedApps()
        let hasShields = store.shield.applications != nil

        print("Debug: \(selection.applicationTokens.count) apps, shields=\(hasShields)")
        result(true)
    }

    // MARK: - Shield Update Helpers

    private func updateShieldsIfScheduleActive() {
        let defaults = sharedDefaults ?? UserDefaults.standard
        guard let schedulesData = defaults.data(forKey: "faithlock_schedules"),
              let schedulesArray = try? JSONSerialization.jsonObject(with: schedulesData) as? [[String: Any]] else {
            return
        }

        // Parse schedules
        var schedules: [(name: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, enabled: Bool)] = []
        for scheduleDict in schedulesArray {
            guard let name = scheduleDict["name"] as? String,
                  let startHour = scheduleDict["startHour"] as? Int,
                  let startMinute = scheduleDict["startMinute"] as? Int,
                  let endHour = scheduleDict["endHour"] as? Int,
                  let endMinute = scheduleDict["endMinute"] as? Int,
                  let enabled = scheduleDict["enabled"] as? Bool else {
                continue
            }
            schedules.append((name, startHour, startMinute, endHour, endMinute, enabled))
        }

        // Check if any schedule is active and update shields accordingly
        checkAndApplyImmediateBlocking(schedules: schedules)
    }

    // MARK: - Immediate Blocking Check

    private func checkAndApplyImmediateBlocking(schedules: [(name: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, enabled: Bool)]) {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.hour, .minute], from: now)
        let currentHour = currentComponents.hour ?? 0
        let currentMinute = currentComponents.minute ?? 0

        let currentTimeInMinutes = currentHour * 60 + currentMinute

        var hasActiveSchedule = false

        for schedule in schedules where schedule.enabled {
            let startTimeInMinutes = schedule.startHour * 60 + schedule.startMinute
            let endTimeInMinutes = schedule.endHour * 60 + schedule.endMinute

            var isActive = false

            // Handle schedules that cross midnight
            if endTimeInMinutes < startTimeInMinutes {
                isActive = currentTimeInMinutes >= startTimeInMinutes || currentTimeInMinutes < endTimeInMinutes
            } else {
                isActive = currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes < endTimeInMinutes
            }

            if isActive {
                // Verify shields are in store
                if store.shield.applications == nil {
                    applyBlockingRestrictions()
                }
                hasActiveSchedule = true
                break
            }
        }
    }

    // MARK: - App Group Communication

    private func handleShouldNavigateToPrayer(result: @escaping FlutterResult) {
        // Read flag from App Group shared storage
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        let shouldNavigate = defaults?.bool(forKey: "should_navigate_to_prayer") ?? false

        if shouldNavigate {
            NSLog("✅ Prayer flag is set - should navigate to prayer")
        } else {
            NSLog("ℹ️ Prayer flag is not set")
        }

        result(shouldNavigate)
    }

    private func handleClearPrayerFlag(result: @escaping FlutterResult) {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        defaults?.removeObject(forKey: "should_navigate_to_prayer")
        defaults?.removeObject(forKey: "prayer_request_time")
        defaults?.synchronize()

        NSLog("🗑️ Prayer flag cleared from App Group")
        result(true)
    }

    private func handleCheckScheduleEnded(result: @escaping FlutterResult) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            result(nil)
            return
        }

        let scheduleEnded = defaults.string(forKey: "schedule_ended")
        result(scheduleEnded)
    }

    private func handleClearScheduleEndedFlag(result: @escaping FlutterResult) {
        guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
            result(false)
            return
        }

        defaults.removeObject(forKey: "schedule_ended")
        defaults.removeObject(forKey: "schedule_ended_time")
        defaults.synchronize()

        NSLog("✅ Schedule ended flag cleared")
        result(true)
    }
}
