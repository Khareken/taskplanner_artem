import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final selectedCategory = taskProvider.selectedCategory;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // All filter
          _buildFilterChip(
            context: context,
            label: 'All',
            icon: Icons.grid_view_rounded,
            isSelected: selectedCategory == null,
            color: theme.colorScheme.primary,
            onTap: () => taskProvider.setSelectedCategory(null),
            count: taskProvider.tasks.where((t) => !t.isCompleted).length,
          ),
          const SizedBox(width: 10),

          // Category filters
          ...TaskCategory.values.map((category) {
            final count = taskProvider.pendingTasksByCategory[category] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildFilterChip(
                context: context,
                label: category.name,
                icon: category.icon,
                isSelected: selectedCategory == category,
                color: category.color,
                onTap: () => taskProvider.setSelectedCategory(category),
                count: count,
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: -0.05);
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    required int count,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : theme.hintColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : theme.hintColor,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? color : theme.hintColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : theme.hintColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
