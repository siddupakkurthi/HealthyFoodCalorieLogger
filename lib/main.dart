import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/food_entry.dart';
import 'screens/add_food_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'utils/date_utils.dart';

void main() {
  // Ensure Flutter engine bindings are initialized before calling SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalorieLoggerApp());
}

/// Root application widget configuring Material 3 theme and typography.
class CalorieLoggerApp extends StatelessWidget {
  const CalorieLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF2E7D32); // Health & nutrition green

    return MaterialApp(
      title: 'Healthy Food Calorie Logger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FBF8),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFF9FBF8),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3D1F),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: seedColor, width: 2.0),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

/// Main container widget managing persistent state via StorageService.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final StorageService _storageService = StorageService();

  int _currentTabIndex = 0;
  int _dailyGoal = StorageService.defaultDailyGoal;
  late DateTime _selectedDate;
  List<FoodEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadStoredData();
  }

  /// Loads saved calorie goal and logged meals from local storage.
  Future<void> _loadStoredData() async {
    final goal = await _storageService.loadDailyGoal();
    final entries = await _storageService.loadFoodEntries();

    if (mounted) {
      setState(() {
        _dailyGoal = goal;
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  /// Opens the AddFoodScreen and persists the new entry to local storage.
  Future<void> _navigateToAddFood() async {
    final FoodEntry? newEntry = await Navigator.of(context).push<FoodEntry>(
      MaterialPageRoute(
        builder: (context) => AddFoodScreen(initialDate: _selectedDate),
      ),
    );

    if (newEntry != null) {
      final updatedList = await _storageService.addFoodEntry(_entries, newEntry);
      final entryDate = AppDateUtils.parseIsoDate(newEntry.date);

      if (mounted) {
        setState(() {
          _entries = updatedList;
          // Synchronize the dashboard date with the newly added meal's date
          _selectedDate = entryDate;
        });
      }
    }
  }

  /// Deletes a food entry by ID from state and local storage.
  Future<void> _deleteFood(String id) async {
    FoodEntry? targetEntry;
    try {
      targetEntry = _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      targetEntry = null;
    }

    final updatedList = await _storageService.deleteFoodEntry(_entries, id);

    if (mounted) {
      setState(() {
        _entries = updatedList;
      });

      if (targetEntry != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${targetEntry.name}" (${targetEntry.calories} kcal)'),
            backgroundColor: Colors.grey.shade800,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Dialog allowing the user to update their daily calorie target.
  Future<void> _showEditGoalDialog() async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: _dailyGoal.toString());

    final int? newGoal = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.flag_outlined, color: Color(0xFF2E7D32)),
              SizedBox(width: 8.0),
              Text('Set Daily Goal'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter target daily calorie intake in kcal (500 - 10,000):',
                  style: TextStyle(fontSize: 13.0, color: Colors.black87),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Target Calories',
                    suffixText: 'kcal',
                    prefixIcon: Icon(Icons.local_fire_department),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a goal';
                    }
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null) {
                      return 'Must be a whole number';
                    }
                    if (parsed < 500 || parsed > 10000) {
                      return 'Must be between 500 and 10,000 kcal';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final parsed = int.parse(controller.text.trim());
                  Navigator.of(dialogContext).pop(parsed);
                }
              },
              child: const Text('Save Goal'),
            ),
          ],
        );
      },
    );

    if (newGoal != null && newGoal != _dailyGoal) {
      await _storageService.saveDailyGoal(newGoal);
      if (mounted) {
        setState(() {
          _dailyGoal = newGoal;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily goal updated to $newGoal kcal!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
        ),
      );
    }

    final List<Widget> pages = [
      HomeScreen(
        selectedDate: _selectedDate,
        entries: _entries,
        dailyGoal: _dailyGoal,
        onDateChanged: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
        onAddFood: _navigateToAddFood,
        onDeleteFood: _deleteFood,
        onEditGoal: _showEditGoalDialog,
      ),
      HistoryScreen(
        entries: _entries,
        onDeleteFood: _deleteFood,
        onSelectDate: (targetDate) {
          setState(() {
            _selectedDate = targetDate;
            _currentTabIndex = 0; // Jump to Dashboard tab
          });
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTabIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
