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

/// Extension that monitors device activity and enforces app blocking schedules
class FaithLockDeviceActivityMonitor: DeviceActivityMonitor {

    let store = ManagedSettingsStore()

    /// Called when a monitoring interval starts (e.g., 8:00 AM for morning lock)
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        print("🔒 FaithLock: Schedule started - \(activity.rawValue)")

        // Apply blocking to selected apps
        applyShield(for: activity)
    }

    /// Called when a monitoring interval ends (e.g., 10:00 AM for morning lock)
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        print("🔓 FaithLock: Schedule ended - \(activity.rawValue)")

        // Remove blocking
        removeShield(for: activity)
    }

    /// Called when an event threshold is reached during monitoring
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)

        print("⚠️ FaithLock: Event threshold reached - \(event.rawValue)")
    }

    // MARK: - Private Methods

    private func applyShield(for activity: DeviceActivityName) {
        // Get the stored app selection from App Groups
        guard let selection = loadStoredSelection() else {
            print("❌ No app selection found in storage")
            return
        }

        // Block applications
        if !selection.applicationTokens.isEmpty {
            store.shield.applications = selection.applicationTokens
            print("✅ Blocked \(selection.applicationTokens.count) applications")
        }

        // Block categories if any
        if !selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
            print("✅ Blocked \(selection.categoryTokens.count) categories")
        }

        // Block websites if any
        if !selection.webDomainTokens.isEmpty {
            store.shield.webDomains = selection.webDomainTokens
            print("✅ Blocked \(selection.webDomainTokens.count) web domains")
        }
    }

    private func removeShield(for activity: DeviceActivityName) {
        // Remove all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        print("✅ All shields removed")
    }

    private func loadStoredSelection() -> FamilyActivitySelection? {
        // Access shared App Groups container
        guard let userDefaults = UserDefaults(suiteName: "group.com.appbiz.faithlock") else {
            print("❌ Failed to access App Groups")
            return nil
        }

        var selection = FamilyActivitySelection()

        // Load application tokens
        if let appsData = userDefaults.data(forKey: "selectedApps"),
           let apps = try? JSONDecoder().decode(Set<ApplicationToken>.self, from: appsData) {
            selection.applicationTokens = apps
            print("📱 Loaded \(apps.count) app tokens")
        }

        // Load category tokens
        if let categoriesData = userDefaults.data(forKey: "selectedCategories"),
           let categories = try? JSONDecoder().decode(Set<ActivityCategoryToken>.self, from: categoriesData) {
            selection.categoryTokens = categories
            print("📂 Loaded \(categories.count) category tokens")
        }

        // Load web domain tokens
        if let webDomainsData = userDefaults.data(forKey: "selectedWebDomains"),
           let webDomains = try? JSONDecoder().decode(Set<WebDomainToken>.self, from: webDomainsData) {
            selection.webDomainTokens = webDomains
            print("🌐 Loaded \(webDomains.count) web domain tokens")
        }

        let hasSelection = !selection.applicationTokens.isEmpty ||
                          !selection.categoryTokens.isEmpty ||
                          !selection.webDomainTokens.isEmpty

        if hasSelection {
            print("✅ Loaded selection: \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories, \(selection.webDomainTokens.count) domains")
            return selection
        } else {
            print("❌ No selection data found")
            return nil
        }
    }
}
