import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Trình quản lý dữ liệu lưu trữ dùng chung giữa App, Widget Extension và AppIntents
public final class TaskStore {
    public static let defaultGroupIdentifier = "group.com.example.assignment1TodolistApp"
    public static let tasksKey = "saved_tasks"
    public static let widgetKind = "TodoLockScreenWidget"

    /// Tự động dò App Group hợp lệ đã được ký (hỗ trợ cả App Store/Xcode lẫn sideload iloader có gắn Team ID)
    public static let resolvedGroupIdentifier: String? = {
        var candidates: [String] = []

        func appendGroups(from info: [String: Any]?) {
            guard let info = info else { return }
            if let list = info["ALTApplicationGroups"] as? [String] {
                candidates.append(contentsOf: list)
            }
            if let list = info["ALTAppGroups"] as? [String] {
                candidates.append(contentsOf: list)
            }
        }

        appendGroups(from: Bundle.main.infoDictionary)

        // Nếu đang chạy trong Widget Extension (.appex), kiểm tra thêm host app bundle
        if Bundle.main.bundleURL.pathExtension == "appex" {
            let hostAppURL = Bundle.main.bundleURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            if let hostBundle = Bundle(url: hostAppURL) {
                appendGroups(from: hostBundle.infoDictionary)
                if let hostId = hostBundle.bundleIdentifier, !hostId.isEmpty {
                    candidates.append("group.\(hostId)")
                }
            }
        }

        if let bundleId = Bundle.main.bundleIdentifier, !bundleId.isEmpty {
            var mainId = bundleId
            if mainId.hasSuffix(".TodoWidgetExtension") {
                mainId = String(mainId.dropLast(".TodoWidgetExtension".count))
            } else if mainId.hasSuffix(".TodoWidget") {
                mainId = String(mainId.dropLast(".TodoWidget".count))
            } else {
                mainId = mainId.replacingOccurrences(of: ".TodoWidget", with: "")
            }
            if !mainId.isEmpty {
                candidates.append("group.\(mainId)")
            }
        }

        candidates.append(defaultGroupIdentifier)

        // Loại bỏ trùng lặp nhưng giữ nguyên thứ tự ưu tiên
        var seen = Set<String>()
        let uniqueCandidates = candidates.filter { !$0.isEmpty && seen.insert($0).inserted }

        for candidate in uniqueCandidates {
            if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: candidate) != nil {
                return candidate
            }
        }
        return nil
    }()

    /// Thư mục chia sẻ App Group (nếu entitlement hợp lệ)
    public static var sharedContainerURL: URL? {
        guard let groupId = resolvedGroupIdentifier else { return nil }
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)
    }

    /// UserDefaults chia sẻ qua App Group (chỉ trả về khi App Group hợp lệ)
    public static var sharedGroupDefaults: UserDefaults? {
        guard let groupId = resolvedGroupIdentifier else { return nil }
        return UserDefaults(suiteName: groupId)
    }

    /// File tasks.json trong App Group container (ưu tiên số 1 cho đồng bộ tức thì giữa App & Widget)
    public static var sharedJsonFileURL: URL? {
        return sharedContainerURL?.appendingPathComponent("tasks.json")
    }

    /// File tasks.json trong thư mục Documents của ứng dụng
    public static var localDocumentsJsonFileURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("tasks.json")
    }

    /// Kiểm tra chuỗi có phải JSON Array hợp lệ (bao gồm cả mảng rỗng "[]")
    private static func isValidJsonArray(_ str: String) -> Bool {
        guard !str.isEmpty, let data = str.data(using: .utf8) else {
            return false
        }
        return (try? JSONSerialization.jsonObject(with: data)) is [Any]
    }

    /// Đảm bảo thư mục cha tồn tại trước khi ghi file
    private static func writeAtomic(_ data: Data, to fileURL: URL) {
        let dirURL = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: dirURL.path) {
            try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
        }
        try? data.write(to: fileURL, options: .atomic)
    }

    /// Đọc trực tiếp chuỗi JSON từ 4 lớp lưu trữ, ưu tiên file APFS trong App Group để Widget cập nhật tức thì
    public static func loadRawJsonString() -> String {
        // 1. Ưu tiên file tasks.json trong App Group container (đọc ghi trực tiếp không qua cache cfprefsd)
        if let sharedURL = sharedJsonFileURL,
           FileManager.default.fileExists(atPath: sharedURL.path),
           let data = try? Data(contentsOf: sharedURL),
           let str = String(data: data, encoding: .utf8),
           isValidJsonArray(str) {
            return str
        }

        // 2. UserDefaults của App Group
        if let str = sharedGroupDefaults?.string(forKey: tasksKey), isValidJsonArray(str) {
            if let sharedURL = sharedJsonFileURL,
               !FileManager.default.fileExists(atPath: sharedURL.path),
               let data = str.data(using: .utf8) {
                writeAtomic(data, to: sharedURL)
            }
            return str
        }

        // 3. File tasks.json trong thư mục Documents cục bộ
        if let localURL = localDocumentsJsonFileURL,
           FileManager.default.fileExists(atPath: localURL.path),
           let data = try? Data(contentsOf: localURL),
           let str = String(data: data, encoding: .utf8),
           isValidJsonArray(str) {
            if let sharedURL = sharedJsonFileURL,
               !FileManager.default.fileExists(atPath: sharedURL.path) {
                writeAtomic(data, to: sharedURL)
            }
            if let groupDefaults = sharedGroupDefaults {
                groupDefaults.set(str, forKey: tasksKey)
                groupDefaults.synchronize()
            }
            return str
        }

        // 4. Standard UserDefaults
        if let str = UserDefaults.standard.string(forKey: tasksKey), isValidJsonArray(str) {
            if let sharedURL = sharedJsonFileURL,
               !FileManager.default.fileExists(atPath: sharedURL.path),
               let data = str.data(using: .utf8) {
                writeAtomic(data, to: sharedURL)
            }
            if let groupDefaults = sharedGroupDefaults {
                groupDefaults.set(str, forKey: tasksKey)
                groupDefaults.synchronize()
            }
            return str
        }

        return "[]"
    }

    /// Lưu trực tiếp chuỗi JSON vào tất cả các lớp lưu trữ và kích hoạt WidgetKit reload tức thì
    public static func saveRawJsonString(_ jsonString: String) {
        guard isValidJsonArray(jsonString),
              let data = jsonString.data(using: .utf8) else {
            return
        }

        // 1. Lưu file JSON trong App Group container (ưu tiên tức thì cho Widget)
        if let sharedURL = sharedJsonFileURL {
            writeAtomic(data, to: sharedURL)
        }

        // 2. Lưu UserDefaults App Group
        if let groupDefaults = sharedGroupDefaults {
            groupDefaults.set(jsonString, forKey: tasksKey)
            groupDefaults.synchronize()
        }

        // 3. Lưu file JSON trong Documents directory
        if let localURL = localDocumentsJsonFileURL {
            writeAtomic(data, to: localURL)
        }

        // 4. Lưu Standard UserDefaults
        UserDefaults.standard.set(jsonString, forKey: tasksKey)
        UserDefaults.standard.synchronize()

        // 5. Yêu cầu iOS WidgetKit render lại timeline ngay lập tức
        reloadWidgets()
    }

    /// Yêu cầu WidgetKit làm mới timeline của listcheck Widget
    public static func reloadWidgets() {
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }

    /// Đọc toàn bộ danh sách task
    public static func loadTasks() -> [TaskItem] {
        let jsonString = loadRawJsonString()
        if let data = jsonString.data(using: .utf8) {
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
        saveRawJsonString(jsonString)
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
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        let startDate: Date
        let endDate: Date
        if let maxEndOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: startOfDay),
           let minLateStart = calendar.date(bySettingHour: 23, minute: 58, second: 0, of: startOfDay) {
            if now >= minLateStart {
                startDate = minLateStart
                endDate = maxEndOfDay
            } else {
                startDate = now
                let rawEnd = now.addingTimeInterval(TimeInterval(durationMinutes * 60))
                endDate = min(rawEnd, maxEndOfDay)
            }
        } else {
            startDate = now
            endDate = now.addingTimeInterval(TimeInterval(durationMinutes * 60))
        }

        let newTask = TaskItem(
            id: UUID().uuidString,
            title: title,
            startDateTime: formatter.string(from: startDate),
            endDateTime: formatter.string(from: endDate),
            isCompleted: false,
            createdAt: formatter.string(from: now)
        )
        tasks.append(newTask)
        saveTasks(tasks)
    }

    /// Lọc các task diễn ra trong ngày hôm nay (việc chưa xong ưu tiên lên trước, xếp theo giờ tăng dần)
    public static func getTodayTasks() -> [TaskItem] {
        let all = loadTasks()
        let today = Date()
        return all
            .filter { $0.isOccurring(on: today) }
            .sorted { a, b in
                if a.isCompleted != b.isCompleted {
                    return !a.isCompleted && b.isCompleted
                }
                return (a.startDate ?? .distantFuture) < (b.startDate ?? .distantFuture)
            }
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
