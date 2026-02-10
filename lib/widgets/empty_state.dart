import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmptyState extends StatelessWidget {
  final bool isSearching;
  final bool hasFilter;

  const EmptyState({
    super.key,
    this.isSearching = false,
    this.hasFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String title;
    String subtitle;
    IconData icon;

    if (isSearching) {
      title = 'No results found';
      subtitle = 'Try a different search term';
      icon = Icons.search_off_rounded;
    } else if (hasFilter) {
      title = 'No tasks in this category';
      subtitle = 'Try selecting a different category';
      icon = Icons.filter_list_off_rounded;
    } else {
      title = 'No tasks yet';
      subtitle = 'Tap the button below to add your first task';
      icon = Icons.task_alt_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.5),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
