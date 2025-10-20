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

@available(iOS 16.0, *)
class ScreenTimePlugin: NSObject, FlutterPlugin {

    private let center = AuthorizationCenter.shared
    // Use named store to share with DeviceActivityMonitor extension
    private let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("faithlock"))

    // App Group for sharing data (optional but recommended)
    private let appGroupIdentifier = "group.com.appbiz.faithlock"
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }

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

                // Save the selection
                self.saveSelectedApps(selection)

                // Don't block immediately - let schedules control it
                // The DeviceActivityMonitor will handle blocking during scheduled times

                // Log selection
                print("📱 FaithLock: Saved \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories, \(selection.webDomainTokens.count) web domains")
                print("⏰ Apps will be blocked during scheduled times only")

                // Return success
                result(true)
            }

            rootViewController.present(pickerVC, animated: true)
        }
    }

    private func saveSelectedApps(_ selection: FamilyActivitySelection) {
        let defaults = sharedDefaults ?? UserDefaults.standard

        // Save application tokens
        if let appsData = try? JSONEncoder().encode(selection.applicationTokens) {
            defaults.set(appsData, forKey: "selectedApps")
            print("💾 Saved \(selection.applicationTokens.count) app tokens")
        }

        // Save category tokens
        if let categoriesData = try? JSONEncoder().encode(selection.categoryTokens) {
            defaults.set(categoriesData, forKey: "selectedCategories")
            print("💾 Saved \(selection.categoryTokens.count) category tokens")
        }

        // Save web domain tokens
        if let webDomainsData = try? JSONEncoder().encode(selection.webDomainTokens) {
            defaults.set(webDomainsData, forKey: "selectedWebDomains")
            print("💾 Saved \(selection.webDomainTokens.count) web domain tokens")
        }

        defaults.synchronize()
        print("✅ FaithLock: Apps saved to App Groups storage")
    }

    private func loadSelectedApps() -> FamilyActivitySelection {
        let defaults = sharedDefaults ?? UserDefaults.standard
        var selection = FamilyActivitySelection()

        // Load application tokens
        if let appsData = defaults.data(forKey: "selectedApps"),
           let apps = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: appsData) {
            selection.applicationTokens = apps
        }

        // Load category tokens
        if let categoriesData = defaults.data(forKey: "selectedCategories"),
           let categories = try? JSONDecoder().decode(Set<ActivityCategoryToken>.self, from: categoriesData) {
            selection.categoryTokens = categories
        }

        // Load web domain tokens
        if let webDomainsData = defaults.data(forKey: "selectedWebDomains"),
           let webDomains = try? JSONDecoder().decode(Set<WebDomainToken>.self, from: webDomainsData) {
            selection.webDomainTokens = webDomains
        }

        return selection
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
            print("🔒 Applied immediate blocking to \(selection.applicationTokens.count) apps")
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
            print("🔒 Applied immediate blocking to \(selection.categoryTokens.count) categories")
        }

        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
            print("🔒 Applied immediate blocking to \(selection.webDomainTokens.count) web domains")
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
        // Load previously selected apps
        let selection = loadSelectedApps()

        print("🔒 FaithLock: Applying restrictions...")
        print("   - Apps to block: \(selection.applicationTokens.count)")
        print("   - Categories to block: \(selection.categoryTokens.count)")
        print("   - Web domains to block: \(selection.webDomainTokens.count)")

        // Apply shields to selected apps and categories
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
            print("   ✅ Applied shields to \(selection.applicationTokens.count) apps")
        } else {
            print("   ⚠️ No apps selected - only system restrictions will apply")
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
                selection.categoryTokens
            )
            print("   ✅ Applied shields to \(selection.categoryTokens.count) categories")
        }

        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
            print("   ✅ Applied shields to \(selection.webDomainTokens.count) web domains")
        }

        // Block app installation/removal
        store.application.denyAppInstallation = true
        store.application.denyAppRemoval = true

        // Block explicit content
        store.webContent.blockedByFilter = .all()

        // Prevent settings changes
        store.dateAndTime.requireAutomaticDateAndTime = true

        // Game Center restrictions
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

            // Create schedule with start and end times
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

        print("ℹ️ FaithLock: \(schedules.count) schedule(s) configured")
        print("⚠️ Note: iOS may take a few minutes to activate the DeviceActivityMonitor extension the first time")
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
        result(true)
    }

    private func handleTemporaryUnlock(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let durationMinutes = args["durationMinutes"] as? Int else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Invalid duration for temporary unlock",
                details: nil
            ))
            return
        }

        // Remove shields temporarily
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        // Store unlock end time
        let defaults = sharedDefaults ?? UserDefaults.standard
        let unlockEndTime = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        defaults.set(unlockEndTime, forKey: "temporary_unlock_end")
        defaults.set(true, forKey: "is_temporarily_unlocked")

        print("🔓 FaithLock: Temporary unlock for \(durationMinutes) minutes")

        // Schedule re-lock after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(durationMinutes * 60)) { [weak self] in
            guard let self = self else { return }

            // Check if still should be unlocked
            let defaults = self.sharedDefaults ?? UserDefaults.standard
            if defaults.bool(forKey: "is_temporarily_unlocked") {
                // Re-apply blocking
                self.applyBlockingRestrictions()
                defaults.set(false, forKey: "is_temporarily_unlocked")
                defaults.removeObject(forKey: "temporary_unlock_end")
                print("🔒 FaithLock: Temporary unlock ended, re-locked")
            }
        }

        result(true)
    }
}
