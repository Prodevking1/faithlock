import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 16.0, *) {
      let registrar = self.registrar(forPlugin: "ScreenTimePlugin")
      ScreenTimePlugin.register(with: registrar!)
    }

    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    NSLog("🔔 Notification tapped in AppDelegate")

    let userInfo = response.notification.request.content.userInfo
    NSLog("Notification userInfo: \(userInfo)")

    if let navigateTo = userInfo["navigate_to"] as? String,
       navigateTo == "prayer_learning" {
      NSLog("✅ Prayer notification detected - flag already set by ShieldActionExtension")
    }

    completionHandler()
  }
}
