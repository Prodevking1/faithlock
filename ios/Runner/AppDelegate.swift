import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register ScreenTimePlugin manually BEFORE GeneratedPluginRegistrant
    if #available(iOS 15.0, *) {
      let registrar = self.registrar(forPlugin: "ScreenTimePlugin")
      ScreenTimePlugin.register(with: registrar!)
    }

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
