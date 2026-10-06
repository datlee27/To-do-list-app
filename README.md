# Todo Planner — Liquid Glass Todo List App (PRM393 Assignment 1)

A modern, high-aesthetic Flutter Todo application crafted with an **iOS-inspired Liquid Glass** design system, optical blurring, real-time light refraction, and interactive task management.

Developed for **PRM393 Assignment 1**.

---

## ✨ Features

- **Liquid Glass Aesthetics:**
  - Real-time background blur refraction (`BackdropFilter` with `ImageFilter.blur`).
  - Specular highlight borders and translucent multi-stop gradients.
  - Ambient fluid color mesh orbs creating a dynamic, responsive background.
- **Task Management (Assignment Rubric Compliant):**
  - **View Tasks:** Beautiful timeline view connecting tasks with start and end times.
  - **Add Task:** Bottom sheet editor with task title validation and interactive date/time pickers.
  - **Edit Task:** Pre-fills existing task parameters and allows instant editing.
  - **Delete Task:** Quick deletion with immediate state refresh.
  - **Mark Completed:** Toggle completion state with custom animated checkmark pill.
- **Interactive Calendar & Filters:**
  - **7-day Week Strip:** Switch between weeks, select individual days, and view per-day task counts.
  - **Filter Tabs:** Quickly filter tasks by `All`, `Active`, or `Done`.
  - **Chronological Sorting:** Toggle between earliest-first and latest-first time sorting.
  - **Floating Dock:** Bottom glass bar displaying real-time statistics (Total, Done, Left) and quick "+ Add task" trigger.
- **Pure Flutter Local State:**
  - Managed via clean `StatefulWidget` and `setState` patterns (no external state management bloat).
  - 100% standard Flutter widgets.

---

## 🏗️ Architecture

```text
lib/
├── main.dart                      # App entrypoint (MaterialApp config & light theme)
├── models/
│   └── task_item.dart             # TaskItem model, date/time helpers, TaskFilter enum
├── theme/
│   └── app_colors.dart            # Design tokens & color constants
├── widgets/
│   ├── liquid_glass.dart          # Reusable Liquid Glass optical container
│   ├── app_header.dart            # Top branding pill & hero typography
│   ├── week_calendar_strip.dart   # 7-day week selector with week offset switcher
│   ├── task_filter_bar.dart       # Responsive day title, filter pills & sort toggle
│   ├── task_timeline_tile.dart    # Timeline axis with Stack-positioned connector line
│   ├── bottom_dock_bar.dart       # Floating glass dock with counters & Add button
│   └── task_editor_sheet.dart     # Modal glass sheet for adding & editing tasks
└── screens/
    └── todo_list_screen.dart      # Main screen orchestrator & local state manager
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.27+ or 3.47+)
- Dart SDK (v3.6+)
- Chrome / Android device / iOS Simulator

### Run the App

1. **Clone the repository:**
   ```bash
   git clone https://github.com/datlee27/To-do-list-app.git
   cd To-do-list-app
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Chrome (Web):**
   ```bash
   flutter run -d chrome
   ```

4. **Run on Android:**
   ```bash
   flutter run -d <device_id>
   ```

5. **Run Tests:**
   ```bash
   flutter test
   ```

---

## 🧪 Testing & Code Quality

- Automated widget test suite covering:
  - Add / edit / delete workflow.
  - Validation empty title prompt.
  - Filter and sort toggles.
  - Mobile compact screen (375px) responsive rendering without `RenderFlex` overflows.
- Analysis: `flutter analyze` passes with 0 issues.
