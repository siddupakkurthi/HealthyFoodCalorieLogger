import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_food_calorie_logger/models/food_entry.dart';
import 'package:healthy_food_calorie_logger/services/storage_service.dart';
import 'package:healthy_food_calorie_logger/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('formatIsoDate formats DateTime correctly', () {
      final date = DateTime(2026, 5, 4);
      expect(AppDateUtils.formatIsoDate(date), '2026-05-04');
    });

    test('parseIsoDate parses valid ISO string correctly', () {
      final parsed = AppDateUtils.parseIsoDate('2026-10-27');
      expect(parsed.year, 2026);
      expect(parsed.month, 10);
      expect(parsed.day, 27);
    });

    test('parseIsoDate returns safe date on invalid input', () {
      final parsed = AppDateUtils.parseIsoDate('invalid-date');
      final now = DateTime.now();
      expect(parsed.year, now.year);
    });

    test('formatDisplayDate correctly handles today and yesterday', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final pastDate = DateTime(2025, 1, 15);

      expect(AppDateUtils.formatDisplayDate(today), 'Today');
      expect(AppDateUtils.formatDisplayDate(yesterday), 'Yesterday');
      expect(AppDateUtils.formatDisplayDate(pastDate), 'Jan 15, 2025');
    });

    test('isSameDay accurately detects identical calendar days', () {
      final a = DateTime(2026, 3, 10, 8, 30);
      final b = DateTime(2026, 3, 10, 22, 15);
      final c = DateTime(2026, 3, 11, 8, 30);

      expect(AppDateUtils.isSameDay(a, b), isTrue);
      expect(AppDateUtils.isSameDay(a, c), isFalse);
    });
  });

  group('FoodEntry Model Tests', () {
    test('toMap and fromMap preserve all values', () {
      const entry = FoodEntry(
        id: '12345',
        name: 'Avocado Toast',
        calories: 280,
        mealType: 'Breakfast',
        date: '2026-10-27',
      );

      final map = entry.toMap();
      final restored = FoodEntry.fromMap(map);

      expect(restored.id, '12345');
      expect(restored.name, 'Avocado Toast');
      expect(restored.calories, 280);
      expect(restored.mealType, 'Breakfast');
      expect(restored.date, '2026-10-27');
    });

    test('fromMap handles missing or corrupt map fields gracefully', () {
      final emptyMap = <String, dynamic>{};
      final fallbackEntry = FoodEntry.fromMap(emptyMap);

      expect(fallbackEntry.id, '');
      expect(fallbackEntry.name, 'Unnamed Food');
      expect(fallbackEntry.calories, 0);
      expect(fallbackEntry.mealType, 'Snacks');
      expect(fallbackEntry.date, '');
    });
  });

  group('StorageService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadDailyGoal returns default 2000 when empty', () async {
      final service = StorageService();
      final goal = await service.loadDailyGoal();
      expect(goal, 2000);
    });

    test('saveDailyGoal persists and retrieves target value', () async {
      final service = StorageService();
      await service.saveDailyGoal(2500);
      final retrieved = await service.loadDailyGoal();
      expect(retrieved, 2500);
    });

    test('loadFoodEntries handles empty storage and corrupt JSON safely', () async {
      final service = StorageService();

      // Empty test
      final emptyList = await service.loadFoodEntries();
      expect(emptyList, isEmpty);

      // Corrupt JSON test
      SharedPreferences.setMockInitialValues({
        'food_entries': '{ corrupted_not_a_json_list }',
      });
      final recoveredList = await service.loadFoodEntries();
      expect(recoveredList, isEmpty);
    });

    test('addFoodEntry and deleteFoodEntry properly update storage', () async {
      final service = StorageService();

      const item1 = FoodEntry(
        id: 'id-1',
        name: 'Apple',
        calories: 95,
        mealType: 'Snacks',
        date: '2026-10-27',
      );
      const item2 = FoodEntry(
        id: 'id-2',
        name: 'Rice & Dal',
        calories: 450,
        mealType: 'Lunch',
        date: '2026-10-27',
      );

      var list = await service.addFoodEntry([], item1);
      list = await service.addFoodEntry(list, item2);
      expect(list.length, 2);

      // Verify persistence by reloading
      final reloaded = await service.loadFoodEntries();
      expect(reloaded.length, 2);

      // Delete item1
      final afterDelete = await service.deleteFoodEntry(reloaded, 'id-1');
      expect(afterDelete.length, 1);
      expect(afterDelete.first.name, 'Rice & Dal');
    });
  });
}
