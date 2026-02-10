# Task Planner App

A beautiful and functional task planner app built with Flutter for Android and iOS.

## Features

- **Task Management**: Create, edit, delete, and complete tasks
- **Categories**: Organize tasks by Personal, Work, Shopping, Health, Study, and Other
- **Priority Levels**: Set Low, Medium, or High priority for tasks
- **Due Dates**: Add due dates and times to tasks
- **Subtasks**: Break down tasks into smaller subtasks
- **Calendar View**: View tasks by date with a monthly calendar
- **Statistics**: Track your productivity with detailed statistics
- **Search & Filter**: Find tasks quickly with search and category filters
- **Dark/Light Theme**: Toggle between dark and light modes
- **Persistent Storage**: Tasks are saved locally on your device
- **Smooth Animations**: Beautiful animations throughout the app

## Screenshots

The app features a modern, clean design with:
- Gradient accent cards
- Smooth slide and fade animations
- Circular progress indicators
- Swipe-to-complete and swipe-to-delete actions

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator or iOS Simulator (or physical device)

### Installation

1. Clone the repository or navigate to the project directory:
   ```bash
   cd taskplanner_artem
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point and theme configuration
├── models/
│   └── task.dart             # Task model with priority and category enums
├── providers/
│   ├── task_provider.dart    # Task state management
│   └── theme_provider.dart   # Theme state management
├── screens/
│   ├── home_screen.dart      # Main task list screen
│   ├── add_task_screen.dart  # Create/edit task screen
│   ├── calendar_screen.dart  # Calendar view screen
│   └── statistics_screen.dart# Statistics dashboard
└── widgets/
    ├── task_card.dart        # Task list item widget
    ├── stats_card.dart       # Progress stats widget
    ├── category_filter.dart  # Category filter chips
    └── empty_state.dart      # Empty state placeholder
```

## Dependencies

- **provider**: State management
- **shared_preferences**: Local data persistence
- **uuid**: Unique ID generation
- **intl**: Date formatting
- **flutter_slidable**: Swipe actions for tasks
- **flutter_animate**: Smooth animations
- **google_fonts**: Poppins font family
- **percent_indicator**: Progress indicators
- **table_calendar**: Calendar widget

## License

This project is open source and available under the MIT License.
