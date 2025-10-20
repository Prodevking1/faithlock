import ManagedSettings
  import ManagedSettingsUI
  import UIKit

  // Override the functions below to customize the shields used in various situations.
  class ShieldConfigurationExtension: ShieldConfigurationDataSource {

      override func configuration(shielding application: Application) -> ShieldConfiguration {
          // Customize the shield for specific applications
          return ShieldConfiguration(
              backgroundBlurStyle: .systemMaterial,
              backgroundColor: UIColor.black,
              icon: UIImage(systemName: "hand.raised.fill"),
              title: ShieldConfiguration.Label(
                  text: "Stay Focused!",
                  color: .white
              ),
              subtitle: ShieldConfiguration.Label(
                  text: "This app is blocked during your scheduled focus time. Return to your spiritual journey.",
                  color: .lightGray
              ),
              primaryButtonLabel: ShieldConfiguration.Label(
                  text: "OK",
                  color: .white
              ),
              primaryButtonBackgroundColor: UIColor.systemBlue
          )
      }

      override func configuration(shielding application: Application, in category: ActivityCategory)
  -> ShieldConfiguration {
          // Customize the shield for applications shielded because of their category
          return ShieldConfiguration(
              backgroundBlurStyle: .systemMaterial,
              backgroundColor: UIColor.black,
              icon: UIImage(systemName: "hand.raised.fill"),
              title: ShieldConfiguration.Label(
                  text: "Category Blocked",
                  color: .white
              ),
              subtitle: ShieldConfiguration.Label(
                  text: "Apps in this category are blocked during focus time.",
                  color: .lightGray
              ),
              primaryButtonLabel: ShieldConfiguration.Label(
                  text: "OK",
                  color: .white
              ),
              primaryButtonBackgroundColor: UIColor.systemBlue
          )
      }

      override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
          // Customize the shield for specific web domains
          return ShieldConfiguration(
              backgroundBlurStyle: .systemMaterial,
              backgroundColor: UIColor.black,
              icon: UIImage(systemName: "hand.raised.fill"),
              title: ShieldConfiguration.Label(
                  text: "Website Blocked",
                  color: .white
              ),
              subtitle: ShieldConfiguration.Label(
                  text: "This website is blocked during your focus time.",
                  color: .lightGray
              ),
              primaryButtonLabel: ShieldConfiguration.Label(
                  text: "OK",
                  color: .white
              ),
              primaryButtonBackgroundColor: UIColor.systemBlue
          )
      }

      override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) ->
  ShieldConfiguration {
          // Customize the shield for web domains shielded because of their category
          return configuration(shielding: webDomain)
      }
  }
