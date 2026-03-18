# Flutter Todo App — Assignment #1

**Course:** Flutter Training
**Author:** Abdul Hadi | k201069
**Server:** https://apimocker.com/todos

---

## Features

| Feature | Status |
|---|---|
| Lazy load with scroll controller (10 items/page) | ✅ |
| Paginated API calls (GET with `_page` & `_limit`) | ✅ |
| Add new todo (title + description — both required) | ✅ |
| Mark todo as done / undo | ✅ |
| Most recent item at top of list | ✅ |
| Pull-to-refresh | ✅ |
| Loading indicator on initial fetch | ✅ |
| Loading indicator on post (optional) | ✅ |
| Per-item loading indicator on toggle | ✅ |
| Form validation with error messages | ✅ |
| Error handling with user-friendly messages | ✅ |
| Material 3 design — light & dark theme | ✅ |
| Manual JSON serialization (no build_runner) | ✅ |
| Only `http` as extra dependency | ✅ |

---

## Architecture

```
lib/
├── main.dart                  # App entry point + theme
├── models/
│   └── todo.dart              # Todo & PaginatedTodos data classes (manual JSON)
├── services/
│   └── api_service.dart       # All REST calls via http package
├── screens/
│   ├── todo_list_screen.dart  # Main list: lazy load, pull-to-refresh, toggle
│   └── add_todo_screen.dart   # Add todo form with validation
└── widgets/
    └── todo_item_widget.dart  # Reusable todo card widget
```

---

## API Endpoints Used

| Method | URL | Purpose |
|---|---|---|
| `GET` | `/todos?_page=1&_limit=10&_sort=id&_order=desc` | Fetch paginated todos |
| `POST` | `/todos` | Create new todo |
| `PATCH` | `/todos/:id` | Update done status |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on a device/emulator
flutter run

# Build APK
flutter build apk --release
```

> **Requires Flutter ≥ 3.0.0**

---
