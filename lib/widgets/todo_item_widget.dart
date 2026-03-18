// =============================================================================
// Flutter Assignment #1 — Todo List App
// Author : Abdul Hadi
// =============================================================================

import 'package:flutter/material.dart';
import '../models/todo.dart';

/// A Material card that displays a single [Todo] item.
/// The checkbox toggles the done state; tapping the whole card also toggles it.
class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final bool isToggling;
  final ValueChanged<bool> onToggle;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    this.isToggling = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: todo.done ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: todo.done
            ? BorderSide(color: colorScheme.outlineVariant, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isToggling ? null : () => onToggle(!todo.done),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------------------------
              // Checkbox / loading indicator
              // ----------------------------------------------------------------
              SizedBox(
                width: 24,
                height: 24,
                child: isToggling
                    ? Padding(
                        padding: const EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.primary,
                        ),
                      )
                    : Checkbox(
                        value: todo.done,
                        activeColor: colorScheme.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        onChanged: (val) {
                          if (val != null) onToggle(val);
                        },
                      ),
              ),

              const SizedBox(width: 10),

              // ----------------------------------------------------------------
              // Title + description
              // ----------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration:
                            todo.done ? TextDecoration.lineThrough : null,
                        color: todo.done
                            ? colorScheme.onSurface.withOpacity(0.45)
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration:
                              todo.done ? TextDecoration.lineThrough : null,
                          color: todo.done
                              ? colorScheme.onSurface.withOpacity(0.35)
                              : colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (todo.createdAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(todo.createdAt!),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ----------------------------------------------------------------
              // Done badge
              // ----------------------------------------------------------------
              if (todo.done)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    'Done',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }
}
