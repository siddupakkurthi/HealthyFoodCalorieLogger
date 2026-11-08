import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/food_entry.dart';
import '../utils/date_utils.dart';

/// Screen allowing the user to log a new food item with validation.
class AddFoodScreen extends StatefulWidget {
  final DateTime initialDate;

  const AddFoodScreen({
    super.key,
    required this.initialDate,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  String _selectedMealType = 'Breakfast';
  late DateTime _selectedDate;

  final List<String> _mealTypes = const [
    'Breakfast',
    'Lunch',
    'Snacks',
    'Dinner',
  ];

  @override
  void initState() {
    super.initState();
    // Default the date to the date currently active on the dashboard
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  /// Opens the DatePicker dialog, restricting selection to on or before today.
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(today) ? today : _selectedDate,
      firstDate: DateTime(2020),
      lastDate: today, // Block future dates
      helpText: 'Select Food Date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Validates the form and returns the new entry to the caller.
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Generate unique ID using microseconds since epoch
    final String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    final String foodName = _nameController.text.trim();
    final int calories = int.parse(_caloriesController.text.trim());
    final String isoDate = AppDateUtils.formatIsoDate(_selectedDate);

    final newEntry = FoodEntry(
      id: uniqueId,
      name: foodName,
      calories: calories,
      mealType: _selectedMealType,
      date: isoDate,
    );

    // 2. Show success SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "$foodName" ($calories kcal) successfully!'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // 3. Return to previous screen with the new entry
    Navigator.of(context).pop(newEntry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food Entry'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card container for form inputs
                    Card(
                      elevation: 1.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Meal Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16.0),

                            // 1. Food Name Field
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Food Name',
                                hintText: 'e.g. Oatmeal with Almonds',
                                prefixIcon: Icon(Icons.restaurant),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a food name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // 2. Calories Field (digits only)
                            TextFormField(
                              controller: _caloriesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Calories (kcal)',
                                hintText: 'e.g. 350',
                                prefixIcon: Icon(Icons.local_fire_department_outlined),
                                suffixText: 'kcal',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter calorie count';
                                }
                                final parsed = int.tryParse(value.trim());
                                if (parsed == null) {
                                  return 'Please enter a valid whole number';
                                }
                                if (parsed <= 0) {
                                  return 'Calories must be greater than 0';
                                }
                                if (parsed > 5000) {
                                  return 'Calories cannot exceed 5000 kcal per meal';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // 3. Meal Type Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedMealType,
                              decoration: const InputDecoration(
                                labelText: 'Meal Type',
                                prefixIcon: Icon(Icons.category_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                              ),
                              items: _mealTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedMealType = newValue;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16.0),

                            // 4. Date Selection Button
                            InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(12.0),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Log Date',
                                  prefixIcon: Icon(Icons.calendar_today_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${AppDateUtils.formatDisplayDate(_selectedDate)} (${AppDateUtils.formatIsoDate(_selectedDate)})',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const Icon(Icons.edit_calendar, size: 20.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Submit Button
                    FilledButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.check),
                      label: const Text(
                        'Save Food Entry',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
