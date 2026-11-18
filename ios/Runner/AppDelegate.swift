import Flutter
import UIKit
#if canImport(WidgetKit)
import WidgetKit
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.example.assignment1TodolistApp/widget"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Gọi super.application trước để khởi tạo UIWindow và rootViewController
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      setupWidgetMethodChannel(binaryMessenger: controller.binaryMessenger)
    }

    return result
  }

  private func setupWidgetMethodChannel(binaryMessenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getTasks":
        // Đọc từ App Group hoặc UserDefaults
        if let jsonString = TaskStore.sharedDefaults.string(forKey: TaskStore.tasksKey) ?? UserDefaults.standard.string(forKey: TaskStore.tasksKey) {
          result(jsonString)
        } else {
          let tasks = TaskStore.loadTasks()
          let encoder = JSONEncoder()
          if let data = try? encoder.encode(tasks),
             let str = String(data: data, encoding: .utf8) {
            result(str)
          } else {
            result("[]")
          }
        }

      case "saveTasks":
        if let args = call.arguments as? [String: Any],
           let tasksJson = args["tasksJson"] as? String {
          // Lưu đồng thời vào cả App Group và Standard Defaults
          TaskStore.sharedDefaults.set(tasksJson, forKey: TaskStore.tasksKey)
          TaskStore.sharedDefaults.synchronize()
          UserDefaults.standard.set(tasksJson, forKey: TaskStore.tasksKey)
          UserDefaults.standard.synchronize()

          if let fileURL = TaskStore.sharedJsonFileURL,
             let data = tasksJson.data(using: .utf8) {
            try? data.write(to: fileURL, options: .atomic)
          }

          #if canImport(WidgetKit)
          if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
          }
          #endif
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
