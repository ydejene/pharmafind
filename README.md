# PharmaFind

PharmaFind is a Flutter mobile application for locating prescribed medicines at nearby pharmacies in Rwanda.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-^3.13.4-0175C2?logo=dart&logoColor=white)
![State Management](https://img.shields.io/badge/State_Management-Flutter_Bloc_9.1.1-blueviolet)
![Backend](https://img.shields.io/badge/Backend-Firebase_Auth_%26_Firestore-FFA611?logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-green)
![Tests](https://img.shields.io/badge/Tests-248_passed-brightgreen)

---

## Core Features

PharmaFind provides two distinct, role-based workflows:

### Patient Workflow
- **Medicine Search:** Real-time search across registered pharmacies in Kigali using normalized name prefix queries (`medicineNameLower`), displaying current prices, stock availability, and distance.
- **Interactive Map & Directions:** OpenStreetMap rendering via `flutter_map` showing pharmacy location, current device GPS coordinates (`geolocator`), and turn-by-turn route overview.
- **Pharmacy Details & Direct Contact:** View operating hours, district/area, physical address, and initiate direct phone calls or emails via `url_launcher`.
- **Restock Availability Alerts:** Subscribe to medicine availability notifications for out-of-stock items, stored under the `/alerts` Firestore collection.
- **Localization:** Multilingual support for English (`en`), Kinyarwanda (`rw`), and French (`fr`).
- **Theme Customization:** Light and dark mode support with preferences persisted locally via `shared_preferences`.
- **Authentication & Profile:** Email/password registration, login, Google Sign-In, password recovery, and profile editing.

### Pharmacy Partner Workflow
- **Dedicated Partner Onboarding:** Role-based registration (`role: 'partner'`) with automatic onboarding routing.
- **Pharmacy Profile Management:** Create and update pharmacy profiles including pharmacy name, Kigali district/area, operating hours, contact phone, contact email, and GPS coordinates.
- **Document Verification:** Upload Rwanda Ministry of Health (RMOH) pharmacy licenses and business registration certificates through a secure Cloudinary upload pipeline using `file_picker`.
- **Application Lifecycle Tracking:** Status-aware interface reflecting application states (`pending`, `approved`, `rejected`) with administrative review feedback, rejection reasons, and rejected-document resubmission.
- **Approval-Restricted Inventory Management:** Manage pharmacy stock items with full CRUD support (add, edit price/quantity, delete with confirmation dialogs) restricted strictly to approved pharmacy partners and synchronized in real-time through Firestore streams.

---

[![Flutter](https://img.shields.io/badge/Flutter-3.29.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-blueviolet)](https://bloclibrary.dev)
[![Tests](https://img.shields.io/badge/Tests-188%20Passed%20(100%25)-success)](https://github.com/ydejene/pharmafind)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS-lightgrey)](#platform-support)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-brightgreen)](#architectural-blueprint)

- **Framework:** Flutter
- **Language:** Dart (SDK `^3.13.4`)
- **State Management:** Flutter BLoC (`flutter_bloc: ^9.1.1`, `equatable: ^3.0.0`)
- **Backend & Database:** Firebase Authentication (`firebase_auth: ^7.0.1`), Cloud Firestore (`cloud_firestore: ^7.1.0`), and Firebase Core (`firebase_core: ^5.1.0`)
- **Authentication Provider:** Google Sign-In (`google_sign_in: ^7.2.0`)
- **Document Storage:** Cloudinary REST API (`http: ^1.2.2`, `file_picker: ^13.4.1`)
- **Mapping & Geolocation:** `flutter_map: ^8.3.2`, `latlong2: ^0.10.1`, and `geolocator: ^14.1.2`
- **Local Persistence:** `shared_preferences: ^2.5.6`
- **External Communication:** `url_launcher: ^6.3.3` (telephony, mailto, maps)

---

## Architecture

PharmaFind follows Clean Architecture with a strict unidirectional dependency flow across four core layers:

```
Presentation Layer (UI Screens, Reusable Widgets, BLoCs & Cubits)
       ↓ (invokes)
Use Cases (Granular, Single-Responsibility Business Rules)
       ↓ (depends on)
Domain Repository Contracts (Abstract Interfaces)
       ↑ (implements)
Data Repository Implementations (Coordination & Mapping)
       ↓ (calls)
Data Sources (Firebase Auth, Cloud Firestore, Cloudinary API, SharedPreferences)
```

### Layer Responsibilities

1. **Presentation (`lib/presentation/`):**
   - Screens for onboarding, patient search, map directions, pharmacy details, and partner management.
   - State management via `AuthBloc`, `SettingsCubit`, `PharmacyCubit`, `SearchCubit`, and `AlertCubit`.
   - Reusable UI components including the code-drawn `PharmaFindLogo`, authentication forms, and loading overlays.
2. **Domain (`lib/domain/`):**
   - Pure business logic independent of Flutter and external backend SDKs.
   - **Entities:** `UserEntity`, `PharmacyEntity`, `MedicineEntity`, `StockItemEntity`, `AlertEntity`, `SettingsEntity`.
   - **Repository Contracts:** `IAuthRepository`, `IPharmacyRepository`, `IAlertRepository`, `ISettingsRepository`.
   - **Use Cases:** Fine-grained use cases (e.g., `SearchMedicineUseCase`, `GetPharmacyStockUseCase`, `SubmitVerificationDocumentsUseCase`, `AddStockItemUseCase`, `UpdateStockItemUseCase`, `DeleteStockItemUseCase`).
3. **Data (`lib/data/`):**
   - **Data Sources:** Concrete integrations with Firebase Auth, Cloud Firestore (`pharmacies`, `stock`, `alerts`, `users`), Cloudinary HTTP uploads, and `SharedPreferences`.
   - **Models:** DTOs with bidirectional serialization (`toEntity()`, `fromEntity()`, `toMap()`, `fromFirestore()`).
   - **Repository Implementations:** `AuthRepositoryImpl`, `PharmacyRepositoryImpl`, `AlertRepositoryImpl`, `SettingsRepositoryImpl`.
4. **Core (`lib/core/`):**
   - Shared cross-cutting foundations: `AppColors`, `AppStrings` (localization keys), `AppTheme`, `AppConfig`, and input validators.

### Project Structure

```
lib/
├── core/
│   ├── constants/           # AppColors, AppStrings, AppConfig, AuthRoutes
│   ├── theme/               # Light and Dark theme configurations
│   └── utils/               # Form validators and input formatters
├── data/
│   ├── datasources/         # Firebase, Cloudinary, and local data sources (with mocks)
│   ├── models/              # DTO models with bidirectional entity mapping
│   └── repositories/        # Repository implementations
├── domain/
│   ├── entities/            # Pure business entities
│   ├── repositories/        # Abstract repository contracts
│   └── usecases/            # Granular domain use cases
├── presentation/
│   ├── bloc/                # BLoC and Cubit state management
│   ├── mixins/              # Form mixins and helpers
│   ├── screens/             # Patient, partner, onboarding, and profile screens
│   ├── utils/               # Navigation and snackbar presentation helpers
│   └── widgets/             # Reusable widgets and code-rendered branding
├── app.dart                 # Application root with onGenerateRoute routing table
├── firebase_options.dart    # Firebase platform options
└── main.dart                # Entry point, dependency injection, and MultiBlocProvider setup
```

---

## Setup and Running

### Prerequisites

- **Flutter SDK:** Flutter (3.x compatible)
- **Dart SDK:** Included with Flutter (SDK `^3.13.4`)
- **Platform Tools:** Android Studio with Android SDK (API 21+) or VS Code with Flutter extension
- An active Android emulator, physical Android device, or Google Chrome for web testing

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd pharmafind
   ```

2. Install project dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

### Firebase Configuration

Developers must configure the application with their own Firebase project:
- Provide your Firebase project configuration files: `lib/firebase_options.dart` (generated via the FlutterFire CLI), `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist`.
- **Firebase Authentication:**
  - Email/Password sign-in provider enabled.
  - Google Sign-In provider enabled.
- **Cloud Firestore Database Collections:**
  - `users/{uid}`: User accounts with segregated roles (`patient` or `partner`).
  - `pharmacies/{pharmacyId}`: Registered pharmacy profiles with verification states (`pending`, `approved`, `rejected`).
  - `stock/{stockId}`: Pharmacy inventory items with `medicineNameLower` indexing for prefix queries.
  - `alerts/{alertId}`: Restock notification subscriptions.
- **Security Rules:** Deploy rules from `firestore.rules` to enforce role-based access and data integrity.

### Cloudinary Document Upload Configuration

Verification document uploads for pharmacy partners are configured in `lib/core/constants/app_config.dart`. Each developer must configure their own Cloudinary account credentials before testing document uploads:
- **`cloudinaryCloudName`**: Your Cloudinary cloud name.
- **`cloudinaryUploadPreset`**: Your unsigned upload preset configured in Cloudinary.
- **`cloudinaryUploadFolder`**: The target folder for uploaded verification documents (e.g., `pharmafind/partner-verification`).

> [!NOTE]
> For demonstration and evaluation purposes, Cloudinary uploads use an unsigned preset with public delivery. Document URLs are generated through HTTPS multipart uploads without storing or exposing private API secrets. Please use mock test documents (sample images/PDFs, not real personal identification or legal licenses) during evaluation.

---

## Testing & Quality Assurance

Run static code analysis:
```bash
flutter analyze
```

Execute the automated test suite:
```bash
flutter test
```

### Verified Test Results

- **Static Analysis:** Zero issues reported (`No issues found!`).
- **Test Suite:** **248 automated tests passing (100% pass rate)** covering:
  - Domain use cases and repository contracts.
  - Data models, Firestore serialization, and Cloudinary error handling.
  - BLoC and Cubit state transitions (`AuthBloc`, `PharmacyCubit`, `SearchCubit`, `SettingsCubit`, `AlertCubit`).
  - Widget and screen interaction tests for authentication, partner onboarding, profile creation, license upload, and real-time stock management.

---

## Project Information

- **Project:** PharmaFind Mobile Application
- **Course:** Mobile Application Development (Trimester 06 Summative)
- **Institution:** African Leadership University (ALU)
- **Author:** Cohort 2 Group 6 (Copyright (c) 2026)
- **License:** [MIT License](LICENSE)
