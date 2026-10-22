import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'liquid_glass.dart';

/// ============================================================================
/// WIDGET: AppHeader (Header thương hiệu & AccountMenu chuẩn Figma)
/// ============================================================================
class AppHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onBackToToday;
  final VoidCallback? onLogout;

  const AppHeader({
    super.key,
    required this.selectedDate,
    required this.onBackToToday,
    this.onLogout,
  });

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final weekdayName = _weekdays[selectedDate.weekday - 1];
    final monthName = _months[selectedDate.month - 1];
    final dateSubtitle = '$weekdayName, $monthName ${selectedDate.day}';

    final user = AuthService().currentUser;
    final isGoogle = user != null && !user.isAnonymous;
    final displayName = isGoogle
        ? (user.displayName?.isNotEmpty == true ? user.displayName! : 'Lê Văn Đạt')
        : 'Chế độ Khách';
    final firstName = isGoogle ? displayName.split(' ').last : 'GUEST';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Pill Header dạng Liquid Glass (Logo + Tiêu đề + AccountMenu)
        LiquidGlass(
          borderRadius: 26.0,
          blur: 20.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              // Logo check box
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF4E75AD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Tiêu đề Todo Planner không bị cắt chữ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Todo Planner',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF293B55),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // AccountMenu Trigger
              _buildAccountTrigger(context, isGoogle, displayName, user?.photoURL),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Hero Typography Section với lời chào cá nhân hóa + Nút Back to today chuẩn src.zip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HELLO, ${firstName.toUpperCase()} • YOUR DAILY TASKS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: const TextSpan(
                        text: 'Todo List',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF293B55),
                          letterSpacing: -0.8,
                        ),
                        children: [
                          TextSpan(
                            text: '.',
                            style: TextStyle(
                              color: AppColors.dotBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Plan, organize, and complete your tasks.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Nút Back to today dạng nút tròn kính lỏng chuẩn src.zip App.tsx
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBackToToday,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.50),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3C5078).withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: Color(0xFF58759A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Nút Trigger mở Account Bottom Sheet trên Header
  Widget _buildAccountTrigger(
    BuildContext context,
    bool isGoogle,
    String name,
    String? photoUrl,
  ) {
    final statusColor = isGoogle ? const Color(0xFF66A889) : const Color(0xFF92A3BC);
    final statusText = isGoogle ? 'Cloud Synced' : 'Guest session';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAccountSheet(context, isGoogle),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar tròn 34x34px có dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4E2F5),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: ClipOval(
                      child: isGoogle && photoUrl != null
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarInitial(name, isGoogle),
                            )
                          : _buildAvatarInitial(name, isGoogle),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Name & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF354D6A),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isGoogle ? const Color(0xFF66A889) : const Color(0xFF7B8BA2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitial(String name, bool isGoogle) {
    final initial = isGoogle ? (name.isNotEmpty ? name[0].toUpperCase() : 'Đ') : 'K';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4E75AD),
        ),
      ),
    );
  }

  /// Bottom Sheet Tài khoản chuẩn Figma `AccountMenu.tsx`
  void _showAccountSheet(BuildContext context, bool isGoogle) {
    final user = AuthService().currentUser;
    final name = isGoogle
        ? (user?.displayName?.isNotEmpty == true ? user!.displayName! : 'Lê Văn Đạt')
        : 'Chế độ Khách';
    final email = isGoogle
        ? (user?.email?.isNotEmpty == true ? user!.email! : 'lvd27012004@gmail.com')
        : 'Không cần tài khoản để bắt đầu';
    final photoUrl = user?.photoURL;
    final statusColor = isGoogle ? const Color(0xFF66A889) : const Color(0xFF92A3BC);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close account sheet',
      barrierColor: const Color(0xFF293B57).withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 14, 28, 34),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF4F7FC).withValues(alpha: 0.94),
                          const Color(0xFFE8EDF9).withValues(alpha: 0.94),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                      border: Border.all(color: Colors.white, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF354F79).withValues(alpha: 0.16),
                          blurRadius: 60,
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar kéo
                        Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFA6B4C5).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Header: "TÀI KHOẢN CỦA BẠN" + nút đóng "×"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TÀI KHOẢN CỦA BẠN',
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: 2.0,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF8091A9),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: Color(0xFF8292A8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Avatar lớn (86x86px)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFD4E2F5),
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF536E98).withValues(alpha: 0.18),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: isGoogle && photoUrl != null
                                    ? Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            _buildLargeAvatarInitial(name, isGoogle),
                                      )
                                    : _buildLargeAvatarInitial(name, isGoogle),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tên người dùng
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF30445F),
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Email
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7B8BA2),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Badge Trạng thái đồng bộ
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isGoogle
                                ? const Color(0xFFDBECE4).withValues(alpha: 0.65)
                                : const Color(0xFFDCE5F3).withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.7),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isGoogle
                                    ? 'Đang đồng bộ Firestore Realtime'
                                    : 'Phiên làm việc trên thiết bị',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isGoogle
                                      ? const Color(0xFF5B8E77)
                                      : const Color(0xFF7B8BA2),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Container(
                          height: 1,
                          color: const Color(0xFFCBD6E3).withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 20),

                        // Nút Đăng xuất màu đỏ thanh lịch
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              _showConfirmLogoutDialog(context);
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4DFE1).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 19,
                                    color: Color(0xFFBF5561),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Đăng xuất khỏi thiết bị',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFBF5561),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14.0 * curved.value, sigmaY: 14.0 * curved.value),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          ),
        );
      },
    );
  }

  Widget _buildLargeAvatarInitial(String name, bool isGoogle) {
    final initial = isGoogle ? (name.isNotEmpty ? name[0].toUpperCase() : 'Đ') : 'K';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4E75AD),
        ),
      ),
    );
  }

  /// Hộp thoại xác nhận đăng xuất chuẩn Figma
  void _showConfirmLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF293B57).withValues(alpha: 0.35),
      builder: (ctx) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF354F79).withValues(alpha: 0.16),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon vuông đỏ
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4DFE1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.logout_rounded,
                          size: 22,
                          color: Color(0xFFBF5561),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Bạn có chắc muốn đăng xuất?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF30445F),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Bạn có thể đăng nhập lại bất cứ lúc nào.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B8BA2),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Hai nút hành động: Hủy & Đồng ý
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5FB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF597393),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              onLogout?.call();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBF5561),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFBF5561).withValues(alpha: 0.28),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Đồng ý',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
