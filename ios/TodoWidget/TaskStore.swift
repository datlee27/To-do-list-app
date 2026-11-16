import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Trình quản lý dữ liệu lưu trữ dùng chung giữa App, Widget Extension và AppIntents
public final class TaskStore {
    public static let suiteName = "group.com.example.assignment1TodolistApp"
    public static let tasksKey = "saved_tasks"

    /// UserDefaults chia sẻ qua App Group
    public static var sharedDefaults: UserDefaults {
        return UserDefaults(suiteName: suiteName) ?? .standard
    }

    /// Thư mục chia sẻ App Group (nếu khả dụng)
    public static var sharedContainerURL: URL? {
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: suiteName
        )
    }

    /// File tasks.json trong App Group container
    public static var sharedJsonFileURL: URL? {
        return sharedContainerURL?.appendingPathComponent("tasks.json")
    }

    /// Đọc toàn bộ danh sách task
    public static func loadTasks() -> [TaskItem] {
        // 1. Thử đọc từ UserDefaults App Group trước
        if let jsonString = sharedDefaults.string(forKey: tasksKey),
           let data = jsonString.data(using: .utf8) {
            let decoder = JSONDecoder()
            if let list = try? decoder.decode([TaskItem].self, from: data) {
                return list
            }
        }

        // 2. Fallback đọc từ file shared_tasks.json
        if let fileURL = sharedJsonFileURL,
           FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL) {
            let decoder = JSONDecoder()
            if let list = try? decoder.decode([TaskItem].self, from: data) {
                return list
            }
        }

        return []
    }

    /// Lưu toàn bộ danh sách task và đồng bộ Widget
    public static func saveTasks(_ tasks: [TaskItem]) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(tasks),
              let jsonString = String(data: data, encoding: .utf8) else {
            return
        }

        // 1. Lưu vào UserDefaults App Group
        sharedDefaults.set(jsonString, forKey: tasksKey)
        sharedDefaults.synchronize()

        // 2. Lưu vào file JSON trong shared container
        if let fileURL = sharedJsonFileURL {
            try? data.write(to: fileURL, options: .atomic)
        }

        // 3. Yêu cầu iOS WidgetKit render lại timeline ngay lập tức
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }

    /// Đổi trạng thái hoàn thành của một task theo ID (cho Interactive Widget)
    public static func toggleTask(id: String) {
        var tasks = loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
            saveTasks(tasks)
        }
    }

    /// Thêm nhanh một task từ Shortcuts / Siri / Action Button (không cần mở app)
    public static func addTask(title: String, durationMinutes: Int = 60) {
        var tasks = loadTasks()
        let now = Date()
        let end = now.addingTimeInterval(TimeInterval(durationMinutes * 60))

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let startString = formatter.string(from: now)
        let endString = formatter.string(from: end)
        let createdString = startString

        let newTask = TaskItem(
            id: UUID().uuidString,
            title: title,
            startDateTime: startString,
            endDateTime: endString,
            isCompleted: false,
            createdAt: createdString
        )
        tasks.append(newTask)
        saveTasks(tasks)
    }

    /// Lọc các task diễn ra trong ngày hôm nay
    public static func getTodayTasks() -> [TaskItem] {
        let all = loadTasks()
        let today = Date()
        return all.filter { $0.isOccurring(on: today) }
    }

    /// Tiến độ hoàn thành công việc hôm nay (total, completed, percent)
    public static func getTodayProgress() -> (total: Int, completed: Int, percent: Double) {
        let todayList = getTodayTasks()
        if todayList.isEmpty {
            return (0, 0, 0.0)
        }
        let completedCount = todayList.filter { $0.isCompleted }.count
        let pct = Double(completedCount) / Double(todayList.count)
        return (todayList.count, completedCount, pct)
    }
}
