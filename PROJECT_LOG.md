# 📋 PROJECT LOG & ARCHITECTURE SPECIFICATION
**Course:** PRM393 - Mobile Programming  
**Assignment:** Assignment 1 - Flutter Todo List / Task Manager  
**Platform:** Flutter (Dart)  
**Theme/Design:** Modern iOS-Style "Liquid Glass" (Optical Refraction & Frosted Glass)  
**Date:** 2026-10-06  

---

## 1. CẤU TRÚC DỰ ÁN (PROJECT STRUCTURE)

Toàn bộ ứng dụng đã được nâng cấp lên hiệu ứng **Liquid Glass** (tương đương `npx uilayouts@latest add liquid-glass`) với cơ chế làm mờ khúc xạ thời gian thực (`BackdropFilter`):

```text
Assignment1_todolistApp/
│
├── lib/                                      # Thư mục mã nguồn chính của ứng dụng
│   ├── main.dart                             # Entry point: Khởi chạy app, cấu hình ThemeData & MaterialApp
│   │
│   ├── theme/                                # Hệ thống màu sắc & Styling
│   │   └── app_colors.dart                   # Bảng màu chuẩn Hex, Ambient Blurs & Glassmorphism helpers
│   │
│   ├── models/                               # Data Models / Entities
│   │   └── task_item.dart                    # Class TaskItem (title, startDateTime, endDateTime, duration) & Enum TaskFilter
│   │
│   ├── screens/                              # Màn hình chính (Pages / Screens)
│   │   └── todo_list_screen.dart             # Màn hình chính Todo Planner: Quản lý local state, ngày chọn, lọc & sắp xếp
│   │
│   └── widgets/                              # Các UI Components tái sử dụng
│       ├── liquid_glass.dart                 # ⭐ Component cốt lõi: Khối kính lỏng quang học (BackdropFilter + Specular Border)
│       ├── app_header.dart                   # Header: Pill "Todo Planner", ngày hiện tại & nút "Today" + Hero Typography
│       ├── week_calendar_strip.dart          # Dải lịch tuần 7 ngày tương tác (Mon ➔ Sun, đếm task từng ngày, chuyển tuần)
│       ├── task_filter_bar.dart              # Thanh tiêu đề ngày + 3 Tab bộ lọc (All, Active, Done) + Nút Sort đảo chiều
│       ├── task_timeline_tile.dart           # Thẻ task Timeline: Trục giờ bên trái, Checkbox tròn, gạch ngang, thời lượng, Sửa/Xóa
│       ├── bottom_dock_bar.dart              # Thanh Dock nổi đáy màn hình: 3 ô thống kê (Total, Done, Left) + Nút "+ Add task"
│       └── task_editor_sheet.dart            # Modal BottomSheet: Form nhập tên, chọn ngày/giờ bắt đầu & kết thúc + Validation
│
├── test/
│   └── widget_test.dart                      # Automated Widget Tests (View, Add, Complete, Delete, Filters) -> 100% PASS
│
├── pubspec.yaml                              # Khai báo cấu hình dự án Flutter
├── Assigment_TodoListtask.md                 # Đặc tả yêu cầu đề bài môn PRM393
└── PROJECT_LOG.md                            # Nhật ký kiến trúc & tiến độ dự án
```

---

## 2. CHI TIẾT KỸ THUẬT HIỆU ỨNG LIQUID GLASS

1. **Khúc xạ quang học thực tế (`BackdropFilter` + `ImageFilter.blur`):**
   - Các card và thanh dock sử dụng `sigmaX: 16 - 25`, `sigmaY: 16 - 25`. Khi cuộn danh sách, các task trôi qua bên dưới thanh Dock sẽ bị làm nhòe thấu kính chân thực.
2. **Specular Highlight Border:**
   - Viền trắng phản quang `Colors.white.withValues(alpha: 0.85)` dày 1.4px, giả lập ánh sáng chiếu lên mép kính cong.
3. **Liquid Translucent Gradient Fill:**
   - Dải chuyển màu 3 tầng từ `white/70` ➔ `white/35` ➔ `white/15` tạo độ dày và cảm giác chất lỏng cho tấm kính.
4. **Nền chuyển màu đa sắc (Fluid Mesh Orbs):**
   - Các khối cầu RadialGradient phía sau phát tán ánh sáng dịu mắt (`#DCE7FC`, `#E5DEF4`, `#D3E8EB`), làm nền cho các tấm kính phản chiếu khi tương tác.
5. **Tiêu chuẩn chất lượng:**
   - `flutter analyze`: **0 issues**.
   - `flutter test`: **100% PASS**.

---

## 3. TỐI ƯU HÓA LAYOUT & KHẮC PHỤC RENDERFLEX OVERFLOW

1. **Nguyên nhân lỗi `BOTTOM OVERFLOWED BY 2.0 PIXELS`:**
   - Khi tiêu đề task xuống 2 dòng (ví dụ: *"Complete UI \n assignment"*), `IntrinsicHeight` dùng để kéo dài vạch timeline đã tính toán chiều cao dựa trên bước speculative intrinsic.
   - Do sự chênh lệch subpixel làm tròn dòng chữ trong môi trường Web CanvasKit (khoảng 2.0px), `Column` bên trong thẻ kính bị ép chặt vào khung chiều cao cố định dẫn đến cảnh báo vạch sọc vàng đen.
2. **Giải pháp kiến trúc không phụ thuộc Intrinsic:**
   - Chuyển `TaskTimelineTile` sang cơ chế `Stack` kết hợp `Positioned(left: 25.25, top: 48, bottom: 0)` cho trục kẻ timeline.
   - Nội dung thẻ `LiquidGlass` co dãn 100% tự nhiên theo độ dài nội dung với `Column(mainAxisSize: MainAxisSize.min)`, triệt tiêu hoàn toàn nguy cơ overflow bất kể font chữ hay độ dài tiêu đề.
   - Bổ sung cấu trúc `Wrap` và `Flexible` cho `AppHeader`, `WeekCalendarStrip`, `TaskFilterBar` đảm bảo tương thích hoàn hảo từ màn hình điện thoại nhỏ (375px) đến Desktop.

