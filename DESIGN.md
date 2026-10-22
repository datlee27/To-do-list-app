# DESIGN SYSTEM & SPECIFICATION GUIDELINES (DESIGN.MD)
## Project: PRM393 - Todo Planner (Liquid Glass & iOS Optical Aero)

> **Mục tiêu tài liệu:**  
> File này là **Nguồn chân lý duy nhất (Single Source of Truth)** về toàn bộ quy chuẩn thiết kế (Design Tokens, màu sắc, bố cục, hiệu ứng kính mờ Liquid Glass, Typography và Component rules) được trích xuất trực tiếp từ bản thiết kế mẫu nguyên bản (`src.zip` / React Tailwind Prototype).  
> Bất kỳ AI Assistant hay Lập trình viên nào phát triển tính năng mới hoặc chỉnh sửa giao diện đều **BẮT BUỘC** phải tuân theo các quy tắc trong tài liệu này.

---

## 1. BẢNG MÃ MÀU THIẾT KẾ (COLOR PALETTE)

### 1.1. Màu nền & Không gian quang học (Ambient Backgrounds)
Dự án không dùng nền trắng hoặc xám phẳng đơn điệu, mà sử dụng nền đa sắc chuyển động khúc xạ ánh sáng (Liquid Glass Optics):

- **Nền chính ứng dụng (App Stage / Background):** `#EAF0F8` (Xanh pastel phấn nhạt).
- **Đốm sáng Ambient 1 (Góc trên trái - Soft Blue):** `#DCE7FC` với bán kính mờ Gaussian `blur: 90px`.
- **Đốm sáng Ambient 2 (Góc trên phải - Ambient Purple):** `#E5DEF4` (độ mờ 70%) với bán kính mờ Gaussian `blur: 100px`.
- **Đốm sáng Ambient 3 (Góc dưới - Ambient Teal):** `#D3E8EB` (độ mờ 80%) với bán kính mờ Gaussian `blur: 100px`.
- **Đốm sáng Ambient 4 (Tâm màn hình - Pure Light):** `#FFFFFF` (độ mờ 70%) với bán kính mờ Gaussian `blur: 80px`.

### 1.2. Màu chữ & Thương hiệu (Typography & Accent Colors)
- **Primary Ink (Tiêu đề chính, Text đậm):** `#28364A` hoặc `#293B55` (Xanh than mực trầm sâu).
- **Accent Brand (Màu chủ đạo hành động & Icon):** `#4E75AD` (Xanh dương hoàng gia dịu).
- **Secondary Ink (Nội dung phụ, mô tả):** `#64748B` hoặc `#758399` (Xám ghi đá slate).
- **Eyebrow / Sub-heading Text (Dòng chú thích hoa nhỏ):** `#7589A8` hoặc `#7F94B0` (Xanh khói nhạt).
- **Success / Completed Tint (Màu hoàn thành công việc):** `#66A889` hoặc `#608A76` (Xanh ngọc bích bạc hà).
- **Danger / Logout (Cảnh báo, đăng xuất):** `#BF5561` trên nền kính đỏ `#F4DFE1` (độ mờ 80%).

---

## 2. QUY CHUẨN KÍNH LỎNG QUANG HỌC (LIQUID GLASS TOKENS)

Mọi container thẻ nổi (Header, Thẻ Task, Dock Bar, Modal) đều phải tuân thủ công thức kính mờ 3 lớp:
```
1. Lớp làm mờ (Backdrop Blur): sigma = 20px đến 35px.
2. Lớp nền kính (Glass Tint): Nền trắng mờ (Colors.white với opacity 0.35 đến 0.50) hoặc gradient nhạt.
3. Lớp phản xạ viền (Specular Border): Viền trắng tinh khôi (Border.all(color: Colors.white.withOpacity(0.85), width: 1.0)).
4. Đổ bóng quang học (Ambient Shadow): BoxShadow(color: Color(0x2E3C5078), blurRadius: 32, offset: Offset(0, 8)).
```

---

## 3. QUY TẮC THIẾT KẾ MODAL SHEET (TASK EDITOR & DIALOG)

Khi mở Modal Thêm/Sửa Task (`TaskEditorSheet`) hoặc Hộp thoại Xác nhận:

1. **Hiệu ứng Fullscreen Backdrop Blur (Cực kỳ quan trọng):**
   - **BẮT BUỘC** làm mờ toàn bộ giao diện phía sau khi mở modal (`BackdropFilter` với `sigma = 12px - 16px`).
   - Lớp phủ mờ (Barrier Color): `Color(0x263B4E6A)` tương đương `rgba(59, 78, 106, 0.15)`.
   - Không được dùng màn hình đen tối sầm đơn điệu của Material mặc định.
2. **Đỉnh Modal:**
   - Bo góc cong thanh lịch: `BorderRadius.vertical(top: Radius.circular(32))`.
   - **KHÔNG ĐƯỢC** để thanh handle bar màu xám đậm dày cộm.
3. **Nút Đóng (Close Button):**
   - Thiết kế dạng nút tròn kính lỏng: đường kính 32x32px, `BorderRadius.circular(50)`, nền `Colors.white.withOpacity(0.35)`, viền `Colors.white.withOpacity(0.8)`, icon `Icons.close_rounded` màu `#8292A8`.
4. **Quy chuẩn Input Field (Task title):**
   - Bo góc: `BorderRadius.circular(16)`.
   - Nền: `Colors.white.withOpacity(0.45)`.
   - Viền: Viền trắng mờ `BorderSide(color: Colors.white.withOpacity(0.9), width: 1.0)`.
   - Khi focus: Viền phát sáng nhẹ màu xanh pastel `Color(0xFF93C5FD)` (width 1.5), tuyệt đối không dùng viền đậm màu tím hoặc đen.
   - Placeholder: `"What would you like to do?"` màu `#94A3B8`.
5. **Quy chuẩn Chọn Ngày & Giờ (Starts & Ends Pickers):**
   - **Vị trí Icon:** Icon lịch (`Icons.calendar_today_outlined`) và Icon đồng hồ (`Icons.access_time`) **BẮT BUỘC NẰM Ở BÊN PHẢI**, văn bản hiển thị nằm ở bên trái.
   - **Định dạng Ngày:** Định dạng chuẩn Việt Nam / Quốc tế: **`DD/MM/YYYY`** (ví dụ: `22/10/2026`). Tuyệt đối không dùng dạng tháng trước kiểu Mỹ `MM/DD/YYYY`.
   - **Định dạng Giờ:** Định dạng chuẩn 24 giờ: **`HH:mm`** (ví dụ: `09:00`, `10:00`, đệm số 0). Không dùng dạng `9:00 AM`.
6. **Nút Hành động Chính ("+ Add task" / "Save changes"):**
   - Bo góc 18px, chiều cao 52px.
   - Màu nền: Nền kính lỏng xanh nhạt `const Color(0xFFDCE8FA).withOpacity(0.65)`.
   - Viền trắng phản chiếu `Colors.white.withOpacity(0.8)`.
   - Chữ và icon màu xanh mực `#476894`, độ đậm `FontWeight.w600`.

---

## 4. QUY TẮC BỐ CỤC HEADER & RESPONSIVE

1. **Logo & Tiêu đề:**
   - Hộp icon check bo tròn 14px kính lỏng.
   - Tiêu đề `Todo Planner` (font-size 16-17px, bold) **KHÔNG BAO GIỜ ĐƯỢC BỊ CẮT CHỮ** (`Todo Pl...`) trên bất kỳ kích thước màn hình nào (từ iPhone SE 375px đến Pro Max 430px).
2. **Nút Chuyển đổi Ngày ("Today") & Nút Tài khoản ("AccountMenu"):**
   - Nút "Today" và nút Account phải co giãn tự động (flex/shrink). Trên màn hình điện thoại hẹp, nút Account hiển thị tinh gọn (Avatar + Chấm xanh/xám online) để ưu tiên không gian cho tiêu đề ứng dụng.

---

## 5. QUY TẮC THIẾT KẾ WEEK PREVIEW (ACCORDION XEM TRƯỚC TUẦN)

1. **Nút Bấm Mở Rộng / Thu Gọn (Header):**
   - Trái: `Week preview · {count} tasks` (Font size 12, màu `#425B7C`, số task màu `#64748B`).
   - Phải: Nút `Collapse` (khi mở) hoặc `View` (khi đóng) kèm icon mũi tên lên/xuống màu `#58759A`.
   - Nền kính lỏng: `Colors.white.withValues(alpha: 0.45)`, viền sáng `Colors.white.withValues(alpha: 0.85)`, bo góc 16px.
2. **Khối Danh Sách 7 Ngày (Preview Content):**
   - Hiển thị đầy đủ 7 ngày của tuần (từ Thứ Hai đến Chủ Nhật).
   - **Highlight ngày đang chọn:** Thẻ nền trắng mờ `Colors.white.withValues(alpha: 0.65)`, bo góc 14px, viền sáng và đổ bóng ambient nhẹ.
   - **Cột thứ & ngày:** Thứ ngắn (`Mon`, `Tue`...) màu `#607E9F` và số ngày to rõ màu `#28364A`.
   - **Cột công việc:**
     - Nếu có task: Hiển thị giờ 24h (`09:00`, `11:30`...) màu `#476894` + Tên task màu `#334155`. Nếu đã hoàn thành thì gạch ngang `lineThrough` và mờ chữ sang `#94A3B8`.
     - Nếu không có task: Hiển thị dòng chữ `No tasks planned` màu ghi nhạt `#94A3B8`.
   - **Tương tác trực tiếp:** Bấm vào bất kỳ ngày nào trong preview sẽ chọn ngày đó và cập nhật tức thì danh sách công việc ở timeline phía dưới.

---

## 6. HƯỚNG DẪN DÀNH CHO AI KHI THỰC HIỆN CODE

- Luôn kiểm tra file này trước khi thay đổi bất kỳ thành phần UI nào trong `lib/widgets/` hoặc `lib/screens/`.
- Sử dụng các hằng số màu trong [lib/theme/app_colors.dart](file:///Users/mac/Subject/PRM393/Assignment1_todolistApp/lib/theme/app_colors.dart). Nếu thiếu hằng số nào theo bản thiết kế `DESIGN.md`, hãy bổ sung vào `app_colors.dart` trước khi sử dụng.
