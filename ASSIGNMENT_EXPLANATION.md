# TÀI LIỆU GIẢI THÍCH KIẾN TRÚC & ĐỐI CHIẾU ĐỀ BÀI (PRM393 ASSIGNMENT 1)

> **Mục tiêu tài liệu:**  
> 1. Đối chiếu chi tiết từng file trong source code với yêu cầu gốc của đề bài: file nào là **bắt buộc theo đề**, file nào là **làm thêm nâng cao**.  
> 2. Giải thích cơ chế hoạt động của **`Screen` (`todo_list_screen.dart`)** từ góc nhìn của lập trình viên chuyển từ **React / React Native** sang **Flutter**.

---

## PHẦN 1: BẢNG ĐỐI CHIẾU CÁC FILE TRONG DỰ ÁN VỚI ĐỀ BÀI

### 1. Phân loại tổng quan
Trong dự án hiện tại có **2 nhóm file**:
- **Nhóm Đề bài (Core Rubric & Bonus đề bài):** Đáp ứng 100% các tiêu chí chấm điểm kỹ thuật của môn PRM393 (Local State, `StatefulWidget`, `setState`, thêm/sửa/xóa/đổi trạng thái/lọc/thống kê).
- **Nhóm Làm thêm (Liquid Glass & iOS 26 Styling):** Được tạo ra khi bạn đưa file mẫu giao diện React (`App.tsx`) vào và yêu cầu thiết kế theo phong cách kính lỏng quang học mờ ảo, nâng tầm thẩm mỹ vượt bậc so với một bài tập sinh viên thông thường.

---

### 2. Chi tiết từng file

| Tên File | Phân loại | Giải thích chức năng & Đáp ứng đề bài PRM393 |
| :--- | :--- | :--- |
| **`lib/main.dart`** | 🟢 **Core (Đề bài)** | Điểm khởi chạy của ứng dụng Flutter. Chứa `MaterialApp`, cấu hình Theme và gọi màn hình đầu tiên `TodoListScreen()`. Đề bài yêu cầu dùng `MaterialApp`. |
| **`lib/models/task_item.dart`** | 🟢 **Core (Đề bài)** | Class Model định nghĩa cấu trúc dữ liệu của 1 công việc: `id`, `title`, `isCompleted`. Bổ sung `startDateTime`, `endDateTime` và enum `TaskFilter` (`all`, `active`, `done`). |
| **`lib/screens/todo_list_screen.dart`** | 🟢 **Core (Đề bài)** | **Màn hình chính**. Là "Bộ não" quản lý toàn bộ dữ liệu công việc bằng `StatefulWidget` & `setState()`. Thực hiện các chức năng cốt lõi: Xem, Thêm, Sửa, Xóa, Đổi trạng thái `isCompleted`. Dùng `ListView` theo đúng đề. Đề bài cấm dùng Provider/Bloc/Firebase, bắt buộc dùng State thuần tại đây. |
| **`lib/widgets/task_editor_sheet.dart`** | 🟢 **Core (Đề bài) + UI** | **Thêm & Sửa Task**: Đáp ứng **Requirement 2** (Form, `TextFormField`, nút `ElevatedButton("Add task")`, validation báo lỗi khi rỗng). Kiêm luôn **Bonus Challenge** (Sửa Task - Edit). Mở trượt lên từ nút "+ Add task". |
| **`lib/widgets/task_timeline_tile.dart`** | 🟢 **Core (Đề bài) + UI** | **Hiển thị Task Item**: Đáp ứng **Requirement 3, 4, 5** (Tiêu đề `Text`, nút Complete tích đổi màu và gạch ngang chữ, nút Xóa tức thời khỏi danh sách, nút Sửa). Thiết kế dạng Timeline thời gian cao cấp. |
| **`lib/widgets/bottom_dock_bar.dart`** | 🟢 **Bonus (Đề bài) + UI** | **Thanh Dock nổi**: Đáp ứng **Bonus Challenge** (Hiển thị thống kê `Total`, `Done`, `Left` theo thời gian thực) và nút bấm tiện ích `+ Add task`. |
| **`lib/widgets/task_filter_bar.dart`** | 🟢 **Bonus (Đề bài) + UI** | **Bộ lọc & Sắp xếp**: Đáp ứng **Bonus Challenge** (Bộ lọc 3 chế độ `All`, `Active`, `Done` và nút đảo chiều sắp xếp thời gian `Sort`). |
| **`lib/widgets/week_calendar_strip.dart`** | 🟣 **Làm thêm (UI)** | **Thanh trượt lịch tuần**: Hiển thị 7 ngày trong tuần, tự động đếm số lượng task mỗi ngày, bấm đổi ngày và chuyển tuần (`weekOffset`). |
| **`lib/widgets/app_header.dart`** | 🟣 **Làm thêm (UI)** | **Header trên cùng**: Biểu tượng kiểm hoàn thành, tên ứng dụng *"Todo Planner"*, ngày hiện tại và nút quay về hôm nay (*"Today"*). |
| **`lib/widgets/liquid_glass.dart`** | 🟣 **Làm thêm (UI)** | **Khối kính quang học**: Sử dụng `BackdropFilter` và `ImageFilter.blur` làm mờ nhòe khúc xạ các phần tử phía dưới, kèm viền trắng sáng `Specular Highlight Border`. |
| **`lib/theme/app_colors.dart`** | 🟣 **Làm thêm (UI)** | Khai báo bảng mã màu thiết kế Liquid Glass (`#EAF0F8`, `#28364A`, `#6688BB`, v.v.) và các màu bóng đổ đổ bóng ambient/accent. |
| **`test/widget_test.dart`** | 🟢 **Hỗ trợ chấm điểm** | Bộ kiểm thử tự động (Unit/Widget Tests): tự động giả lập bấm nút Thêm, kiểm tra Validation khi rỗng, Đổi trạng thái, Lọc, Xóa và kiểm tra giao diện mobile không bị tràn màn hình (Overflow). |

---

## PHẦN 2: GIẢI THÍCH CHUYÊN SÂU VỀ `SCREEN` CHO NGƯỜI TỪ REACT / REACT NATIVE

Nếu bạn đã quen với **React Native**, đây là bảng quy đổi tư duy trực tiếp sang **Flutter**:

```
React Native                     Flutter
-------------------------------------------------------------------------------------
Functional Component             StatelessWidget / StatefulWidget
useState(initialValue)           Biến trạng thái bên trong State (ví dụ: _tasks)
setTasks(newTasks)               setState(() { _tasks = newTasks; })
Props (props.title, onPress)     Final fields của Constructor (widget.title, onTap)
JSX return (<View>...)           Hàm Widget build(BuildContext context) { return ... }
Container / Smart Component      Screen (TodoListScreen)
Presentational / Dumb Component  Widgets con (TaskTimelineTile, BottomDockBar)
```

---

### 1. "Screen" là gì và tại sao nó lại là `StatefulWidget`?

Trong kiến trúc ứng dụng:
- **Widget con (Component):** Giống như các khối lego riêng lẻ (nút bấm, thẻ task, thanh dock). Chúng chỉ biết **hiển thị cái gì được đưa cho** và **báo khi có người bấm vào**. Chúng không sở hữu dữ liệu của cả ứng dụng.
- **Screen (`TodoListScreen`):** Đóng vai trò là **"Tổng đạo diễn"** hay **"Single Source of Truth"** (Nguồn chân lý duy nhất).
  - Toàn bộ danh sách `_tasks` chỉ nằm duy nhất tại `TodoListScreen`.
  - Ngày đang chọn `_selectedDate` chỉ nằm tại `TodoListScreen`.
  - Bộ lọc đang bật `_currentFilter` chỉ nằm tại `TodoListScreen`.

Vì dữ liệu này thay đổi liên tục khi người dùng tương tác (thêm task, tích hoàn thành, xóa task), nên Screen **bắt buộc phải là `StatefulWidget`** để lưu giữ trạng thái trong bộ nhớ.

---

### 2. Cấu trúc 2 tầng của `TodoListScreen`:

```dart
// TẦNG 1: Khai báo Widget bên ngoài (Bất biến - Immutable)
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

// TẦNG 2: Bộ não lưu trữ State bên trong (Khả biến - Mutable)
class _TodoListScreenState extends State<TodoListScreen> {
  // Toàn bộ State và Logic nghiệp vụ nằm ở đây!
}
```

---

### 3. Bóc tách từng phần trong `_TodoListScreenState`:

#### A. Khai báo State (Tương đương các `useState` trong React Native):
```dart
// Tương đương: const [selectedDate, setSelectedDate] = useState(today);
late DateTime _selectedDate;

// Tương đương: const [weekOffset, setWeekOffset] = useState(0);
int _weekOffset = 0;

// Tương đương: const [currentFilter, setCurrentFilter] = useState('All');
TaskFilter _currentFilter = TaskFilter.all;

// Tương đương: const [reverseSort, setReverseSort] = useState(false);
bool _reverseSort = false;

// Tương đương: const [tasks, setTasks] = useState([...initialTasks]);
late List<TaskItem> _tasks;
```

#### B. Khởi tạo dữ liệu lần đầu (`initState` - Tương đương `useEffect(() => {}, [])`):
```dart
@override
void initState() {
  super.initState();
  // Khởi tạo ngày hiện tại và 4 công việc mẫu ban đầu
  _selectedDate = DateTime(now.year, now.month, now.day);
  _tasks = [ ... ];
}
```

#### C. Dữ liệu phái sinh (Getters - Tương đương `useMemo` trong React):
Bạn không cần tạo thêm biến state mới mà dùng Getter để tính toán tức thời:
- `List<TaskItem> get _dayTasks`: Lọc ra chỉ những công việc thuộc ngày `_selectedDate`.
- `List<TaskItem> get _visibleTasks`: Lấy `_dayTasks`, lọc tiếp theo bộ lọc `_currentFilter` (All, Active, Done) và sắp xếp theo `_reverseSort`.

#### D. Các hàm thay đổi State (Tương đương các hàm Dispatch / Handler):
Trong React Native, bạn viết:
```javascript
const toggleComplete = (id) => {
  setTasks(prev => prev.map(t => t.id === id ? { ...t, completed: !t.completed } : t));
};
```
Trong Flutter, bạn viết:
```dart
void _toggleComplete(String taskId) {
  setState(() {
    // 1. Tìm task và đảo ngược isCompleted
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.isCompleted = !task.isCompleted;
  }); // 2. setState báo cho Flutter: "Dữ liệu đã đổi, hãy chạy lại hàm build() ngay!"
}
```

Tương tự với xóa task:
```dart
void _deleteTask(String taskId) {
  setState(() {
    _tasks.removeWhere((t) => t.id == taskId);
  });
}
```

Và thêm / cập nhật task:
```dart
void _saveTask(TaskItem task) {
  setState(() {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _tasks[index] = task; // Cập nhật task đã có
    } else {
      _tasks.add(task);     // Thêm task mới
    }
  });
}
```

---

### 4. Hàm `build()` gắn các Widget con như thế nào?

Hàm `build()` trong Flutter chính là hàm `return (<View> ... </View>)` trong React Native. Nó nhận dữ liệu từ State và truyền xuống các Widget con qua Constructor (Props):

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // 1. Nền chuyển màu dạng lỏng (Ambient Blurs)
        Positioned(...),

        // 2. Nội dung cuộn chính
        ListView(
          children: [
            // GẮN WIDGET 1: Header truyền ngày và callback quay về hôm nay
            AppHeader(
              selectedDate: _selectedDate,
              onBackToToday: _backToToday,
            ),

            // GẮN WIDGET 2: Thanh tuần truyền toàn bộ task và nhận callback khi bấm chọn ngày
            WeekCalendarStrip(
              selectedDate: _selectedDate,
              allTasks: _tasks,
              onDateSelected: (newDate) {
                setState(() => _selectedDate = newDate);
              },
            ),

            // GẮN WIDGET 3: Thanh lọc truyền bộ lọc hiện tại và nhận callback đổi bộ lọc
            TaskFilterBar(
              currentFilter: _currentFilter,
              onFilterChanged: (newFilter) {
                setState(() => _currentFilter = newFilter);
              },
            ),

            // GẮN WIDGET 4: Danh sách các dòng công việc (Timeline Tiles)
            ...List.generate(visibleTasks.length, (index) {
              final task = visibleTasks[index];
              return TaskTimelineTile(
                task: task,
                onToggleComplete: () => _toggleComplete(task.id),
                onEdit: () => _openTaskEditor(task),
                onDelete: () => _deleteTask(task.id),
              );
            }),
          ],
        ),

        // GẮN WIDGET 5: Thanh Dock nổi ở đáy (Fixed Bottom Dock)
        Positioned(
          bottom: 12,
          child: BottomDockBar(
            totalCount: totalCount,
            doneCount: doneCount,
            leftCount: leftCount,
            onAddTask: () => _openTaskEditor(),
          ),
        ),
      ],
    ),
  );
}
```

---

## TỔNG KẾT LUỒNG DỮ LIỆU (DATA FLOW)

```text
[Người dùng bấm nút Check trên TaskTimelineTile]
                      │
                      ▼ Gọi callback onToggleComplete()
[_TodoListScreenState thực thi _toggleComplete(id)]
                      │
                      ▼ Gọi hàm setState(() { ... })
[Flutter kích hoạt hàm build() của TodoListScreen]
                      │
                      ▼ Tính toán lại _dayTasks & _visibleTasks
[Các Widget con được vẽ lại với dữ liệu mới ngay lập tức]
```

Mọi dữ liệu đi theo **1 chiều duy nhất (Unidirectional Data Flow)**:
1. **Dữ liệu đi từ trên xuống dưới (Downwards):** Từ `Screen` truyền qua tham số Constructor của các `Widgets con`.
2. **Sự kiện đi từ dưới lên trên (Upwards):** Các `Widgets con` bắt tương tác người dùng (`onTap`) và gọi hàm Callback gửi ngược về `Screen` để kích hoạt `setState()`.
