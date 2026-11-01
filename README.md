# PharmaFind

PharmaFind is a Flutter mobile application that helps users locate prescribed medicines at nearby pharmacies in Rwanda. Users can explore pharmacy locations, check medicine availability, compare prices, and access relevant pharmacy information.

## Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **Backend:** Firebase
- **Database:** Cloud Firestore
- **State Management:** BLoC / Cubit
- **Platforms:** Android and iOS

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- An Android emulator or physical device

### Setup

1. Clone the repository.
2. Open the project directory.
3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

Firebase configuration instructions will be added when the Firebase integration is established.

## Project Structure

The application follows clean architecture principles, separating core application foundations, data access, business logic, and presentation:

```
lib/
├── core/                  # Shared foundations and cross-cutting concerns
│   ├── constants/         # AppColors, AppStrings (localization: en, rw, fr)
│   ├── theme/             # Light and Dark theme configurations
│   └── utils/             # Input validation utilities
├── domain/                # Pure business logic and contracts (no Flutter/Firebase dependencies)
│   ├── entities/          # Pure domain models (UserEntity, PharmacyEntity, etc.)
│   ├── repositories/      # Abstract repository interfaces (IAuthRepository, ISettingsRepository, etc.)
│   └── usecases/          # Granular use cases for Auth and Settings operations
├── data/                  # Data access, persistence, and external service adapters
│   ├── datasources/       # Physical data sources (MockAuthDataSource, SharedPreferencesSettingsDataSource)
│   ├── models/            # Data models with explicit toEntity()/fromEntity() and JSON/Map mapping
│   └── repositories/      # Repository implementations connecting use cases to datasources
└── presentation/          # User interface and state management
    ├── bloc/              # BLoC / Cubit state management (AuthBloc, SettingsCubit)
    ├── screens/           # Application screens (SplashScreen, foundation routing placeholders)
    └── widgets/           # Shared, reusable UI components (PharmaFindLogo)
```

## Running Tests & Static Analysis

Run static code analysis:

```bash
flutter analyze
```

Execute the unit and widget test suite:

```bash
flutter test
```

## Contribution Guidelines

- Work on a dedicated feature branch created from the agreed development branch.
- Keep changes focused on the assigned task.
- Follow the established project architecture and coding conventions:
  - Domain entities must remain pure and free from framework/data dependencies.
  - Data models must provide explicit bidirectional mapping with domain entities.
  - BLoCs and Cubits should depend on domain use cases rather than concrete data sources.
- Test changes before requesting integration (`flutter analyze` and `flutter test`).
- Use descriptive commit messages.
- Coordinate changes involving shared models, services, routing, and application configuration with the team.

## Development Status

- **Shared Foundation (Completed):**
  - Project structure and clean architecture layers established.
  - Core domain entities, repository contracts, and use cases.
  - Data models with explicit entity mapping and serialization.
  - Mock authentication data source, repository, use cases, and `AuthBloc`.
  - Settings pipeline with `SharedPreferencesSettingsDataSource`, repository, use cases, and `SettingsCubit`.
  - Application entry (`main.dart`), theme switching, and splash screen with route stubs (`/login`, `/language`).
  - Unit and widget test suite covering models, settings, authentication, and UI branding.
- **Next Stage:** Feature development (authentication screens, pharmacy listing, medicine search, and Firebase integration).