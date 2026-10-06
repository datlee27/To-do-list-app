import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:assignment1_todolist_app/main.dart';

void main() {
  testWidgets('Todo Planner UI and Workflow Test (View, Add, Complete, Delete)', (WidgetTester tester) async {
    // Đặt kích thước màn hình test để hiển thị đủ chiều dọc
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Khởi chạy TodoApp
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Kiểm tra các thành phần Header & Initial tasks
    expect(find.text('Todo Planner'), findsOneWidget);
    expect(find.text('Learn Flutter'), findsOneWidget);

    // 2. Mở Modal Thêm task qua nút "+ Add task" ở đáy màn hình
    await tester.tap(find.text('Add task'));
    await tester.pumpAndSettle();

    expect(find.text('Plan something good'), findsOneWidget);

    // 3. Kiểm tra Validation khi để trống
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add task'));
    await tester.pumpAndSettle();
    expect(find.text('Give your task a name.'), findsOneWidget);

    // 4. Nhập tiêu đề hợp lệ và lưu
    await tester.enterText(find.byType(TextFormField), 'Study PRM393 Flutter');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add task'));
    await tester.pumpAndSettle();

    // Xác nhận task mới xuất hiện trong danh sách
    expect(find.text('Study PRM393 Flutter'), findsOneWidget);

    // 5. Thử nghiệm Xóa một task
    final deleteButtons = find.byTooltip('Delete task');
    expect(deleteButtons, findsWidgets);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // 6. Thử nghiệm chuyển đổi bộ lọc All, Active, Done
    await tester.tap(find.text('Done').first);
    await tester.pumpAndSettle();
    expect(find.text('Complete UI assignment'), findsOneWidget);

    await tester.tap(find.text('All').first);
    await tester.pumpAndSettle();
  });

  testWidgets('Todo Planner renders on mobile phone width without layout overflow', (WidgetTester tester) async {
    // Kích thước chuẩn iPhone SE / màn hình nhỏ (375x812)
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Xác nhận task dài "Complete UI assignment" hiển thị không gây lỗi
    expect(find.text('Complete UI assignment'), findsOneWidget);
    // Xác nhận không có ngoại lệ RenderFlex overflow ném ra
    expect(tester.takeException(), isNull);
  });
}
