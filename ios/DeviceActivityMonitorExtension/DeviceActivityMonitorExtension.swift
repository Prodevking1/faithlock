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

/// Extension that monitors device activity and sends notifications
/// Shields are managed by the main app via ScheduleController
class DeviceActivityMonitorExtension: DeviceActivityMonitor {

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

        logToAppGroup(event: "intervalDidStart", activity: activity.rawValue)

        let scheduleName = activity.rawValue.replacingOccurrences(of: "_", with: " ")
        sendDebugNotification(title: "🔒 \(scheduleName)", body: "Lock period started")
    }

    /// Called when a monitoring interval ends (e.g., 10:00 AM for morning lock)
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        NSLog("🔓 MONITOR: Schedule '\(activity.rawValue)' ended")

        logToAppGroup(event: "intervalDidEnd", activity: activity.rawValue)

        if let defaults = UserDefaults(suiteName: appGroup) {
            defaults.set(activity.rawValue, forKey: "schedule_ended")
            defaults.set(Date(), forKey: "schedule_ended_time")
            defaults.synchronize()
            NSLog("✅ MONITOR: Notified app that schedule '\(activity.rawValue)' ended")
        }

        let scheduleName = activity.rawValue.replacingOccurrences(of: "_", with: " ")
        sendDebugNotification(title: "🔓 \(scheduleName)", body: "Lock period ended")
    }

    /// Called when an event threshold is reached during monitoring
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        NSLog("⚠️ MONITOR: Event threshold - \(event.rawValue)")
        logToAppGroup(event: "eventDidReachThreshold: \(event.rawValue)", activity: activity.rawValue)
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

    private func sendDebugNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
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
