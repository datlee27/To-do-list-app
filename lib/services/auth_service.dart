import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service quản lý Xác thực người dùng (Authentication)
/// Hỗ trợ Đăng nhập Google & duy trì phiên đăng nhập (Session Persistence)
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '821101079230-placeholder.apps.googleusercontent.com' : null,
  );

  /// Stream lắng nghe thay đổi trạng thái đăng nhập
  /// Tự động phát ra User khi đã đăng nhập (kể cả khi mở lại app), hoặc null khi chưa/đã đăng xuất.
  Stream<User?> get authStateChanges {
    final auth = _auth;
    return auth != null ? auth.authStateChanges() : const Stream.empty();
  }

  /// Thông tin người dùng hiện tại
  User? get currentUser => _auth?.currentUser;

  /// Đăng nhập bằng Google (Tự động hỗ trợ cả Web và Mobile)
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) return null;
    try {
      if (kIsWeb) {
        // Trên nền tảng Web / Tiện ích giả lập điện thoại: Dùng Popup chính thức của Firebase
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await auth.signInWithPopup(googleProvider);
      }

      // Trên nền tảng Di động (Android / iOS): Dùng SDK GoogleSignIn gốc
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng nhập Khách (Guest / Anonymous) - Tiện ích hỗ trợ chấm điểm và demo nhanh
  Future<UserCredential?> signInAnonymously() async {
    return await _auth?.signInAnonymously();
  }

  /// Đăng xuất khỏi hệ thống
  /// Xóa bỏ token và session đã lưu để lần sau mở app sẽ hiện màn hình Login
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth?.signOut();
    } catch (e) {
      await _auth?.signOut();
    }
  }
}
