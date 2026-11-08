# 🥗 Healthy Food Calorie Logger

A clean, responsive, and privacy-focused daily calorie tracking and meal logging application built with **Flutter** and **Material 3**. Designed for individuals who want an intuitive, zero-friction way to monitor their daily nutrition budget, cultivate mindful eating habits, and achieve wellness goals across desktop, tablet, and mobile devices.

---

## 📌 Table of Contents

- [About the Application](#-about-the-application)
- [Why Healthy Food Calorie Logger?](#-why-healthy-food-calorie-logger)
- [Key Features](#-key-features)
- [Screen-by-Screen Overview](#-screen-by-screen-overview)
- [Calorie Calculations & Logic](#-calorie-calculations--logic)
- [Responsive Layout Architecture](#-responsive-layout-architecture)
- [Project Architecture & Directory Structure](#-project-architecture--directory-structure)
- [Data Flow & State Management](#-data-flow--state-management)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Running Automated Tests](#-running-automated-tests)
- [License](#-license)

---

## 📖 About the Application

**Healthy Food Calorie Logger** is an offline-first nutrition companion that simplifies calorie management. Rather than burdening users with complex nutrition databases, invasive ads, or mandatory account creation, the app provides a straightforward, health-oriented interface where you can:

1. **Set a personalized daily calorie goal** tailored to your fitness objectives (weight maintenance, deficit, or surplus).
2. **Quickly log meals** across standard meal types (Breakfast, Lunch, Snacks, Dinner) with their calorie counts.
3. **Visualize your daily intake progress** in real-time through clear metric cards and progress indicators.
4. **Browse past eating history** grouped chronologically by date to spot trends in your dietary habits.
5. **Navigate effortlessly** on any screen size — from mobile smartphones to widescreen desktop monitors.

---

## 💡 Why Healthy Food Calorie Logger?

Many commercial calorie tracking applications suffer from common pain points:
- **Feature bloat & paywalls**: Unnecessary social feeds, barcode scanner paywalls, and intrusive subscription popups.
- **Privacy concerns**: Daily personal eating data is often synced to external servers and monetized.
- **Mobile-only layouts**: When opened on desktop browsers or tablets, apps appear as awkward, stretched mobile views.

**Healthy Food Calorie Logger solves these challenges:**
- **100% Private & Offline**: All meal data and target goals remain stored locally on your device via `shared_preferences`.
- **Zero Friction**: Open the app and log a meal in under 5 seconds with built-in validation.
- **Tailored Responsive Design**: Automatically transforms into a balanced two-column dashboard on desktop ($\ge 900\,\text{px}$) while remaining touch-optimized on mobile.
- **Calming Visual Language**: Uses a natural green-and-white Material 3 palette (`#2E7D32`, `#1B3D1F`, `#F9FBF8`) that encourages positive dietary mindfulness.

---

## ✨ Key Features

### 1. Welcoming Dashboard & Motivational Guidance
- Greets users with an inspiring *"Welcome Back!"* header and a wellness subtitle encouraging mindful nourishment.
- Instant overview of the current date's nutritional intake.

### 2. High-Clarity Calorie Summary Card
- **Three Prominent Metric Tiles**:
  - **Consumed**: Displays total calories eaten today, accented in vibrant green (or warning orange if over target).
  - **Goal**: Current daily target (e.g., $2000\,\text{kcal}$), with a one-tap *Edit Goal* button.
  - **Remaining**: Real-time remaining calorie allowance ($0$ when reached or exceeded).
- **Daily Progress Bar**: Smooth linear progress bar accompanied by an exact percentage indicator (e.g., `65%`).
- **Dynamic Motivational Status Banner**:
  - *On Track*: Shows remaining kcal needed to reach your goal.
  - *Goal Reached*: Displays a celebratory balance badge when target is met.
  - *Over Goal*: Highlights excess calories with a warning icon to help guide adjustments for the next meal.

### 3. Streamlined Meal Logging
- Add meals with:
  - **Food Name** (with title capitalization)
  - **Calorie Count** (validated between $1$ and $5000\,\text{kcal}$ per meal)
  - **Meal Category** (Breakfast, Lunch, Snacks, Dinner)
  - **Log Date** (defaults to selected dashboard date; blocks future dates)
- Visual feedback via floating snackbar notifications upon successful additions.

### 4. Refined Meal Cards
- Distinct icon and color tint for each meal category:
  - 🌅 **Breakfast**: Morning sun icon (`Icons.wb_sunny_rounded`) in warm amber.
  - 🥪 **Lunch**: Dining icon (`Icons.lunch_dining_rounded`) in rich gold.
  - 🍎 **Snacks**: Healthy apple icon (`Icons.apple_rounded`) in violet.
  - 🍽️ **Dinner**: Dinner plate icon (`Icons.dinner_dining_rounded`) in deep indigo.
- Pill badge for meal type and calorie counter badge (`350 kcal`).
- Safety confirmation modal before deleting any food entry to prevent accidental data loss.

### 5. Date Navigation & Calendar Integration
- Seamless previous/next day chevron navigation.
- Next day button automatically disables when viewing today to prevent future date navigation.
- Tap the date chip to open an interactive DatePicker calendar modal.

### 6. Food History Screen
- Displays all historical meals organized into daily summary cards (newest date first).
- Shows total calories consumed for each historical day.
- Includes a **"View on Dashboard"** button on each card to immediately switch the dashboard view to that date.

---

## 🖥️ Screen-by-Screen Overview

```
┌────────────────────────────────────────────────────────┐
│                   Main Navigation                      │
├───────────────────────────┬────────────────────────────┤
│       Dashboard Tab       │        History Tab         │
│  • Welcome Heading        │  • Chronological Log       │
│  • Date Navigation Card   │  • Grouped by Day          │
│  • Calorie Summary Card   │  • Day Total Calorie Badge │
│  • Logged Meals List      │  • Jump to Dashboard       │
│  • Floating "Add Food"    │                            │
└───────────────────────────┴────────────────────────────┘
```

### 1. Dashboard Screen (`HomeScreen`)
The central hub of the app. It calculates all daily totals based on the currently selected date.
- **Desktop View**: Uses an expansive $1080\,\text{px}$ container with a 2-column layout. The left column holds the Date Navigator and Calorie Summary card; the right column lists all logged meals with item counts and total calorie sums.
- **Mobile/Tablet View**: Vertically stacks the header, date navigator, summary card, and meal list in a scrollable view.
- **Empty State**: When no meals are logged for the active day, an interactive `EmptyState` widget encourages the user to log their first meal.

### 2. Add Food Screen (`AddFoodScreen`)
A focused modal form that captures meal information:
- Form validation guarantees valid food names and positive whole-number calories.
- Date picker restricts entries to on or before today.
- Generates a unique microsecond-based ID for each entry.

### 3. Food History Screen (`HistoryScreen`)
Provides long-term visibility into eating patterns:
- Groups entries using ISO date strings (`yyyy-MM-dd`).
- Sums daily calories and sorts days descending.
- Allows deleting older entries directly or jumping to that day's dashboard.

---

## 🔢 Calorie Calculations & Logic

The application follows precise business calculations to prevent division errors and ensure accurate budget display:

$$\text{Safe Goal} = \begin{cases} \text{Goal}, & \text{if } \text{Goal} > 0 \\ 1, & \text{otherwise} \end{cases}$$

$$\text{Total Consumed} = \sum_{i=1}^{n} \text{Calories}_i \quad (\text{for all entries matching selected date})$$

$$\text{Remaining Calories} = \max(0, \text{Goal} - \text{Total Consumed})$$

$$\text{Progress Ratio} = \min\left(1.0, \, \max\left(0.0, \, \frac{\text{Total Consumed}}{\text{Safe Goal}}\right)\right)$$

$$\text{Status Mode} = \begin{cases} \text{Over Target}, & \text{if } \text{Total Consumed} > \text{Goal} \\ \text{Goal Met}, & \text{if } \text{Total Consumed} = \text{Goal} \text{ and } \text{Goal} > 0 \\ \text{In Progress}, & \text{otherwise} \end{cases}$$

---

## 📐 Responsive Layout Architecture

The application dynamically detects available viewport dimensions using `LayoutBuilder`:

| Breakpoint | Target Devices | Max Width | Layout Structure |
| :--- | :--- | :--- | :--- |
| **Desktop ($\ge 900\,\text{px}$)** | Desktops, Laptops, Ultrawide screens | $1080\,\text{px}$ | **2-Column Split**: Left (Date + Summary), Right (Meal List) |
| **Tablet ($600 - 899\,\text{px}$)** | iPads, Android tablets, Foldables | $720\,\text{px}$ | **Centered Single Column** with spacious horizontal margins |
| **Mobile ($< 600\,\text{px}$)** | Smartphones (iOS / Android) | Full width ($16\,\text{px}$ pad) | **Single Column** touch-optimized vertical scroll |

---

## 🏗️ Project Architecture & Directory Structure

The project follows clean separation of concerns without external over-engineering:

```
lib/
├── main.dart                  # Application entry point, Material 3 theme & MainNavigationScreen
├── models/
│   └── food_entry.dart        # Immutable FoodEntry data model with JSON serialization (toMap/fromMap)
├── screens/
│   ├── add_food_screen.dart   # Input form for logging meals with validation & date picker
│   ├── history_screen.dart    # Historical daily meal groups, daily totals & jump navigation
│   └── home_screen.dart       # Responsive dashboard (LayoutBuilder 2-column desktop / 1-column mobile)
├── services/
│   └── storage_service.dart   # Offline storage service wrapping SharedPreferences
├── utils/
│   └── date_utils.dart        # Date formatting (ISO 8601 & display dates), same-day comparison
└── widgets/
    ├── empty_state.dart       # Reusable friendly empty state widget with action button
    ├── food_list_item.dart    # Polished meal item card with category squircle icons & delete dialog
    └── summary_card.dart      # Visual hierarchy calorie card with 3 metric tiles & progress indicator
```

---

## 🔄 Data Flow & State Management

```
┌─────────────────────────────────────────────────────────────┐
│                    MainNavigationScreen                     │
│  State: _entries (List<FoodEntry>), _dailyGoal, _selectedDate│
└──────────────┬───────────────────────────────┬──────────────┘
               │                               │
               ▼                               ▼
       ┌───────────────┐               ┌───────────────┐
       │  HomeScreen   │               │ HistoryScreen │
       └───────┬───────┘               └───────┬───────┘
               │                               │
       ┌───────┴───────┐               ┌───────┴───────┐
       ▼               ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│SummaryCard  │ │FoodListItem │ │Summary Group│ │FoodListItem │
└─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
               ▲
               │ Persisted via
       ┌───────┴────────┐
       │ StorageService │  ──▶  SharedPreferences (JSON)
       └────────────────┘
```

1. **State Ownership**: `MainNavigationScreen` acts as the single source of truth for the list of `FoodEntry` items, the selected date, and the daily calorie goal.
2. **Persistence**: Every mutation (`addFoodEntry`, `deleteFoodEntry`, `saveDailyGoal`) immediately invokes `StorageService`, which encodes entries as a JSON string in device storage.
3. **Reactive Re-renders**: Once storage completes, local widget state triggers UI updates smoothly across the dashboard and history tabs.

---

## 🧰 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Channel stable, Dart SDK `^3.7.2`)
- **UI & Components**: Material 3 (`ThemeData(useMaterial3: true)`)
- **Storage**: [`shared_preferences ^2.5.3`](https://pub.dev/packages/shared_preferences)
- **Icons**: Material Icons (`Icons.*`) & Cupertino Icons (`CupertinoIcons.*`)
- **Testing**: `flutter_test` (Automated unit and widget test suite)

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.7 or higher)
- [Git](https://git-scm.com/) installed
- Target platform environment: Google Chrome (Web), Windows build tools (Desktop), or Android Studio / Xcode (Mobile)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/siddupakkurthi/HealthyFoodCalorieLogger.git
   cd HealthyFoodCalorieLogger
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify environment**:
   ```bash
   flutter doctor
   ```

### Running the App

- **On Google Chrome (Web)**:
  ```bash
  flutter run -d chrome
  ```
- **On Windows (Desktop)**:
  ```bash
  flutter run -d windows
  ```
- **On Connected Mobile Device / Emulator**:
  ```bash
  flutter run
  ```

### Building for Production

- **Web Release Build**:
  ```bash
  flutter build web
  ```
  The compiled web bundle will be generated in `build/web/`.

- **Windows Desktop Release Build**:
  ```bash
  flutter build windows
  ```

- **Android APK Release Build**:
  ```bash
  flutter build apk --release
  ```

---

## 🧪 Running Automated Tests

The application includes unit tests and widget tests covering date utilities, data models, persistence logic, user interaction flows, and responsive layouts across desktop, tablet, and mobile:

```bash
# 1. Run static code analysis (0 issues / lints)
flutter analyze

# 2. Run all unit and widget tests
flutter test
```

### What the Test Suite Verifies

- **Unit Tests (`test/unit_test.dart`)**:
  - `AppDateUtils`: Correct ISO 8601 formatting (`yyyy-MM-dd`), safe date parsing, relative formatting (`Today`, `Yesterday`, `MMM d, y`), and same-day calendar validation.
  - `FoodEntry`: Map serialization and deserialization, including resilience against corrupt or missing JSON payloads.
  - `StorageService`: Default fallback daily goal ($2000\,\text{kcal}$), goal mutation persistence, JSON corruption recovery, and atomic meal addition/deletion.
- **Widget Tests (`test/widget_test.dart`)**:
  - Initial dashboard render, welcome header validation, and bottom navigation bar tab switching.
  - Full end-to-end user flow: tapping *Add Food*, filling in meal details, submitting form, verifying dashboard summary updates, triggering deletion confirmation modal, and removing the item.
  - Goal editing dialog flow: updating target calories and verifying immediate dashboard synchronization.
  - Responsive layout assertions verifying proper rendering on Desktop ($1280 \times 800$), Tablet ($768 \times 1024$), and Mobile ($390 \times 844$) screen dimensions without layout overflows.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE) — feel free to use, customize, and extend it for your own personal or educational health tracking projects.
