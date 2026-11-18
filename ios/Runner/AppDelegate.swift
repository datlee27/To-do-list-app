import Flutter
import UIKit

/// Plugin nội bộ đồng bộ dữ liệu Todo List giữa Flutter, ổ cứng thiết bị và Lock Screen Widget
final class TodoListWidgetPlugin: NSObject, FlutterPlugin {
  private static let channelName = "com.example.assignment1TodolistApp/widget"
  private static var registeredMessengers = Set<ObjectIdentifier>()
  private static var retainedChannels: [FlutterMethodChannel] = []
  private static let sharedInstance = TodoListWidgetPlugin()

  public static func register(with registrar: FlutterPluginRegistrar) {
    attach(to: registrar.messenger())
  }

  public static func attach(to binaryMessenger: FlutterBinaryMessenger) {
    let id = ObjectIdentifier(binaryMessenger as AnyObject)
    guard registeredMessengers.insert(id).inserted else { return }

    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      sharedInstance.handle(call, result: result)
    }
    retainedChannels.append(channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getTasks":
      let json = TaskStore.loadRawJsonString()
      // Đồng bộ lại bản sao dự phòng cục bộ của app chính (phòng khi Widget/Shortcut vừa thay đổi dữ liệu)
      if let data = json.data(using: .utf8) {
        if let localURL = TaskStore.localDocumentsJsonFileURL {
          let dirURL = localURL.deletingLastPathComponent()
          if !FileManager.default.fileExists(atPath: dirURL.path) {
            try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
          }
          try? data.write(to: localURL, options: .atomic)
        }
        UserDefaults.standard.set(json, forKey: TaskStore.tasksKey)
        UserDefaults.standard.synchronize()
      }
      result(json)

    case "saveTasks":
      if let args = call.arguments as? [String: Any],
         let tasksJson = args["tasksJson"] as? String {
        TaskStore.saveRawJsonString(tasksJson)
        result(true)
      } else {
        result(FlutterError(code: "INVALID_ARGS", message: "tasksJson is required", details: nil))
      }

    case "reloadWidgets":
      TaskStore.reloadWidgets()
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = self.registrar(forPlugin: "TodoListWidgetPlugin") {
      TodoListWidgetPlugin.register(with: registrar)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TodoListWidgetPlugin") {
      TodoListWidgetPlugin.register(with: registrar)
    }
    TodoListWidgetPlugin.attach(to: engineBridge.applicationRegistrar.messenger())
  }
}
