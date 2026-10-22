import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assignment1_todolist_app/screens/todo_list_screen.dart';
import 'package:assignment1_todolist_app/screens/login_screen.dart';
import 'package:assignment1_todolist_app/widgets/task_timeline_tile.dart';

void main() {
  testWidgets('Todo Planner UI and Workflow Test (View, Add, Complete, Delete)', (WidgetTester tester) async {
    // Đặt kích thước màn hình test để hiển thị đủ chiều dọc
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Khởi chạy TodoListScreen trực tiếp
    await tester.pumpWidget(const MaterialApp(home: TodoListScreen()));
    await tester.pumpAndSettle();

    // Kiểm tra Header, trạng thái rỗng sạch sẽ (không có mock task) và nút View ban đầu
    expect(find.text('Todo Planner'), findsOneWidget);
    expect(find.text('No tasks planned for this day.'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    // 2. Kiểm tra đóng/mở Week Preview mượt mà
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    expect(find.text('Collapse'), findsOneWidget);

    await tester.tap(find.text('Collapse'));
    await tester.pumpAndSettle();
    expect(find.text('View'), findsOneWidget);

    // 3. Mở Modal Thêm task qua nút "+ Add task" ở thanh Dock
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Plan something good'), findsOneWidget);

    // 4. Kiểm tra Validation khi để trống: bấm nút Add task trong form (nút thứ 2)
    await tester.tap(find.text('Add task').last);
    await tester.pumpAndSettle();
    expect(find.text('Give your task a name.'), findsOneWidget);

    // 5. Nhập tiêu đề hợp lệ và lưu
    await tester.enterText(find.byType(TextFormField), 'Study PRM393 Flutter');
    await tester.tap(find.text('Add task').last);
    await tester.pumpAndSettle();

    // Xác nhận task mới xuất hiện trong danh sách
    expect(find.text('Study PRM393 Flutter'), findsAtLeastNWidgets(1));

    // 6. Hoàn thành task và kiểm tra lọc
    final checkButton = find.descendant(
      of: find.byType(TaskTimelineTile),
      matching: find.byType(InkWell),
    ).first;
    await tester.tap(checkButton);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done').first);
    await tester.pumpAndSettle();
    expect(find.text('Study PRM393 Flutter'), findsAtLeastNWidgets(1));

    // 7. Thử nghiệm Xóa một task
    final deleteButtons = find.byTooltip('Delete task');
    expect(deleteButtons, findsWidgets);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();
    expect(find.text('No tasks planned for this day.'), findsOneWidget);
  });

  testWidgets('Todo Planner renders on mobile phone width without layout overflow', (WidgetTester tester) async {
    // Kích thước chuẩn iPhone SE / màn hình nhỏ (375x812)
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TodoListScreen()));
    await tester.pumpAndSettle();

    // Xác nhận tiêu đề Todo Planner hiển thị trọn vẹn và không có lỗi layout
    expect(find.text('Todo Planner'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LoginScreen renders properly with Google and Guest options', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Todo Planner'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
    expect(find.text('Dùng thử chế độ Khách'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
