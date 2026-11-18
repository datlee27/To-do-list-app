import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    // Đảm bảo MethodChannel được kết nối ngay khi WindowScene sẵn sàng
    if let windowScene = scene as? UIWindowScene {
      let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        ?? windowScene.windows.first?.rootViewController
        ?? self.window?.rootViewController

      if let controller = rootVC as? FlutterViewController {
        AppDelegate.setupWidgetMethodChannel(binaryMessenger: controller.binaryMessenger)
      }
    }
  }
}
