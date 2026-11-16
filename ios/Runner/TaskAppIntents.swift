import Foundation
import AppIntents
#if canImport(WidgetKit)
import WidgetKit
#endif

// =============================================================================
// APP INTENT 1: ToggleTaskIntent (Interactive Widget trên Lock Screen iOS 17+)
// =============================================================================
@available(iOS 17.0, *)
public struct ToggleTaskIntent: AppIntent {
    public static var title: LocalizedStringResource = "Đánh dấu hoàn thành"
    public static var description = IntentDescription("Đổi trạng thái hoàn thành của task trực tiếp trên màn hình khoá")

    @Parameter(title: "Task ID")
    public var taskId: String

    public init() {}

    public init(taskId: String) {
        self.taskId = taskId
    }

    public func perform() async throws -> some IntentResult {
        TaskStore.toggleTask(id: taskId)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
        return .result()
    }
}

// =============================================================================
// APP INTENT 2: AddTaskIntent (Thêm việc nhanh qua Phím tắt / Siri / Action Button)
// KHÔNG CẦN MỞ APP (openAppWhenRun = false)
// =============================================================================
@available(iOS 17.0, *)
public struct AddTaskIntent: AppIntent {
    public static var title: LocalizedStringResource = "Thêm công việc mới"
    public static var description = IntentDescription("Thêm nhanh một việc cần làm vào Todo List mà không cần mở app.")

    // Quan trọng: Đảm bảo app KHÔNG cần phải bật lên
    public static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Tên công việc",
        requestValueDialog: IntentDialog("Bạn muốn thêm công việc gì?")
    )
    public var title: String

    public init() {}

    public init(title: String) {
        self.title = title
    }

    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            TaskStore.addTask(title: trimmed)
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
            return .result(dialog: IntentDialog("Đã thêm: \(trimmed)"))
        }
        return .result(dialog: IntentDialog("Tiêu đề công việc không được để trống."))
    }
}

// =============================================================================
// APP SHORTCUTS PROVIDER: Tự động đưa vào ứng dụng "Phím tắt" (Shortcuts) & Siri
// =============================================================================
@available(iOS 17.0, *)
public struct TodoShortcutsProvider: AppShortcutsProvider {
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTaskIntent(),
            phrases: [
                "Thêm công việc trong \(.applicationName)",
                "Thêm task vào \(.applicationName)",
                "Ghi chú việc cần làm trong \(.applicationName)",
                "Add task in \(.applicationName)"
            ],
            shortTitle: "Thêm việc mới",
            systemImageName: "plus.circle.fill"
        )
    }
}
