import 'dart:math';
import 'package:flutter/material.dart';

/// Summary card displaying calories consumed, daily goal, remaining calories,
/// and a visual progress indicator with dynamic color coding.
class SummaryCard extends StatelessWidget {
  final int consumed;
  final int goal;
  final VoidCallback onEditGoal;

  const SummaryCard({
    super.key,
    required this.consumed,
    required this.goal,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Business calculations:
    // 1. Avoid division by zero if goal is 0 or less.
    final safeGoal = goal > 0 ? goal : 1;
    // 2. Remaining calories is clamped to 0 so we never show negative remaining.
    final remaining = max(0, goal - consumed);
    // 3. Progress ratio between 0.0 and 1.0 for the progress bar.
    final progress = (consumed / safeGoal).clamp(0.0, 1.0);
    // 4. Check if the user has exceeded their goal.
    final isExceeded = consumed > goal;
    final isGoalMet = consumed == goal && goal > 0;

    // Dynamic accent color: Green normally, orange/red if over goal.
    final Color progressColor = isExceeded
        ? Colors.deepOrange
        : (isGoalMet ? Colors.teal : theme.colorScheme.primary);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title, icon badge, and Edit Goal button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7.0),
                        decoration: BoxDecoration(
                          color: progressColor.withAlpha(24),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(
                          Icons.local_fire_department,
                          color: progressColor,
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          'Daily Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B3D1F),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                TextButton.icon(
                  onPressed: onEditGoal,
                  icon: const Icon(Icons.edit, size: 16.0),
                  label: const Text('Edit Goal'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: theme.colorScheme.primary.withAlpha(50)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Middle: Three metric cards (Consumed, Goal, Remaining)
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Consumed',
                    value: '$consumed',
                    unit: 'kcal',
                    icon: Icons.restaurant_outlined,
                    accentColor: isExceeded ? Colors.deepOrange : theme.colorScheme.primary,
                    backgroundColor: isExceeded
                        ? Colors.deepOrange.withAlpha(16)
                        : theme.colorScheme.primary.withAlpha(14),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Goal',
                    value: '$goal',
                    unit: 'kcal',
                    icon: Icons.flag_outlined,
                    accentColor: theme.colorScheme.onSurface,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    label: 'Remaining',
                    value: '$remaining',
                    unit: 'kcal',
                    icon: isExceeded ? Icons.block_outlined : Icons.check_circle_outline,
                    accentColor: isExceeded ? Colors.grey : Colors.green.shade700,
                    backgroundColor: isExceeded
                        ? Colors.grey.withAlpha(14)
                        : Colors.green.shade700.withAlpha(14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.0),

            // Progress Bar Section with Percentage
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Progress',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12.0,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 14.0),

            // Motivational / Warning Status Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: progressColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: progressColor.withAlpha(50),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isExceeded
                        ? Icons.warning_amber_rounded
                        : (isGoalMet ? Icons.check_circle_outline : Icons.info_outline),
                    size: 18.0,
                    color: progressColor,
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      isExceeded
                          ? 'Over goal by ${consumed - goal} kcal'
                          : (isGoalMet
                              ? 'Goal reached! Perfect balance.'
                              : '$remaining kcal remaining to reach your goal.'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: accentColor.withAlpha(35),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14.0, color: accentColor.withAlpha(200)),
                const SizedBox(width: 4.0),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 2.0),
                Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
