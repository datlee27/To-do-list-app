import Flutter
import UIKit
#if canImport(WidgetKit)
import WidgetKit
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private static let channelName = "com.example.assignment1TodolistApp/widget"
  private static var isChannelConfigured = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // 1. Thử đăng ký qua plugin registrar
    if let registrar = self.registrar(forPlugin: "TodoListWidgetPlugin") {
      AppDelegate.setupWidgetMethodChannel(binaryMessenger: registrar.messenger())
    }

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // 2. Thử đăng ký qua window rootViewController nếu đã có
    if let controller = window?.rootViewController as? FlutterViewController {
      AppDelegate.setupWidgetMethodChannel(binaryMessenger: controller.binaryMessenger)
    }

    return result
  }

  public static func setupWidgetMethodChannel(binaryMessenger: FlutterBinaryMessenger) {
    if isChannelConfigured { return }
    isChannelConfigured = true

    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getTasks":
        // Đọc từ TaskStore (bao gồm App Group, Standard UserDefaults và file JSON)
        let jsonString = TaskStore.loadRawJsonString()
        result(jsonString)

      case "saveTasks":
        if let args = call.arguments as? [String: Any],
           let tasksJson = args["tasksJson"] as? String {
          // Lưu bền vững vào cả 4 lớp lưu trữ
          TaskStore.saveRawJsonString(tasksJson)
          result(true)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "tasksJson is required", details: nil))
        }

      case "reloadWidgets":
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
        result(true)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
