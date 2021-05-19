import UIKit
import Flutter
import GoogleMaps
import AppTrackingTransparency

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { (status) in
            print(status)
        }    
    }
    GMSServices.provideAPIKey("AIzaSyBXoHy5VAJODIpy3etPWpXA4cL1f9gNIVY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
