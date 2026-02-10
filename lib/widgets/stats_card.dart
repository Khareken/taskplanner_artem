import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StatsCard extends StatelessWidget {
  final int completedCount;
  final int pendingCount;
  final double completionRate;

  const StatsCard({
    super.key,
    required this.completedCount,
    required this.pendingCount,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalTasks = completedCount + pendingCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                  "Today's Progress",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completedCount / $totalTasks',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalTasks == 0
                      ? 'No tasks yet'
                      : pendingCount == 0
                          ? 'All done! 🎉'
                          : '$pendingCount tasks remaining',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 6,
            percent: completionRate.clamp(0.0, 1.0),
            backgroundColor: Colors.white24,
            progressColor: Colors.white,
            circularStrokeCap: CircularStrokeCap.round,
            center: Text(
              '${(completionRate * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            animation: true,
            animationDuration: 800,
          ),
        ],
      ),
    );
  }
}
