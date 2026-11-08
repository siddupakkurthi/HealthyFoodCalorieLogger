import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_food_calorie_logger/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Provide clean initial mock values
    SharedPreferences.setMockInitialValues({
      'daily_goal': 2000,
      'food_entries': '[]',
    });
  });

  testWidgets('Healthy Calorie Logger initial render and navigation test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const CalorieLoggerApp());
    await tester.pumpAndSettle();

    expect(find.text('Healthy Calorie Logger'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Daily Summary'), findsOneWidget);

    // Initial goal is 2000, consumed is 0, remaining is 2000 (2 instances)
    expect(find.text('2000'), findsNWidgets(2));
    expect(find.text('No meals logged yet'), findsOneWidget);

    // Navigation test to History and back
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Food History'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Healthy Calorie Logger'), findsOneWidget);
  });

  testWidgets('Full User Flow: Add Food, Update Summary, and Delete Food', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const CalorieLoggerApp());
    await tester.pumpAndSettle();

    // 1. Tap the Add Food button
    await tester.tap(find.text('Add Food'));
    await tester.pumpAndSettle();

    // Verify Add Food Screen is open
    expect(find.text('Add Food Entry'), findsOneWidget);

    // 2. Fill in the form fields
    final foodNameField = find.widgetWithText(TextFormField, 'Food Name');
    final caloriesField = find.widgetWithText(TextFormField, 'Calories (kcal)');

    await tester.enterText(foodNameField, 'Oatmeal & Almonds');
    await tester.enterText(caloriesField, '350');

    // 3. Save the food entry
    await tester.tap(find.text('Save Food Entry'));
    await tester.pumpAndSettle();

    // Verify returning to Dashboard
    expect(find.text('Healthy Calorie Logger'), findsOneWidget);
    expect(find.text('Oatmeal & Almonds'), findsOneWidget);
    expect(find.text('350 kcal'), findsOneWidget);

    // Check consumed is now 350 and remaining is 2000 - 350 = 1650
    expect(find.text('350'), findsOneWidget); // Consumed
    expect(find.text('1650'), findsOneWidget); // Remaining

    // Wait for the SnackBar duration so it disappears cleanly
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 4. Test Deletion with Confirmation Dialog
    final deleteIcon = find.byIcon(Icons.delete_outline);
    expect(deleteIcon, findsOneWidget);
    await tester.ensureVisible(deleteIcon);
    await tester.tap(deleteIcon);
    await tester.pumpAndSettle();

    // Verify confirmation dialog showed
    expect(find.text('Delete Food Entry'), findsOneWidget);

    // Tap Delete button in the confirmation dialog
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    // Verify item is removed and empty state returns
    expect(find.text('Oatmeal & Almonds'), findsNothing);
    expect(find.text('No meals logged yet'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // Consumed back to 0
    expect(find.text('2000'), findsNWidgets(2)); // Goal & Remaining are 2000
  });

  testWidgets('Edit Calorie Goal Flow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const CalorieLoggerApp());
    await tester.pumpAndSettle();

    // Tap Edit Goal button
    await tester.tap(find.text('Edit Goal'));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('Set Daily Goal'), findsOneWidget);

    // Enter a new goal of 2500
    final targetField = find.widgetWithText(TextFormField, 'Target Calories');
    await tester.enterText(targetField, '2500');

    // Tap Save Goal
    await tester.tap(find.widgetWithText(FilledButton, 'Save Goal'));
    await tester.pumpAndSettle();

    // Verify the goal is updated on the dashboard
    expect(find.text('2500'), findsNWidgets(2)); // Goal and Remaining are 2500
  });

  testWidgets('Responsive Dashboard Desktop Layout Test', (WidgetTester tester) async {
    // Test on desktop resolution (1280x800)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const CalorieLoggerApp());
    await tester.pumpAndSettle();

    // Verify welcoming header and motivational subtitle
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(
      find.text('Track your meals mindfully to nourish your body and reach your wellness goals.'),
      findsOneWidget,
    );

    // Verify summary card and empty state on desktop layout
    expect(find.text('Daily Summary'), findsOneWidget);
    expect(find.text('No meals logged yet'), findsOneWidget);
    expect(find.text('Add Food'), findsOneWidget);
  });

  testWidgets('Responsive Dashboard Mobile and Tablet Layout Test', (WidgetTester tester) async {
    // 1. Mobile screen (390 x 844)
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const CalorieLoggerApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Daily Summary'), findsOneWidget);
    expect(find.text('No meals logged yet'), findsOneWidget);

    // 2. Tablet screen (768 x 1024)
    tester.view.physicalSize = const Size(768, 1024);
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Daily Summary'), findsOneWidget);
    expect(find.text('No meals logged yet'), findsOneWidget);

    tester.view.resetPhysicalSize();
  });
}
