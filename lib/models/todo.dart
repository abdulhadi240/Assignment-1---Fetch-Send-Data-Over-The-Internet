// =============================================================================
// Flutter Assignment #1 — Todo List App
// Author : Abdul Hadi
// =============================================================================

/// Data model representing a single Todo item.
/// All JSON serialization is done manually — no build_runner is used.
class Todo {
  final String id;
  final String title;
  final String description;
  final bool done;
  final DateTime? createdAt;

  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.done,
    this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Deserialization — JSON → Todo
  // ---------------------------------------------------------------------------
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      done: _parseBool(json['done']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization — Todo → JSON
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'done': done,
    };
  }

  /// Returns a copy of this Todo with the given fields replaced.
  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? done,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() =>
      'Todo(id: $id, title: $title, done: $done, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Todo && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------------------------------------------------------
// Response wrapper for paginated API responses
// ---------------------------------------------------------------------------
class PaginatedTodos {
  final List<Todo> todos;
  final int total;
  final int page;
  final int limit;

  const PaginatedTodos({
    required this.todos,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;

  factory PaginatedTodos.fromJson(Map<String, dynamic> json, int page, int limit) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return PaginatedTodos(
      todos: rawList.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json['total'] as num?)?.toInt() ?? rawList.length,
      page: page,
      limit: limit,
    );
  }

  factory PaginatedTodos.fromList(List<dynamic> list, int page, int limit) {
    final todos = list.map((e) => Todo.fromJson(e as Map<String, dynamic>)).toList();
    return PaginatedTodos(
      todos: todos,
      total: todos.length < limit ? (page - 1) * limit + todos.length : page * limit + 1,
      page: page,
      limit: limit,
    );
  }
}
