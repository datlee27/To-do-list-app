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

    /// Chuyển đổi startDateTime chuỗi ISO8601 sang đối tượng Date
    public var startDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatter.date(from: startDateTime) { return d }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: startDateTime)
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
        return calendar.isDate(sDate, inSameDayAs: targetDate)
    }
}
