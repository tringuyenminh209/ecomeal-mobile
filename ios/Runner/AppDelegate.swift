import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Same source as Dart and Android: GOOGLE_MAPS_IOS_API_KEY from --dart-define-from-file=env.json.
    // Dart only shows GoogleMap when this define is non-empty, so the SDK is always initialized first.
    if let key = Self.dartDefine("GOOGLE_MAPS_IOS_API_KEY"), !key.isEmpty {
      GMSServices.provideAPIKey(key)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Flutter writes the defines into Generated.xcconfig as DART_DEFINES: comma-separated,
  // each item base64("NAME=value"). Info.plist exposes that build setting as "DartDefines".
  private static func dartDefine(_ name: String) -> String? {
    guard let raw = Bundle.main.object(forInfoDictionaryKey: "DartDefines") as? String else {
      return nil
    }
    let prefix = name + "="
    for item in raw.split(separator: ",") {
      guard let data = Data(base64Encoded: String(item)),
            let pair = String(data: data, encoding: .utf8),
            pair.hasPrefix(prefix) else { continue }
      return String(pair.dropFirst(prefix.count))
    }
    return nil
  }
}
