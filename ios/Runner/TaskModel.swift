import Foundation

/// Model đại diện cho một công việc, đồng bộ với Model Dart TaskItem
public struct TaskItem: Codable, Identifiable {
    public let id: String
    public var title: String
    public var startDateTime: String
    public var endDateTime: String
    public var isCompleted: Bool
    public var createdAt: String

    public init(
        id: String = UUID().uuidString,
        title: String,
        startDateTime: String,
        endDateTime: String,
        isCompleted: Bool = false,
        createdAt: String = ISO8601DateFormatter().string(from: Date())
    ) {
        self.id = id
        self.title = title
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    /// Hàm phân tích cú pháp chuỗi ngày giờ linh hoạt (Hỗ trợ định dạng Dart và chuẩn ISO8601)
    private static func parseFlexibleDate(_ str: String) -> Date? {
        if str.isEmpty { return nil }

        // 1. Chuẩn ISO8601 có múi giờ
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFormatter.date(from: str) { return d }
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let d = isoFormatter.date(from: str) { return d }

        // 2. Chuẩn ngày giờ địa phương của Flutter Dart (toIso8601String không có múi giờ Z)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone.current

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        for fmt in formats {
            df.dateFormat = fmt
            if let d = df.date(from: str) {
                return d
            }
        }
        return nil
    }

    /// Chuyển đổi startDateTime sang đối tượng Date
    public var startDate: Date? {
        return Self.parseFlexibleDate(startDateTime)
    }

    /// Chuyển đổi endDateTime sang đối tượng Date
    public var endDate: Date? {
        return Self.parseFlexibleDate(endDateTime)
    }

    /// Giờ bắt đầu hiển thị dạng HH:mm
    public var formattedStartTime: String {
        guard let date = startDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    /// Kiểm tra xem task có diễn ra trong ngày targetDate không
    public func isOccurring(on targetDate: Date) -> Bool {
        guard let sDate = startDate else { return false }
        let calendar = Calendar.current
        if let eDate = endDate {
            let startDay = calendar.startOfDay(for: sDate)
            let endDay = calendar.startOfDay(for: eDate)
            let targetDay = calendar.startOfDay(for: targetDate)
            return targetDay >= startDay && targetDay <= endDay
        }
        return calendar.isDate(sDate, inSameDayAs: targetDate)
    }
}
