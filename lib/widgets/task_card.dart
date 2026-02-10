import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task.id),
        startActionPane: task.dueDate != null && !task.isCompleted
            ? ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _showExtendDeadlineDialog(context),
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    icon: Icons.more_time_rounded,
                    label: 'Extend',
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              )
            : null,
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onToggleComplete(),
              backgroundColor: task.isCompleted
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF10B981),
              foregroundColor: Colors.white,
              icon: task.isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_rounded,
              label: task.isCompleted ? 'Undo' : 'Done',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: task.isOverdue && !task.isCompleted
                  ? Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.5),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: onToggleComplete,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task.isCompleted
                              ? task.category.color
                              : Colors.transparent,
                          border: Border.all(
                            color: task.isCompleted
                                ? task.category.color
                                : theme.hintColor.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? theme.hintColor
                                  : null,
                            ),
                          ),

                          // Description
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.hintColor,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Tags row
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Category
                              _buildTag(
                                icon: task.category.icon,
                                label: task.category.name,
                                color: task.category.color,
                                theme: theme,
                              ),

                              // Priority
                              _buildTag(
                                icon: task.priority.icon,
                                label: task.priority.name,
                                color: task.priority.color,
                                theme: theme,
                              ),

                              // Difficulty with coin reward
                              _buildTag(
                                icon: task.difficulty.icon,
                                label: '${task.difficulty.name} +${task.difficulty.coinReward}🪙',
                                color: task.difficulty.color,
                                theme: theme,
                              ),

                              // Due date
                              if (task.dueDate != null)
                                _buildTag(
                                  icon: Icons.access_time_rounded,
                                  label: _formatDueDate(task),
                                  color: _getDueDateColor(task),
                                  theme: theme,
                                ),

                              // Extend deadline button
                              if (task.dueDate != null && !task.isCompleted)
                                GestureDetector(
                                  onTap: () => _showExtendDeadlineDialog(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.more_time_rounded, size: 12, color: Color(0xFF6366F1)),
                                        SizedBox(width: 4),
                                        Text(
                                          '+1 day',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF6366F1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Subtasks progress
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    lineHeight: 6,
                    percent: task.subtaskProgress,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                    progressColor: theme.colorScheme.primary,
                    barRadius: const Radius.circular(3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${task.subtaskCompleted.where((c) => c).length}/${task.subtasks.length} subtasks',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(Task task) {
    if (task.isDueToday) {
      final time = DateFormat('HH:mm').format(task.dueDate!);
      return 'Today $time';
    }
    if (task.isDueTomorrow) {
      final time = DateFormat('HH:mm').format(task.dueDate!);
      return 'Tomorrow $time';
    }
    if (task.isOverdue) {
      final days = DateTime.now().difference(task.dueDate!).inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    }
    return DateFormat('MMM d').format(task.dueDate!);
  }

  Color _getDueDateColor(Task task) {
    if (task.isOverdue) return const Color(0xFFEF4444);
    if (task.isDueToday) return const Color(0xFFF59E0B);
    return const Color(0xFF6B7280);
  }

  void _showExtendDeadlineDialog(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    final cost = task.difficulty.deadlineExtensionCost;
    final balance = taskProvider.coinBalance;
    final canAfford = balance >= cost;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.more_time_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Extend Deadline'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extend deadline for "${task.title}" by 1 day?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cost:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '$cost 🪙',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canAfford
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Your balance:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '$balance 🪙',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: canAfford
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            if (!canAfford) ...[
              const SizedBox(height: 12),
              const Text(
                'Not enough coins! Complete more tasks to earn coins.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: canAfford
                ? () {
                    taskProvider.extendDeadline(task.id);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deadline extended! -$cost 🪙'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('Extend'),
          ),
        ],
      ),
    );
  }
}
