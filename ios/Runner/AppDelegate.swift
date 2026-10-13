import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let storageSecurityChannel = FlutterMethodChannel(
      name: "family_tracker/storage_security",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    storageSecurityChannel.setMethodCallHandler { call, result in
      guard call.method == "excludePrivateDataFromBackup" else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        let protectedDirectories = try [
          FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
          ),
          FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
          ),
        ]
        for directory in protectedDirectories {
          var resourceValues = URLResourceValues()
          resourceValues.isExcludedFromBackup = true
          var excludedDirectory = directory
          try excludedDirectory.setResourceValues(resourceValues)
        }
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "backup_exclusion_failed",
            message: "Unable to exclude private app data from device backups.",
            details: nil
          )
        )
      }
    }
  }
}
