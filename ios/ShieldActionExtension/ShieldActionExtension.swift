//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created for FaithLock
//

import ManagedSettings
import UIKit
import UserNotifications

// Override the functions below to customize the shield actions used in various situations.
@available(iOS 16.0, *)
class ShieldActionExtension: ShieldActionDelegate {

    override init() {
        super.init()
        NSLog("========================================")
        NSLog("🚀 ShieldActionExtension INITIALIZED!")
        NSLog("========================================")
    }

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        NSLog("🎬 ShieldActionExtension: handle(action:for application:) CALLED")

        switch action {
        case .primaryButtonPressed:
            NSLog("✅ Primary button pressed - Sending notification to open FaithLock app")

            // Store a flag indicating user wants to pray
            let defaults = UserDefaults(suiteName: "group.com.appbiz.faithlock")
            defaults?.set(true, forKey: "should_navigate_to_prayer")
            defaults?.set(Date(), forKey: "prayer_request_time")
            defaults?.synchronize()

            NSLog("📝 Stored prayer flag in App Group")

            // ⚠️ CRITICAL: ShieldActionExtension CANNOT directly open the parent app
            // Workaround: Send a local notification that user can tap to open the app
            sendPrayerNotification()

            // Close the shield - user will tap notification to open app
            completionHandler(.close)

            NSLog("🔔 Notification sent - user can tap to open FaithLock app")

        case .secondaryButtonPressed:
            NSLog("ℹ️ Secondary button pressed - User dismissed")
            completionHandler(.close)

        @unknown default:
            NSLog("⚠️ Unknown action")
            completionHandler(.close)
        }
    }

    /// Send a local notification to prompt user to open the app
    private func sendPrayerNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🙏 Prayer Time"
        content.body = "Tap to open FaithLock and complete your prayer session"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "PRAYER_REMINDER"

        // Add custom data for deep linking
        content.userInfo = ["navigate_to": "prayer_learning"]

        // Deliver immediately
        let request = UNNotificationRequest(
            identifier: "prayer_session_\(UUID().uuidString)",
            content: content,
            trigger: nil // nil = deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("❌ Failed to send notification: \(error)")
            } else {
                NSLog("✅ Prayer notification sent successfully")
            }
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        NSLog("🌐 ShieldActionExtension: handle(action:for webDomain:) CALLED")
        completionHandler(.close)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        NSLog("📁 ShieldActionExtension: handle(action:for category:) CALLED")
        completionHandler(.close)
    }
}
