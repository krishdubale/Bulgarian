# Bulgarian Learning App 🇧🇬

A comprehensive Flutter mobile application for learning the Bulgarian language from absolute beginner (A1) to advanced mastery (C2).

## Features

- **Alphabet Trainer** — All 30 Cyrillic letters with pronunciation guides, example words, and quiz mode
- **Vocabulary Trainer** — Animated flashcard system with spaced repetition (SRS) across 9 categories (110+ words)
- **Grammar Lessons** — 7 structured topics (A1–B1) with examples and multiple-choice quizzes
- **Pronunciation Trainer** — Phonetic guides for every letter and word
- **Listening Practice** — 3 authentic dialogues with comprehension quizzes
- **Speaking Practice** — 15 phrases with level filter and context hints
- **Reading Practice** — 3 texts (A1–B1) with translation toggle and comprehension quizzes
- **Writing Practice** — Translation and fill-in-the-blank exercises with instant feedback
- **Progress Analytics** — XP chart, streak, words learned, level roadmap
- **Settings** — Dark mode toggle, daily XP goal selector

## Gamification

- 🔥 Daily streak system (auto-updated on login)
- ⭐ XP points: 10/lesson · 5/word · 15/quiz
- 📈 Level progression: A1 → A2 → B1 → B2 → C1 → C2
- 🏆 All progress persisted offline via SharedPreferences

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Material 3) |
| State Management | Riverpod 2.x |
| Navigation | go_router (StatefulShellRoute) |
| Local Storage | SharedPreferences (offline-first) |
| Charts | fl_chart |
| Fonts | Google Fonts (Noto Sans – Cyrillic support) |
| Architecture | Clean Architecture, feature-based modules |

## Project Structure

```
lib/
├── main.dart                    # Entry point (ProviderScope + SharedPrefs init)
├── app.dart                     # MaterialApp.router + dark/light theme
├── core/
│   ├── constants/               # AppConstants, BulgarianData (all lesson content)
│   ├── providers/               # SharedPreferencesProvider
│   ├── router/                  # GoRouter with bottom navigation shell
│   ├── theme/                   # Light and dark Material 3 themes
│   └── widgets/                 # Shared UI components
├── data/
│   ├── models/                  # Word, Lesson, UserProgress, Exercise
│   └── repositories/            # ProgressRepository (CRUD) + UserProgressNotifier
└── features/
    ├── home/                    # Dashboard: streak, XP, level cards, module grid
    ├── alphabet/                # 30 Cyrillic letters grid + quiz mode
    ├── vocabulary/              # Flashcards with SRS (9 categories)
    ├── grammar/                 # 7 topics with expandable explanations + quizzes
    ├── pronunciation/           # Phonetic letter guide
    ├── listening/               # Dialogues with comprehension quiz
    ├── speaking/                # Phrase practice with level filter
    ├── reading/                 # Reading texts with translation + quiz
    ├── writing/                 # Translation and fill-in-the-blank
    ├── progress/                # Analytics (bar charts, level roadmap)
    └── settings/                # Dark mode, daily goal

assets/
└── data/
    └── course_blueprint.json    # Shared A1–B1 curriculum architecture (36 units, 288 lessons)
```

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0

### Installation

```bash
flutter pub get
flutter run
```

### Firebase Setup

This app uses Firebase Authentication and Cloud Firestore for account-based login and progress storage.

1. Create a Firebase project.
2. Enable Email/Password sign-in in Firebase Authentication.
3. Create a Cloud Firestore database.
4. Run `flutterfire configure` from the project root.
5. Add the generated platform config files before running the app.

Without Firebase configuration, authentication and per-account progress sync will fail at runtime.

### Running Tests

```bash
flutter test
```

## Engineering Workflow Gates

Run this quality gate locally for each prompt-sized change:

```bash
bash tool/validate_prompt.sh
```

Baseline command contract:

```bash
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter test test/widget_test.dart
```

Execution governance and stage ordering are defined in:

- `docs/execution_playbook.md`
- `.github/pull_request_template.md`
- `.github/workflows/ci.yml`

## Future Enhancements

- [ ] Bulgarian TTS audio integration (`flutter_tts`)
- [ ] Speech recognition for pronunciation scoring
- [ ] AI conversation partner (GPT-based)
- [ ] Cloud sync and user accounts
- [ ] Teacher mode and community practice
- [ ] Multiplayer vocabulary games
- [ ] Content marketplace
