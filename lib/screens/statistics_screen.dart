import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Track your productivity',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
            const SizedBox(height: 24),

            // Overview Card
            _buildOverviewCard(theme, taskProvider)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.05),
            const SizedBox(height: 20),

            // Stats Grid
            _buildStatsGrid(theme, taskProvider)
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.05),
            const SizedBox(height: 20),

            // Category Breakdown
            _buildCategoryBreakdown(theme, taskProvider)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.05),
            const SizedBox(height: 20),

            // Priority Distribution
            _buildPriorityDistribution(theme, taskProvider)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(ThemeData theme, TaskProvider taskProvider) {
    final completionRate = taskProvider.completionRate;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(completionRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${taskProvider.completedTasksCount} of ${taskProvider.totalTasksCount} tasks completed',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 50,
            lineWidth: 8,
            percent: completionRate,
            backgroundColor: Colors.white24,
            progressColor: Colors.white,
            circularStrokeCap: CircularStrokeCap.round,
            center: Icon(
              completionRate >= 0.8
                  ? Icons.emoji_events_rounded
                  : completionRate >= 0.5
                      ? Icons.trending_up_rounded
                      : Icons.hourglass_empty_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, TaskProvider taskProvider) {
    final stats = [
      _StatItem(
        title: 'Pending',
        value: taskProvider.pendingTasksCount.toString(),
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _StatItem(
        title: 'Completed',
        value: taskProvider.completedTasksCount.toString(),
        icon: Icons.task_alt_rounded,
        color: const Color(0xFF10B981),
      ),
      _StatItem(
        title: 'Overdue',
        value: taskProvider.overdueTasks.length.toString(),
        icon: Icons.warning_rounded,
        color: const Color(0xFFEF4444),
      ),
      _StatItem(
        title: 'Due Today',
        value: taskProvider.todayTasks.length.toString(),
        icon: Icons.today_rounded,
        color: const Color(0xFF6366F1),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: stats.map((stat) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: stat.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat.icon, color: stat.color, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stat.value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    stat.title,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme, TaskProvider taskProvider) {
    final categoryStats = taskProvider.pendingTasksByCategory;
    final categories = categoryStats.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No pending tasks by category',
            style: TextStyle(color: theme.hintColor),
          ),
        ),
      );
    }

    final total = categories.fold<int>(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasks by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...categories.map((entry) {
            final percentage = entry.value / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: entry.key.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          entry.key.icon,
                          color: entry.key.color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.key.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.value} tasks',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: entry.key.color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(entry.key.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriorityDistribution(ThemeData theme, TaskProvider taskProvider) {
    final priorityStats = <TaskPriority, int>{};
    for (final priority in TaskPriority.values) {
      priorityStats[priority] = taskProvider.tasks
          .where((t) => t.priority == priority && !t.isCompleted)
          .length;
    }

    final total = priorityStats.values.fold<int>(0, (sum, v) => sum + v);
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No pending tasks by priority',
            style: TextStyle(color: theme.hintColor),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority Distribution',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: TaskPriority.values.reversed.map((priority) {
              final count = priorityStats[priority] ?? 0;
              final percentage = count / total;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: priority != TaskPriority.low ? 12 : 0,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(
                              value: percentage,
                              strokeWidth: 8,
                              backgroundColor: priority.color.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation(priority.color),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: priority.color,
                                ),
                              ),
                              Text(
                                '${(percentage * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(priority.icon, size: 14, color: priority.color),
                          const SizedBox(width: 4),
                          Text(
                            priority.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}
