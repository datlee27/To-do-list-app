import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'todo_list_screen.dart';

/// ============================================================================
/// SCREEN: LoginScreen (Thiết kế tối giản chuẩn Figma Liquid Glass)
/// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoadingGoogle = false;
  bool _isLoadingGuest = false;

  bool get _isLoading => _isLoadingGoogle || _isLoadingGuest;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoadingGoogle = true);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TodoListScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Đăng nhập thất bại: ${e.toString()}';
        if (e.toString().contains('popup-blocked')) {
          msg = 'Cửa sổ đăng nhập bị chặn! Vui lòng bấm biểu tượng ở góc thanh địa chỉ URL để "Luôn cho phép cửa sổ bật lên" rồi bấm lại.';
        } else if (e.toString().contains('popup-closed-by-user')) {
          msg = 'Đã hủy thao tác đăng nhập Google.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: e.toString().contains('popup-closed')
                ? const Color(0xFF4E75AD)
                : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGoogle = false);
      }
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => _isLoadingGuest = true);
    try {
      await _authService.signInAnonymously();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TodoListScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        // Dự phòng: Nếu offline hoặc chưa khởi tạo Firebase, vẫn cho phép vào màn hình chính dưới dạng Khách
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TodoListScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGuest = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF0F8),
      body: Stack(
        children: [
          // 1. Ambient Background Gradients chuẩn Figma
          Positioned(
            left: -80,
            top: size.height * 0.15,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC0D4ED).withValues(alpha: 0.6),
                    const Color(0xFFC0D4ED).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: size.height * 0.38,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD3C8ED).withValues(alpha: 0.6),
                    const Color(0xFFD3C8ED).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: size.width * 0.15,
            bottom: -60,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDCE8F6).withValues(alpha: 0.7),
                    const Color(0xFFDCE8F6).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 2. Nội dung chính căn giữa
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 402),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // Glass Badge Logo (92 x 92)
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.93),
                            width: 1.2,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.65),
                              Colors.white.withValues(alpha: 0.15),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5678A9).withValues(alpha: 0.22),
                              blurRadius: 35,
                              offset: const Offset(0, 14),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            child: const Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 48,
                                color: Color(0xFF4E75AD),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Tên ứng dụng
                      const Text(
                        'Todo Planner',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF293B55),
                          letterSpacing: -1.2,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Phụ đề ngắn 1 dòng
                      const Text(
                        'Quản lý công việc thông minh & tiện lợi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF758399),
                          letterSpacing: -0.25,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // 3. Khung hai nút hành động
                      // Nút 1: Tiếp tục với Google
                      Container(
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4E75AD).withValues(alpha: 0.20),
                              blurRadius: 20,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(100),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _isLoading ? null : _handleGoogleSignIn,
                            borderRadius: BorderRadius.circular(100),
                            hoverColor: Colors.white,
                            splashColor: const Color(0xFF4E75AD).withValues(alpha: 0.12),
                            highlightColor: Colors.transparent,
                            child: Container(
                              height: 58,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: _isLoadingGoogle
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Color(0xFF4E75AD),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomPaint(
                                            size: const Size(20, 20),
                                            painter: GoogleLogoPainter(),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Tiếp tục với Google',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF293B55),
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Nút 2: Dùng thử chế độ Khách (Ghost Glass Button)
                      Container(
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4E75AD).withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(100),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _isLoading ? null : _handleGuestSignIn,
                                borderRadius: BorderRadius.circular(100),
                                hoverColor: Colors.white.withValues(alpha: 0.4),
                                splashColor: const Color(0xFF4E75AD).withValues(alpha: 0.1),
                                highlightColor: Colors.transparent,
                                child: Container(
                                  height: 58,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: _isLoadingGuest
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.2,
                                              color: Color(0xFF536B8B),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.person_outline_rounded,
                                                size: 20,
                                                color: Color(0xFF536B8B),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Dùng thử chế độ Khách',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF536B8B),
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // 4. Chân trang (Footer)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: const Color(0xFF7F8CA1).withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Bảo mật và đồng bộ đám mây',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7F8CA1),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter vẽ Logo Google 4 màu chuẩn theo vector SVG từ Figma
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Blue path
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(43.6, 24.5)
      ..cubicTo(43.6, 23.1, 43.5, 21.7, 43.2, 20.4)
      ..lineTo(24, 20.4)
      ..lineTo(24, 28.3)
      ..lineTo(35, 28.3)
      ..cubicTo(34.5, 30.6, 33.1, 32.7, 30.9, 34.5)
      ..lineTo(30.9, 39.6)
      ..lineTo(37.5, 39.6)
      ..cubicTo(41.4, 36.0, 43.6, 30.8, 43.6, 24.5)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // 2. Green path
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(24, 44)
      ..cubicTo(29.5, 44, 34.1, 42.2, 37.5, 39.1)
      ..lineTo(30.9, 34)
      ..cubicTo(29.1, 35.2, 26.8, 35.9, 24, 35.9)
      ..cubicTo(18.7, 35.9, 14.2, 32.3, 12.6, 27.5)
      ..lineTo(5.8, 27.5)
      ..lineTo(5.8, 32.8)
      ..cubicTo(9.2, 39.6, 16.1, 44, 24, 44)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // 3. Yellow path
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(12.6, 27.5)
      ..cubicTo(12.2, 26.2, 12, 24.8, 12, 23.4)
      ..cubicTo(12, 22.0, 12.2, 20.6, 12.6, 19.3)
      ..lineTo(12.6, 14.0)
      ..lineTo(5.8, 14.0)
      ..cubicTo(4.4, 16.8, 3.6, 20.0, 3.6, 23.4)
      ..cubicTo(3.6, 26.8, 4.4, 30.0, 5.8, 32.8)
      ..lineTo(12.6, 27.5)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // 4. Red path
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(24, 11.3)
      ..cubicTo(27.0, 11.3, 29.6, 12.3, 31.7, 14.3)
      ..lineTo(37.5, 8.6)
      ..cubicTo(34.0, 5.3, 29.4, 3.3, 24, 3.3)
      ..cubicTo(16.1, 3.3, 9.2, 7.7, 5.8, 14.5)
      ..lineTo(12.6, 19.8)
      ..cubicTo(14.2, 15.0, 18.7, 11.3, 24, 11.3)
      ..close();
    canvas.drawPath(redPath, redPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
