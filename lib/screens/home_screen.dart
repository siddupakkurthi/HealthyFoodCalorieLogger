import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_list_item.dart';
import '../widgets/summary_card.dart';

/// The primary dashboard screen displaying daily calorie summary,
/// date selector, and the list of food entries for that date.
class HomeScreen extends StatelessWidget {
  final DateTime selectedDate;
  final List<FoodEntry> entries;
  final int dailyGoal;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onAddFood;
  final ValueChanged<String> onDeleteFood;
  final VoidCallback onEditGoal;

  const HomeScreen({
    super.key,
    required this.selectedDate,
    required this.entries,
    required this.dailyGoal,
    required this.onDateChanged,
    required this.onAddFood,
    required this.onDeleteFood,
    required this.onEditGoal,
  });

  /// Navigates one day backward.
  void _goToPreviousDay() {
    onDateChanged(selectedDate.subtract(const Duration(days: 1)));
  }

  /// Navigates one day forward (up to today).
  void _goToNextDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextDay = selectedDate.add(const Duration(days: 1));

    if (!nextDay.isAfter(today)) {
      onDateChanged(nextDay);
    }
  }

  /// Opens the DatePicker dialog when the date chip is tapped.
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(today) ? today : selectedDate,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = AppDateUtils.isSameDay(selectedDate, today);

    // Calculate total calories consumed for the selected date
    final selectedIso = AppDateUtils.formatIsoDate(selectedDate);
    final dailyEntries = entries.where((e) => e.date == selectedIso).toList();
    final int totalConsumed = dailyEntries.fold<int>(0, (sum, item) => sum + item.calories);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthy Calorie Logger'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine responsive screen form factor
            final screenWidth = constraints.maxWidth;
            final isDesktop = screenWidth >= 900;
            final isTablet = screenWidth >= 600 && screenWidth < 900;
            final double contentMaxWidth = isDesktop ? 1080.0 : (isTablet ? 720.0 : 600.0);
            final double horizontalPadding = isDesktop ? 24.0 : 16.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: horizontalPadding,
                    top: 8.0,
                    bottom: 96.0, // Ensures content is never obscured by the FloatingActionButton
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcoming Heading and Short Motivational Subtitle
                      _buildWelcomeHeader(context),
                      const SizedBox(height: 12.0),

                      if (isDesktop)
                        // Desktop Two-Column Responsive Layout
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Date Selector & Calorie Summary Card
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildDateSelector(context, theme, isToday),
                                  const SizedBox(height: 16.0),
                                  SummaryCard(
                                    consumed: totalConsumed,
                                    goal: dailyGoal,
                                    onEditGoal: onEditGoal,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24.0),

                            // Right Column: Logged Meals List / Empty State
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMealsHeader(theme, dailyEntries.length, totalConsumed),
                                  const SizedBox(height: 8.0),
                                  _buildMealsContent(dailyEntries, isToday),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        // Mobile & Tablet Single-Column Layout
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDateSelector(context, theme, isToday),
                            const SizedBox(height: 12.0),
                            SummaryCard(
                              consumed: totalConsumed,
                              goal: dailyGoal,
                              onEditGoal: onEditGoal,
                            ),
                            const SizedBox(height: 20.0),
                            _buildMealsHeader(theme, dailyEntries.length, totalConsumed),
                            const SizedBox(height: 8.0),
                            _buildMealsContent(dailyEntries, isToday),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddFood,
        icon: const Icon(Icons.add),
        label: const Text('Add Food'),
      ),
    );
  }

  /// Welcoming heading and short motivational subtitle.
  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  'Welcome Back!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B3D1F),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8.0),
                const Icon(
                  Icons.spa,
                  color: Color(0xFF2E7D32),
                  size: 26.0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Track your meals mindfully to nourish your body and reach your wellness goals.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Date selector navigation bar.
  Widget _buildDateSelector(BuildContext context, ThemeData theme, bool isToday) {
    return Card(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous Day',
              onPressed: _goToPreviousDay,
            ),
            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 18.0,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      AppDateUtils.formatDisplayDate(selectedDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(Icons.arrow_drop_down_rounded, size: 22.0),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Next Day',
              onPressed: isToday ? null : _goToNextDay,
            ),
          ],
        ),
      ),
    );
  }

  /// Header displaying logged meal count and sum of calories.
  Widget _buildMealsHeader(ThemeData theme, int count, int totalConsumed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Logged Meals ($count)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                '$totalConsumed kcal total',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Renders either empty state or list of food entries.
  Widget _buildMealsContent(List<FoodEntry> dailyEntries, bool isToday) {
    if (dailyEntries.isEmpty) {
      return EmptyState(
        icon: Icons.restaurant_outlined,
        title: 'No meals logged yet',
        message: isToday
            ? 'Start your day by tracking breakfast, lunch, or snacks!'
            : 'No food entries were recorded for this day.',
        buttonText: 'Add First Meal',
        onButtonPressed: onAddFood,
      );
    }
    return Column(
      children: dailyEntries
          .map(
            (entry) => FoodListItem(
              key: ValueKey(entry.id),
              entry: entry,
              showDate: false,
              onDelete: () => onDeleteFood(entry.id),
            ),
          )
          .toList(),
    );
  }
}
