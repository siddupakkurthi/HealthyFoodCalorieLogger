import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';

/// Service responsible for managing all local persistence using SharedPreferences.
/// Keeps storage logic separated from UI screens.
class StorageService {
  static const String _entriesKey = 'food_entries';
  static const String _goalKey = 'daily_goal';
  static const int defaultDailyGoal = 2000;

  /// Loads the saved daily calorie goal. Defaults to 2000 kcal if not set.
  Future<int> loadDailyGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_goalKey) ?? defaultDailyGoal;
    } catch (_) {
      // In case of any read error, return safe default
      return defaultDailyGoal;
    }
  }

  /// Saves the daily calorie goal to SharedPreferences.
  Future<bool> saveDailyGoal(int goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(_goalKey, goal);
    } catch (_) {
      return false;
    }
  }

  /// Loads all stored food entries.
  /// Handles missing keys or corrupted JSON gracefully by returning an empty list.
  Future<List<FoodEntry>> loadFoodEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_entriesKey);

      if (jsonString == null || jsonString.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => FoodEntry.fromMap(item))
            .toList();
      }
      return [];
    } catch (e) {
      // Corrupted JSON or parsing exception: fallback to empty list safely
      return [];
    }
  }

  /// Serializes and writes the entire list of food entries to SharedPreferences.
  Future<bool> saveFoodEntries(List<FoodEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMaps = entries.map((e) => e.toMap()).toList();
      final String jsonString = jsonEncode(listMaps);
      return await prefs.setString(_entriesKey, jsonString);
    } catch (_) {
      return false;
    }
  }

  /// Helper to insert a single food entry and persist it.
  Future<List<FoodEntry>> addFoodEntry(
    List<FoodEntry> currentEntries,
    FoodEntry newEntry,
  ) async {
    final updatedList = [newEntry, ...currentEntries];
    await saveFoodEntries(updatedList);
    return updatedList;
  }

  /// Helper to remove an entry by its unique ID and persist the change.
  Future<List<FoodEntry>> deleteFoodEntry(
    List<FoodEntry> currentEntries,
    String id,
  ) async {
    final updatedList = currentEntries.where((entry) => entry.id != id).toList();
    await saveFoodEntries(updatedList);
    return updatedList;
  }
}
