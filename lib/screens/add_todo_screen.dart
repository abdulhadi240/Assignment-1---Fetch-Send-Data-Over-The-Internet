// =============================================================================
// Flutter Assignment #1 — Todo List App
// Author : Abdul Hadi
// =============================================================================

import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/api_service.dart';

/// Screen for creating a new Todo item.
/// Validates title and description before posting to the server.
class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiService = ApiService();

  bool _isSubmitting = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    // Trigger form validation
    if (!_formKey.currentState!.validate()) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final newTodo = await _apiService.createTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      // Return the newly created todo to the list screen
      Navigator.of(context).pop<Todo>(newTodo);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
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
      appBar: AppBar(
        title: const Text('New Todo'),
        centerTitle: true,
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save todo',
              onPressed: _submit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ----------------------------------------------------------------
              // Header illustration / icon
              // ----------------------------------------------------------------
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_task_rounded,
                    size: 36,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ----------------------------------------------------------------
              // Title field
              // ----------------------------------------------------------------
              Text(
                'Title',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  prefixIcon: const Icon(Icons.title),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 20),

              // ----------------------------------------------------------------
              // Description field
              // ----------------------------------------------------------------
              Text(
                'Description',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                enabled: !_isSubmitting,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 500,
                maxLines: 5,
                minLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add more details…',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 64),
                    child: Icon(Icons.notes),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required.';
                  }
                  if (value.trim().length < 5) {
                    return 'Description must be at least 5 characters.';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: 32),

              // ----------------------------------------------------------------
              // Save button
              // ----------------------------------------------------------------
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSubmitting ? 'Saving…' : 'Save Todo',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 12),

              // ----------------------------------------------------------------
              // Cancel button
              // ----------------------------------------------------------------
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
