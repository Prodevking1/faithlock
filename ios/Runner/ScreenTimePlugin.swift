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

@available(iOS 15.0, *)
class ScreenTimePlugin: NSObject, FlutterPlugin {

    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()

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
        case "startBlocking":
            handleStartBlocking(call: call, result: result)
        case "stopBlocking":
            handleStopBlocking(result: result)
        case "isMonitoring":
            handleIsMonitoring(result: result)
        case "getAuthorizationStatus":
            handleGetAuthorizationStatus(result: result)
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

            // Create and present picker
            let pickerVC = FamilyActivityPickerViewController()
            pickerVC.modalPresentationStyle = .pageSheet

            if let sheet = pickerVC.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }

            pickerVC.setOnSelection { [weak self] selection in
                guard let self = self else { return }

                // Save the selection
                self.saveSelectedApps(selection)

                // Log selection
                print("📱 FaithLock: Saved \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories, \(selection.webDomainTokens.count) web domains")

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
        }

        // Save category tokens
        if let categoriesData = try? JSONEncoder().encode(selection.categoryTokens) {
            defaults.set(categoriesData, forKey: "selectedCategories")
        }

        // Save web domain tokens
        if let webDomainsData = try? JSONEncoder().encode(selection.webDomainTokens) {
            defaults.set(webDomainsData, forKey: "selectedWebDomains")
        }
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
}
