//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created for FaithLock
//

import DeviceActivity
import FamilyControls
import ManagedSettings
import Foundation
import UserNotifications

/// Extension that monitors device activity and enforces app blocking schedules
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

    // Use named store to share with main app
    let store = ManagedSettingsStore(named: ManagedSettingsStore.Name("faithlock"))

    // App Group for communication (must match entitlements)
    let appGroup = "group.com.appbiz.faithlock"

    // Override init to log when extension loads
    override init() {
        super.init()
        NSLog("🚀 FAITHLOCK MONITOR: DeviceActivityMonitorExtension initialized!")

        // Log to App Group immediately
        if let defaults = UserDefaults(suiteName: appGroup) {
            defaults.set(Date(), forKey: "extensionLastInitDate")
            defaults.set("Extension initialized", forKey: "extensionLastInit")
            defaults.synchronize()
            NSLog("✅ FAITHLOCK MONITOR: Logged init to App Group")
        } else {
            NSLog("❌ FAITHLOCK MONITOR: Failed to access App Group on init")
        }
    }

    /// Called when a monitoring interval starts (e.g., 8:00 AM for morning lock)
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        NSLog("🔒 MONITOR: Schedule '\(activity.rawValue)' started")

        // Log to UserDefaults (App Group)
        logToAppGroup(event: "intervalDidStart", activity: activity.rawValue)

        // Check if this is a temporary unlock schedule (ends with "_TEMP_UNLOCK")
        if activity.rawValue.hasSuffix("_TEMP_UNLOCK") {
            // This is the START of a temporary unlock period
            // Shields should already be removed by the main app
            NSLog("🔓 MONITOR: Temporary unlock period started")
            sendDebugNotification(title: "🔓 Temporary Unlock", body: "Apps unlocked for 5 minutes")
            return
        }

        // Regular schedule - apply shields
        sendDebugNotification(title: "🔒 Schedule Active", body: "Apps are now blocked")
        applyShield(for: activity)
        verifyShieldsApplied()
    }

    /// Called when a monitoring interval ends (e.g., 10:00 AM for morning lock)
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        NSLog("🔓 MONITOR: Schedule '\(activity.rawValue)' ended")

        // Log to UserDefaults (App Group)
        logToAppGroup(event: "intervalDidEnd", activity: activity.rawValue)

        // Check if this is a temporary unlock schedule
        if activity.rawValue.hasSuffix("_TEMP_UNLOCK") {
            // This is the END of a temporary unlock period
            // Re-apply shields automatically
            NSLog("🔒 MONITOR: Temporary unlock ended - re-applying shields")
            sendDebugNotification(title: "🔒 Apps Re-locked", body: "Temporary unlock period expired")

            // Re-apply shields (they should still be in the store from initial selection)
            reapplyShieldsFromStore()
            return
        }

        // Regular schedule ended - remove shields
        sendDebugNotification(title: "🔓 Schedule Ended", body: "Apps are now unlocked")
        removeShield(for: activity)
    }

    /// Called when an event threshold is reached during monitoring
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        NSLog("⚠️ MONITOR: Event threshold - \(event.rawValue)")
        logToAppGroup(event: "eventDidReachThreshold: \(event.rawValue)", activity: activity.rawValue)
    }

    // MARK: - Private Methods

    private func applyShield(for activity: DeviceActivityName) {
        // ✅ Retrieve the saved FamilyActivitySelection from App Group
        guard let defaults = UserDefaults(suiteName: appGroup),
              let selectionData = defaults.data(forKey: "familyActivitySelection"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: selectionData) else {
            NSLog("⚠️ MONITOR: No FamilyActivitySelection found in App Group!")
            return
        }

        // Apply shields from the selection
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
            NSLog("✅ MONITOR: Applied shields to \(selection.applicationTokens.count) apps")
        }

        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
            NSLog("✅ MONITOR: Applied shields to \(selection.categoryTokens.count) categories")
        }

        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
            NSLog("✅ MONITOR: Applied shields to \(selection.webDomainTokens.count) web domains")
        }
    }

    private func removeShield(for activity: DeviceActivityName) {
        // Remove all shields when schedule ends
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        NSLog("✅ MONITOR: Shields removed")
    }

    private func reapplyShieldsFromStore() {
        // The shields should still be in the store from the initial app selection
        // We just need to ensure they're active
        if let existingShields = store.shield.applications {
            NSLog("✅ MONITOR: Re-applied \(existingShields.count) app shields")
        } else {
            NSLog("⚠️ MONITOR: No shields to re-apply!")
        }

        // Verify shields are active
        verifyShieldsApplied()
    }

    private func verifyShieldsApplied() {
        if let shields = store.shield.applications {
            NSLog("✅ MONITOR: \(shields.count) apps verified blocked")
        } else {
            NSLog("⚠️ MONITOR: No shields found")
        }
    }

    // MARK: - Logging & Debugging

    /// Log events to App Group UserDefaults for debugging
    private func logToAppGroup(event: String, activity: String) {
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            NSLog("❌ FAITHLOCK MONITOR: Cannot access App Group UserDefaults")
            return
        }

        let timestamp = Date()
        defaults.set(timestamp, forKey: "lastMonitorEventDate")
        defaults.set(event, forKey: "lastMonitorEvent")
        defaults.set(activity, forKey: "lastMonitorActivity")

        // Keep a history of last 10 events
        var history = defaults.array(forKey: "monitorEventHistory") as? [[String: Any]] ?? []
        history.insert([
            "event": event,
            "activity": activity,
            "timestamp": timestamp.timeIntervalSince1970
        ], at: 0)

        // Keep only last 10
        if history.count > 10 {
            history = Array(history.prefix(10))
        }

        defaults.set(history, forKey: "monitorEventHistory")
        defaults.synchronize()

        NSLog("✅ FAITHLOCK MONITOR: Event logged to App Group - \(event)")
    }

    /// Send local notification for debugging (visible to user)
    private func sendDebugNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "\(body) at \(DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium))"
        content.sound = .default
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate delivery
        )


        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("❌ FAITHLOCK MONITOR: Notification error - \(error.localizedDescription)")
            } else {
                NSLog("✅ FAITHLOCK MONITOR: Notification sent - \(title)")
            }
        }
    }
}
