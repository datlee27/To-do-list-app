# ASSIGNMENT: FLUTTER TODO LIST / TASK MANAGER

## Objective
Build a simple Todo List (Task Manager) application using Flutter, where task data is managed using Flutter State (`StatefulWidget` & `setState`).

The app allows users to add tasks, mark tasks as completed, and delete tasks.

---

## Functional Requirements

### 1. Main Screen
- Display a list of current tasks.
- Use `ListView` to show tasks.
- Each task is displayed using `ListTile`.

### 2. Add New Task
- Provide a `TextField` or `TextFormField` for task input.
- Provide an `ElevatedButton` labeled **“Add Task”**.
- When the button is pressed:
  - If input is empty → show validation message.
  - If valid → add task to the list.

### 3. Task Item Structure
Each task item should display:
- 📝 Task title (`Text`)
- ✅ Complete button (`IconButton` or `ElevatedButton`)
- ❌ Delete button (`IconButton`)

### 4. Complete Task
- When the Complete button is pressed:
  - Toggle task status between completed / incomplete.
  - Completed task should:
    - Show strikethrough text **OR**
    - Change text color/style to indicate completion.

### 5. Delete Task
- When the Delete button is pressed:
  - Remove the task from the list immediately.

### 6. Data Handling
- Use local state only.
- No database or persistent storage required.
- Data can be lost when the app reloads.

---

## Technical Constraints

### Allowed Flutter Widgets & Concepts:
- `MaterialApp`
- `Scaffold`
- `AppBar`
- `Text`
- `Icon`
- `ListView`
- `ListTile`
- `TextField` / `TextFormField`
- `Form`
- `ElevatedButton`
- `StatefulWidget`
- `setState()`

### ❌ Do NOT use:
- SQLite / Firebase
- State management packages: Provider / Bloc / Riverpod
- Backend APIs

---

## Optional Challenges (Bonus)
*(For students who finish early)*
- Add task filters:
  - All
  - Completed
  - Incomplete
- Allow editing a task
- Sort tasks by creation time
- Display total number of tasks / completed tasks

---

## Project Structure & Implementation Mapping

```text
lib/
├── main.dart                      # App entry point (MaterialApp & Theme)
├── models/
│   └── task_item.dart             # Model: TaskItem class & TaskFilter enum
├── screens/
│   └── todo_list_screen.dart      # Main Screen (StatefulWidget & setState)
└── widgets/                       # Reusable UI Components
    ├── task_input_form.dart       # Form + TextFormField + ElevatedButton (Add Task)
    ├── task_item_tile.dart        # ListTile + Complete toggle + Edit + Delete
    ├── task_stats_bar.dart        # Realtime Counters: Total, Done, Left
    └── task_filter_bar.dart       # SegmentedButton Filters (All, Done, Active)
```