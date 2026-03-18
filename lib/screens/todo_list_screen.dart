// =============================================================================
// Flutter Assignment #1 — Todo List App
// Author : Abdul Hadi
// =============================================================================

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../widgets/todo_item_widget.dart';
import 'add_todo_screen.dart';

/// Main screen — shows the paginated todo list with lazy loading,
/// pull-to-refresh, and toggle done/undo functionality.
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  static const int _pageSize = 10;

  final _apiService = ApiService();
  final _scrollController = ScrollController();

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  List<Todo> _todos = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  /// Tracks which todo ids are currently being toggled (to show per-item loader).
  final Set<String> _togglingIds = {};

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Scroll listener — lazy loading
  // ---------------------------------------------------------------------------
  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------
  Future<void> _loadInitial() async {
    if (_isLoadingInitial) return;

    setState(() {
      _isLoadingInitial = true;
      _errorMessage = null;
      _todos = [];
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final result = await _apiService.fetchTodos(page: 1, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _todos = result.todos;
        _hasMore = result.hasMore;
        _currentPage = 1;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Failed to load todos. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await _apiService.fetchTodos(page: nextPage, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _todos.addAll(result.todos);
        _hasMore = result.hasMore && result.todos.isNotEmpty;
        _currentPage = nextPage;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Failed to load more items.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Pull-to-refresh
  // ---------------------------------------------------------------------------
  Future<void> _onRefresh() async {
    await _loadInitial();
  }

  // ---------------------------------------------------------------------------
  // Toggle done
  // ---------------------------------------------------------------------------
  Future<void> _toggleDone(Todo todo) async {
    if (_togglingIds.contains(todo.id)) return;

    setState(() => _togglingIds.add(todo.id));

    // Optimistic update
    final originalIndex = _todos.indexWhere((t) => t.id == todo.id);
    if (originalIndex != -1) {
      setState(() {
        _todos[originalIndex] = todo.copyWith(done: !todo.done);
      });
    }

    try {
      final updated = await _apiService.updateTodo(todo.id, done: !todo.done);
      if (!mounted) return;
      setState(() {
        final idx = _todos.indexWhere((t) => t.id == updated.id);
        if (idx != -1) _todos[idx] = updated;
      });
      _showSnackBar(
        updated.done ? '✓ Marked as done' : '↩ Marked as not done',
      );
    } on ApiException catch (e) {
      // Revert optimistic update
      if (!mounted) return;
      setState(() {
        if (originalIndex != -1) _todos[originalIndex] = todo;
      });
      _showSnackBar(e.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (originalIndex != -1) _todos[originalIndex] = todo;
      });
      _showSnackBar('Failed to update todo.', isError: true);
    } finally {
      if (mounted) setState(() => _togglingIds.remove(todo.id));
    }
  }

  // ---------------------------------------------------------------------------
  // Navigate to Add Todo
  // ---------------------------------------------------------------------------
  Future<void> _openAddTodo() async {
    final newTodo = await Navigator.of(context).push<Todo>(
      MaterialPageRoute(builder: (_) => const AddTodoScreen()),
    );

    if (newTodo != null && mounted) {
      // Insert new item at the very top (most recent first)
      setState(() => _todos.insert(0, newTodo));
      _showSnackBar('Todo added!');
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? Colors.red.shade600 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Todos'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isLoadingInitial ? null : _onRefresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: _buildSummaryBar(colorScheme),
        ),
      ),
      body: _buildBody(theme, colorScheme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTodo,
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
        elevation: 4,
      ),
    );
  }

  Widget _buildSummaryBar(ColorScheme cs) {
    final total = _todos.length;
    final done = _todos.where((t) => t.done).length;
    final pending = total - done;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: cs.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip('Total', total, cs.primary),
          const SizedBox(width: 12),
          _chip('Pending', pending, Colors.orange),
          const SizedBox(width: 12),
          _chip('Done', done, Colors.green),
        ],
      ),
    );
  }

  Widget _chip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme cs) {
    // --- Initial loading ---
    if (_isLoadingInitial) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Loading todos…',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    // --- Error state ---
    if (_errorMessage != null && _todos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 64, color: cs.error),
              const SizedBox(height: 16),
              Text(
                'Oops!',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadInitial,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // --- Empty state ---
    if (_todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checklist_rounded, size: 80, color: cs.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No todos yet!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first task.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    // --- Main list ---
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: cs.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 88),
        itemCount: _todos.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Bottom loader tile
          if (index == _todos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final todo = _todos[index];
          return TodoItemWidget(
            key: ValueKey(todo.id),
            todo: todo,
            isToggling: _togglingIds.contains(todo.id),
            onToggle: (_) => _toggleDone(todo),
          );
        },
      ),
    );
  }
}
