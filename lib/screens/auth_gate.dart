import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'todo_list_screen.dart';

/// ============================================================================
/// SCREEN: AuthGate (Bộ điều phối Phiên đăng nhập & Auto-Login)
/// ============================================================================
/// - Lắng nghe authStateChanges() của Firebase Authentication.
/// - Nếu đã đăng nhập trước đó: Tự động vào thẳng TodoListScreen (như Zalo / Facebook).
/// - Nếu chưa đăng nhập hoặc đã bấm Đăng xuất: Hiển thị LoginScreen.
/// ============================================================================
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Đang kiểm tra token / session lưu trong thiết bị
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            ),
          );
        }

        // Đã có phiên đăng nhập hợp lệ
        if (snapshot.hasData && snapshot.data != null) {
          return const TodoListScreen();
        }

        // Chưa đăng nhập hoặc đã đăng xuất
        return const LoginScreen();
      },
    );
  }
}
