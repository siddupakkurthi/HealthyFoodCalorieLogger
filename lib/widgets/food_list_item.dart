import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../utils/date_utils.dart';

/// Reusable card widget representing a single logged food entry.
class FoodListItem extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback onDelete;
  final bool showDate;

  const FoodListItem({
    super.key,
    required this.entry,
    required this.onDelete,
    this.showDate = false,
  });

  /// Helper to get an appropriate modern icon for each meal type.
  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'snacks':
        return Icons.apple_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  /// Helper to get distinct color tint for each meal type.
  Color _getMealColor(String mealType, ColorScheme scheme) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange.shade700;
      case 'lunch':
        return Colors.amber.shade800;
      case 'snacks':
        return Colors.purple.shade600;
      case 'dinner':
        return Colors.indigo.shade600;
      default:
        return scheme.primary;
    }
  }

  /// Shows a confirmation dialog before invoking the deletion callback.
  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Delete Food Entry'),
          content: Text('Are you sure you want to remove "${entry.name}" (${entry.calories} kcal)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealColor = _getMealColor(entry.mealType, theme.colorScheme);

    // Format the date if showDate is enabled (useful on the History screen)
    String dateSubtitle = '';
    if (showDate && entry.date.isNotEmpty) {
      final parsed = AppDateUtils.parseIsoDate(entry.date);
      dateSubtitle = ' • ${AppDateUtils.formatDisplayDate(parsed)}';
    }

    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Meal Icon Container (Squircle)
            Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: mealColor.withAlpha(24),
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(
                  color: mealColor.withAlpha(50),
                  width: 1.0,
                ),
              ),
              child: Icon(
                _getMealIcon(entry.mealType),
                color: mealColor,
                size: 24.0,
              ),
            ),
            const SizedBox(width: 14.0),

            // Meal Name & Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B3D1F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: mealColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: mealColor.withAlpha(45),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          entry.mealType,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: mealColor,
                          ),
                        ),
                      ),
                      if (dateSubtitle.isNotEmpty)
                        Flexible(
                          child: Text(
                            dateSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),

            // Calories badge & Delete action
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
                  ),
                  child: Text(
                    '${entry.calories} kcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.0,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20.0),
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
