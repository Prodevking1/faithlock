//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Abdoul Rachid Tapsoba on 22/10/2025.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
@available(iOS 15.0, *)
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    // 🆕 INIT - Log when extension is loaded by iOS
    override init() {
        super.init()
        NSLog("========================================")
        NSLog("🚀 ShieldConfigurationExtension INITIALIZED!")
        NSLog("========================================")
    }

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // FaithLock Shield - Motivational message to resist distraction
        NSLog("🛡️ ShieldConfigurationExtension: Showing shield for app")

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0),
            icon: UIImage(systemName: "hands.sparkles.fill"),
            title: ShieldConfiguration.Label(
                text: "Prayer Time",
                color: .black
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Take a moment to pray.\n\nYou'll unlock this app after completing your prayer session.",
                color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Start Prayer",
                color: .white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.2, green: 0.6, blue: 0.4, alpha: 1.0),
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Later",
                color: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            )
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        NSLog("🛡️ ShieldConfigurationExtension: configuration(shielding webDomain) CALLED")
        return ShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        NSLog("🛡️ ShieldConfigurationExtension: configuration(shielding webDomain, in category) CALLED")
        return ShieldConfiguration()
    }
}
