import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_list_item.dart';

/// Screen displaying all logged food entries grouped by date, newest first.
class HistoryScreen extends StatelessWidget {
  final List<FoodEntry> entries;
  final ValueChanged<String> onDeleteFood;
  final ValueChanged<DateTime> onSelectDate;

  const HistoryScreen({
    super.key,
    required this.entries,
    required this.onDeleteFood,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 1. Group entries by ISO date string ('yyyy-MM-dd')
    final Map<String, List<FoodEntry>> grouped = {};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.date, () => []).add(entry);
    }

    // 2. Sort dates in descending order (newest date first)
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food History'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: entries.isEmpty
                ? const EmptyState(
                    icon: Icons.history,
                    title: 'No history yet',
                    message: 'Your past meals and daily calorie summaries will appear here once you start logging.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateString = sortedDates[index];
                      final dayEntries = grouped[dateString] ?? [];
                      final parsedDate = AppDateUtils.parseIsoDate(dateString);

                      // Calculate total calories for this specific date
                      final int dayTotal = dayEntries.fold(0, (sum, item) => sum + item.calories);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date Header Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18.0,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        AppDateUtils.formatDisplayDate(parsedDate),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      '$dayTotal kcal',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimaryContainer,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              const Divider(),
                              const SizedBox(height: 4.0),

                              // List of food items for this date
                              ...dayEntries.map(
                                (entry) => FoodListItem(
                                  key: ValueKey(entry.id),
                                  entry: entry,
                                  showDate: false,
                                  onDelete: () => onDeleteFood(entry.id),
                                ),
                              ),

                              const SizedBox(height: 8.0),
                              // Button to jump to this date on Dashboard
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => onSelectDate(parsedDate),
                                  icon: const Icon(Icons.dashboard_outlined, size: 16.0),
                                  label: const Text('View on Dashboard'),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
