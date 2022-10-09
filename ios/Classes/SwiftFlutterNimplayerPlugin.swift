import Flutter
import UIKit

public class SwiftFlutterNimplayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_nimplayer", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterNimplayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? NSDictionary

    switch call.method {
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
      break
      default:
        result(FlutterMethodNotImplemented)
      break
    }
  }
}
