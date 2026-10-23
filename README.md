# Sovereign 🏎️

> **The discipline cockpit.** A high-performance personal productivity suite engineered with a Ferrari-inspired design system. Built with Flutter, backed by Supabase.

---

## 🏎️ Overview

**Sovereign** is a cross-platform discipline and execution system built for individuals who take their daily output seriously. Designed with aggressive minimalism, Rosso Corsa accents, and high-contrast typography (Barlow), Sovereign centralizes tasks, habit streaks, deep work intervals, progressive-overload workout tracking, and daily schedule blocks into a single cohesive cockpit.

One codebase targets **iOS, Android, Web, macOS, Windows, and Linux**.

---

## ✨ Features

### 1. 📋 Tasks & Priorities
- Strict priority tiers: **P0 (Urgent/Critical)**, **P1 (High)**, **P2 (Normal)**, **P3 (Backlog)**.
- Category tagging (Deep Work, Health, Operations, Personal).
- Due date filtering and fast completion toggling.
- White-space guarded validation and responsive sheet editor.

### 2. ⚡ Habits & Streaks
- Daily frequency targets and instant check-ins.
- Deterministic streak calculation tracking:
  - **Current streak** (accounts for today or yesterday grace periods).
  - **Best streak record** (all-time highest consistency).
- Reversible check-ins with immediate optimistic UI updates.

### 3. ⏱️ Focus Timer (Deep Work)
- Pomodoro-style interval sessions (25m Focus, 50m Ultra-Focus, custom durations, and rest breaks).
- **Elapsed timestamp tracking**: Preserves exact work duration even if the app process is suspended or backgrounded.
- Session completion logging tied to specific tags/tasks.

### 4. 🏋️ Workouts (Iron Log)
- Structured session logging: Exercises, Set numbers, Weights, Reps, and completion states.
- Strict validation: Blocks empty workout commits or set-less exercise templates.
- Metric unit support: Dynamic toggle between Kilograms (kg) and Pounds (lbs).

### 5. 📅 Daily Planner (Timeline)
- Time-blocked schedule view with 24-hour vertical timeline.
- Color-coded calendar entries with hour-level precision.
- Previous/Next day navigation with direct jumps to today.

### 6. ⚙️ Settings & System
- Dynamic Theme Modes: **Dark (Rosso Corsa & Ink)**, **Light (Rosso & Silver)**, or System Default.
- Persistent state management with instant hot-swapping.
- Supabase Cloud Sync with local offline-first fallback capability.

---

## 🎨 Design System: The Scuderia Palette

| Token | Hex | Role |
| :--- | :--- | :--- |
| **Rosso Corsa** | `#D40000` | Primary brand accent, action buttons, active states |
| **Rosso Pressed** | `#A80000` | Active button tap state |
| **Modena Yellow** | `#FFF200` | Secondary highlights, warnings, streak badges |
| **Ink** | `#181818` | Dark mode background canvas |
| **Surface Dark** | `#202020` | Cards, elevated sheets, modal dialogs |
| **Gray Silver** | `#E5E5E5` | Light mode canvas and secondary text in dark mode |
| **Barlow** | *Font Family* | Clean, athletic, high-contrast typography |

---

## 🛠️ Architecture & Tech Stack

```
lib/
├── app.dart                        # MaterialApp.router configuration & theme listener
├── main.dart                       # Entry point & Supabase bootstrapping
├── core/
│   ├── env/                        # Environment flag readers (dart-define)
│   ├── errors/                     # App-wide exception & failure handlers
│   ├── router/                     # GoRouter routes, redirect guards & shell
│   ├── theme/                      # SovereignColors & SovereignTheme (Light/Dark)
│   └── widgets/                    # Shared buttons, cards, inputs, and indicators
└── features/
    ├── auth/                       # Supabase Auth, magic links, session management
    ├── tasks/                      # Task models, sorting, filtering & Supabase repository
    ├── habits/                     # Habit models, streak engine & check-in providers
    ├── focus/                      # Focus timer state machine, duration tracking
    ├── workouts/                   # Exercise & Set tracking, weight conversions
    ├── planner/                    # Daily schedule timeline & color-coded blocks
    └── settings/                   # SharedPreferences-backed user preferences
```

- **Framework**: [Flutter](https://flutter.dev) (3.x stable)
- **State Management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod`)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Backend / Database**: [Supabase](https://supabase.com) (PostgreSQL + Auth + Row Level Security)
- **Local Persistence**: `shared_preferences`
- **Testing**: `flutter_test`, `mocktail`, strict test-first domain and widget suites.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.3.0`)
- A [Supabase](https://supabase.com) project (free tier works great)

### 1. Database Setup

1. Open your Supabase Project dashboard.
2. Navigate to the **SQL Editor**.
3. Run the schema migration script located at:
   ```
   supabase/migrations/0001_schema.sql
   ```
   This creates tables for `profiles`, `tasks`, `habits`, `habit_checkins`, `focus_sessions`, `workouts`, `workout_sets`, and `planner_entries` with automatic Row Level Security (RLS) policies.

### 2. Clone & Install Dependencies

```bash
git clone https://github.com/zereforuto/Sovereign.git
cd Sovereign/sovereign
flutter pub get
```

### 3. Run the Application

Pass your Supabase credentials using `--dart-define` flags:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

#### Running on Desktop:
```bash
# Windows
flutter run -d windows --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...

# macOS
flutter run -d macos --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

> **Note**: If run without `--dart-define` parameters, Sovereign launches into a friendly Configuration Helper screen with full instructions.

---

## 🧪 Testing

Sovereign is built strictly test-first. Run the entire test suite across all feature domains:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

---

## 🔒 Security & Privacy

- All user data in PostgreSQL is protected by **Row Level Security (RLS)**.
- Users can strictly only read, insert, update, and delete their own rows matching `auth.uid() = user_id`.
- Magic link and passwordless authentication handled natively by Supabase Auth.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
