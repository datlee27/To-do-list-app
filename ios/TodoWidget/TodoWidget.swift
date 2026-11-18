import WidgetKit
import SwiftUI
import AppIntents

// =============================================================================
// TIMELINE ENTRY
// =============================================================================
struct TodoEntry: TimelineEntry {
    let date: Date
    let todayTasks: [TaskItem]
    let totalCount: Int
    let completedCount: Int
    let progressPercent: Double
}

// =============================================================================
// TIMELINE PROVIDER
// =============================================================================
struct TodoTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(
            date: Date(),
            todayTasks: [
                TaskItem(title: "Họp nhóm đồ án", startDateTime: "2026-11-16T09:00:00Z", endDateTime: "2026-11-16T10:00:00Z", isCompleted: true),
                TaskItem(title: "Hoàn thiện Widget Lock Screen", startDateTime: "2026-11-16T14:00:00Z", endDateTime: "2026-11-16T15:30:00Z", isCompleted: false)
            ],
            totalCount: 2,
            completedCount: 1,
            progressPercent: 0.5
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        let entry = currentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        let entry = currentEntry()
        // Cập nhật lại mỗi 15 phút, đúng 00:00 qua ngày mới, hoặc tức thì khi TaskStore gọi reloadTimelines
        let now = Date()
        let calendar = Calendar.current
        let fifteenMin = calendar.date(byAdding: .minute, value: 15, to: now) ?? now
        let nextDay = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let tomorrowStart = calendar.startOfDay(for: nextDay)
        let nextUpdate = min(fifteenMin, tomorrowStart)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> TodoEntry {
        let todayList = TaskStore.getTodayTasks()
        let (total, completed, pct) = TaskStore.getTodayProgress()
        return TodoEntry(
            date: Date(),
            todayTasks: todayList,
            totalCount: total,
            completedCount: completed,
            progressPercent: pct
        )
    }
}

// =============================================================================
// WIDGET VIEW
// =============================================================================
struct TodoWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: TodoTimelineProvider.Entry

    var remainingCount: Int {
        max(0, entry.totalCount - entry.completedCount)
    }

    var body: some View {
        switch family {
        case .accessoryRectangular:
            lockScreenRectangularView
        case .accessoryCircular:
            lockScreenCircularView
        case .accessoryInline:
            lockScreenInlineView
        case .systemSmall:
            homeScreenSmallView
        default:
            homeScreenMediumView
        }
    }

    // -------------------------------------------------------------------------
    // 1. LOCK SCREEN: Accessory Rectangular (Khối chữ nhật dưới đồng hồ)
    // -------------------------------------------------------------------------
    private var lockScreenRectangularView: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "checklist")
                    .font(.system(size: 10, weight: .bold))
                Text("HÔM NAY: \(entry.completedCount)/\(entry.totalCount)")
                    .font(.system(size: 10, weight: .heavy))
                Spacer()
                if remainingCount == 0 && entry.totalCount > 0 {
                    Text("Xong hết!")
                        .font(.system(size: 9, weight: .medium))
                } else if entry.todayTasks.count > 2 {
                    Text("+\(entry.todayTasks.count - 2)")
                        .font(.system(size: 9, weight: .bold))
                }
            }
            .opacity(0.85)

            if entry.todayTasks.isEmpty {
                Text("Không có việc cần làm")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            } else {
                ForEach(entry.todayTasks.prefix(2)) { task in
                    HStack(spacing: 4) {
                        // Nút tương tác tick hoàn thành trực tiếp trên iOS 17+
                        if #available(iOS 17.0, *) {
                            Button(intent: ToggleTaskIntent(taskId: task.id)) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12, weight: .semibold))
                                    .frame(width: 20, height: 18, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 11, weight: .semibold))
                        }

                        Text(task.title)
                            .font(.system(size: 11, weight: task.isCompleted ? .regular : .medium))
                            .strikethrough(task.isCompleted, color: .secondary)
                            .opacity(task.isCompleted ? 0.6 : 1.0)
                            .lineLimit(1)

                        Spacer()

                        if !task.formattedStartTime.isEmpty {
                            Text(task.formattedStartTime)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    // -------------------------------------------------------------------------
    // 2. LOCK SCREEN: Accessory Circular (Vòng tròn tiến độ dưới đồng hồ)
    // -------------------------------------------------------------------------
    private var lockScreenCircularView: some View {
        Gauge(value: entry.progressPercent) {
            Image(systemName: "checkmark")
                .font(.system(size: 10, weight: .bold))
        } currentValueLabel: {
            Text("\(remainingCount)")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    // -------------------------------------------------------------------------
    // 3. LOCK SCREEN: Accessory Inline (Dòng chữ trên đồng hồ)
    // -------------------------------------------------------------------------
    private var lockScreenInlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "checklist")
            if remainingCount == 0 {
                Text("Đã xong mọi việc!")
            } else {
                Text("\(remainingCount) việc còn lại")
            }
        }
    }

    // -------------------------------------------------------------------------
    // 4. HOME SCREEN: Small Widget
    // -------------------------------------------------------------------------
    private var homeScreenSmallView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("\(Int(entry.progressPercent * 100))%")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(.blue)
            }

            Spacer()

            Text("\(remainingCount)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("việc cần làm hôm nay")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            if let nextTask = entry.todayTasks.first(where: { !$0.isCompleted }) {
                Text(nextTask.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.secondarySystemBackground)
        }
    }

    // -------------------------------------------------------------------------
    // 5. HOME SCREEN: Medium Widget
    // -------------------------------------------------------------------------
    private var homeScreenMediumView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("listcheck", systemImage: "checklist")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.blue)
                Spacer()
                Text("\(entry.completedCount)/\(entry.totalCount) hoàn thành")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Divider()

            if entry.todayTasks.isEmpty {
                Spacer()
                Text("Không có công việc nào trong ngày.")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ForEach(entry.todayTasks.prefix(3)) { task in
                    HStack(spacing: 6) {
                        if #available(iOS 17.0, *) {
                            Button(intent: ToggleTaskIntent(taskId: task.id)) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(task.isCompleted ? .green : .gray)
                                    .frame(width: 24, height: 22, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        } else {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 13))
                                .foregroundColor(task.isCompleted ? .green : .gray)
                        }

                        Text(task.title)
                            .font(.system(size: 12, weight: task.isCompleted ? .regular : .medium))
                            .strikethrough(task.isCompleted, color: .secondary)
                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                            .lineLimit(1)

                        Spacer()

                        if !task.formattedStartTime.isEmpty {
                            Text(task.formattedStartTime)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.secondarySystemBackground)
        }
    }
}

// =============================================================================
// WIDGET CONFIGURATION
// =============================================================================
struct TodoWidget: Widget {
    let kind: String = "TodoLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoTimelineProvider()) { entry in
            TodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("listcheck")
        .description("Theo dõi và tick hoàn thành công việc trực tiếp trên Màn hình khóa.")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline,
            .systemSmall,
            .systemMedium
        ])
    }
}
