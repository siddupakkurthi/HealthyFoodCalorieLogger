/// Represents an individual food entry logged by the user.
class FoodEntry {
  final String id;
  final String name;
  final int calories;
  final String mealType;
  final String date; // Standardized ISO format: 'yyyy-MM-dd'

  const FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.mealType,
    required this.date,
  });

  /// Converts a FoodEntry instance into a Map for JSON serialization.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'mealType': mealType,
      'date': date,
    };
  }

  /// Creates a FoodEntry instance from a Map (deserialization).
  /// Provides safe fallbacks to prevent crashes if data is missing or malformed.
  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed Food',
      calories: (map['calories'] is num) ? (map['calories'] as num).toInt() : 0,
      mealType: map['mealType']?.toString() ?? 'Snacks',
      date: map['date']?.toString() ?? '',
    );
  }

  /// Creates a copy of the entry with specified fields replaced.
  FoodEntry copyWith({
    String? id,
    String? name,
    int? calories,
    String? mealType,
    String? date,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
    );
  }
}
