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

- [Overview and Healthcare Impact](#overview-and-healthcare-impact)
- [Key Features](#key-features)
  - [1. Granular Medicine Discovery and Search](#1-granular-medicine-discovery-and-search)
  - [2. Interactive Map and Live GPS Directions](#2-interactive-map-and-live-gps-directions)
  - [3. Medicine Availability Alerts](#3-medicine-availability-alerts)
  - [4. Pharmacy Partner Management Portal](#4-pharmacy-partner-management-portal)
  - [5. Dual Authentication and Role Partitioning](#5-dual-authentication-and-role-partitioning)
  - [6. Trilingual Clinical Localization](#6-trilingual-clinical-localization)
  - [7. Medical Insurance Provider Profiles](#7-medical-insurance-provider-profiles)
- [Architectural Blueprint](#architectural-blueprint)
- [State Management Matrix](#state-management-matrix)
- [Database Schema and Security Architecture](#database-schema-and-security-architecture)
  - [Firestore Collections Schema](#firestore-collections-schema)
  - [Firestore Security Rules and Access Control](#firestore-security-rules-and-access-control)
- [Codebase Structure](#codebase-structure)
- [Getting Started and Setup Guide](#getting-started-and-setup-guide)
  - [Prerequisites](#prerequisites)
  - [Installation and Execution](#installation-and-execution)
  - [Firebase Configuration](#firebase-configuration)
- [Testing Strategy and Quality Assurance](#testing-strategy-and-quality-assurance)
  - [Test Coverage Breakdown](#test-coverage-breakdown)
- [Platform Support](#platform-support)
- [Team Members and Task Allocation](#team-members-and-task-allocation)
- [License](#license)

---

## Overview and Healthcare Impact

In urban communities across Sub-Saharan Africa, accessing prescribed medications often represents an arduous, fragmented ordeal. Patients frequently experience physical fatigue and emotional distress traveling from pharmacy to pharmacy across Kigali, only to find critical prescription items out of stock.

**PharmaFind** bridges this vital healthcare accessibility gap:

- **Centralized Pharmacy Directory:** Surfaces verified community pharmacies across Kigali districts (Kimironko, Nyarutarama, Remera, Kicukiro, Kiyovu, and adjacent areas).
- **Real-Time Inventory Transparency:** Enables patients to check live medication availability, packaging quantities, and verified pricing in Rwandan Francs (RWF).
- **Integrated Geolocation and Routing:** Provides GPS routing directly from the user's current coordinates to the dispensing pharmacy.
- **Alignment with UN Sustainable Development Goals (SDG 3):** Advances Good Health and Well-Being by shortening the critical window between clinical diagnosis and treatment commencement.

---

## Key Features

### 1. Granular Medicine Discovery and Search
- **Sub-Second Search Pipeline:** Instant prefix queries managed by `SearchCubit` with normalized lowercase indexing (`medicineNameLower`).
- **Stock Status Indicators:** Distinct badges indicate whether items are *In Stock* (including available pack counts), *Low Stock*, or *Out of Stock*.
- **Price Transparency:** Live unit prices formatted clearly in RWF.
- **Stock Reconfirmation:** Community-driven stock validation allowing users to confirm inventory on-site with a single tap.

### 2. Interactive Map and Live GPS Directions
- **OpenStreetMap and FlutterMap Integration:** Free, vector-tiled mapping with smooth pan, zoom, and orientation without proprietary map API lock-in.
- **Dynamic Camera Bounds Algorithm:** Mathematical auto-framing (`_fitMapToMarkers`) calculating `LatLngBounds` between user GPS and pharmacy coordinates, with custom asymmetrical padding for bottom sheets and navigation bars.
- **External Maps Intent:** Native integration launching Google Maps or Apple Maps app directions through `geo:` and `https://www.google.com/maps/dir/` URI protocols.
- **Telephony Action:** Instant dialer invocation to pharmacy dispensaries via `tel:` URLs.

### 3. Medicine Availability Alerts
- **Notification Requests:** Users can submit availability alerts when a prescription medicine is currently unavailable or out of stock in their district.
- **Persistent Storage:** Alerts are recorded in Cloud Firestore under `/alerts` and tied to user profiles for automated notification triggers upon inventory restocking.

### 4. Pharmacy Partner Management Portal
- **Role-Based Experience:** Dedicated interface tailored specifically for licensed pharmacy owners.
- **Verification Workflow:** Multi-stage lifecycle tracking for pharmacy onboarding (`pending`, `approved`, `rejected`) with license number validation.
- **Stock Inventory CRUD:** Full management interface to add new medications, update quantities and prices, adjust stock status, and remove discontinued items.
- **Reactive Inventory Streams:** Live inventory synchronization via `WatchPharmacyStockUseCase` with automatic lifecycle subscription cancellation upon teardown.

### 5. Dual Authentication and Role Partitioning
- **Guest Access:** Guest browsing enabled out-of-the-box, allowing users to search medicines without mandatory login.
- **Email and Password Authentication:** Client-side validation with real-time password strength evaluation across length, numbers, casing, and symbols.
- **Google OAuth Integration:** Single-tap sign-in via `GoogleSignIn` and Firebase Authentication.
- **Password Recovery:** Automated self-service email dispatch for forgotten passwords.

### 6. Trilingual Clinical Localization
- **Instant Language Switching:** Seamless reactive switching across **English**, **Kinyarwanda** (*Murakaza neza*), and **French** (*Bienvenue*) without application restarts.
- **Clinical Terminology:** Accurate local translations for dosage forms, insurance co-pays, dispensary hours, and stock states.

### 7. Medical Insurance Provider Profiles
- **Insurance Scheme Selection:** Integrated support for major Rwandan health insurance providers, including **RSSB Medical Scheme (RAMA)**, **Britam**, **Eden Care**, **Radiant**, and **MMI**.
- **Member Policy Management:** Secure storage of policy numbers to expedite in-person dispensary billing.

---

## Architectural Blueprint

PharmaFind is engineered strictly following **Clean Architecture** principles, enforcing separation of concerns, high testability, and framework independence.

```
                  +----------------------------------------+
                  |           Presentation Layer           |
                  |  (Screens, Widgets, BLoCs & Cubits)    |
                  +-------------------T--------------------+
                                      | depends on
                                      v
                  +----------------------------------------+
                  |              Domain Layer              |
                  | (Entities, Use Cases, Repos Contracts) |
                  +-------------------^--------------------+
                                      | implements
                                      |
                  +-------------------T--------------------+
                  |               Data Layer               |
                  | (Models, Repositories, Remote & Local) |
                  +----------------------------------------+
```

### Layer Responsibilities

1. **Domain Layer (Pure Dart):**
   - Independent of Flutter, Firebase, or external packages.
   - Contains immutable domain entities (`UserEntity`, `PharmacyEntity`, `StockItemEntity`, `AlertEntity`, `SettingsEntity`).
   - Declares granular, single-responsibility use cases (`SearchMedicineUseCase`, `GetPharmacyStockUseCase`, `SignInWithEmailUseCase`, `CreateAlertUseCase`, etc.).
   - Defines abstract repository contracts (`IAuthRepository`, `IPharmacyRepository`, `IAlertRepository`, `ISettingsRepository`).

2. **Data Layer:**
   - Implements domain repository contracts (`AuthRepositoryImpl`, `PharmacyRepositoryImpl`, `AlertRepositoryImpl`, `SettingsRepositoryImpl`).
   - Serializes data via models (`UserModel`, `PharmacyModel`, `StockItemModel`, `AlertModel`) with explicit `toEntity()` and `fromEntity()` mappings.
   - Integrates remote datasources (`FirebaseAuthDataSource`, `FirestorePharmacyDataSource`, `FirestoreAlertDataSource`) and local persistence (`SharedPreferencesSettingsDataSource`, `MockPharmacyDataSource`, `MockAuthDataSource`).

3. **Presentation Layer:**
   - Powered by `flutter_bloc` (BLoC and Cubit patterns).
   - UI widgets observe immutable states emitted by Cubits/BLoCs through `BlocBuilder`, `BlocConsumer`, and `BlocListener`.
   - UI components contain zero I/O, business validation, or direct database dependencies.

---

## State Management Matrix

| BLoC / Cubit | Scope and Role | Input Triggers | Emitted States |
| :--- | :--- | :--- | :--- |
| **`AuthBloc`** | Global authentication lifecycle | `AuthCheckRequested`, `AuthLoginRequested`, `AuthRegisterRequested`, `AuthGoogleSignInRequested`, `AuthLogoutRequested` | `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`, `AuthPasswordResetSent` |
| **`SearchCubit`** | Medicine query and pharmacy selection | `searchMedicine(query)`, `selectResult(stockItem)`, `clearSearch()` | `SearchState` (`initial`, `loading`, `loaded`, `error`, query string, results list, selectedItem) |
| **`PharmacyCubit`** | Partner pharmacy profile and stock CRUD | `loadPharmacy(ownerId)`, `createPharmacy()`, `addStockItem()`, `updateStockItem()`, `deleteStockItem()`, `subscribeToStock()` | `PharmacyState` (`initial`, `loading`, `loaded`, `error`, pharmacy entity, stockItems list) |
| **`AlertCubit`** | Availability alert creation and management | `createAlert(userId, medicine, area)`, `reset()` | `AlertState` (`initial`, `loading`, `saved`, `error`, errorMessage) |
| **`SettingsCubit`** | Theme, localization, and preference caching | `setLocale(code)`, `setDarkMode(bool)`, `setStockAlerts(bool)`, `setAppUpdates(bool)`, `markOnboardingSeen()` | `SettingsState` (locale: `en`/`rw`/`fr`, isDarkMode, stockAlerts, appUpdates, hasSeenOnboarding) |

---

## Database Schema and Security Architecture

PharmaFind uses Google Cloud Firestore organized into normalized top-level collections optimized for low-latency queries and granular access control rules.

### Firestore Collections Schema

```
cloud_firestore
|-- users/{userId}
|   |-- uid: string (Primary Key)
|   |-- email: string
|   |-- displayName: string
|   |-- role: "patient" | "partner" | "admin"
|   |-- phone: string
|   |-- insuranceProvider: string
|   |-- insuranceId: string
|   +-- createdAt: timestamp
|
|-- pharmacies/{pharmacyId}
|   |-- id: string (Primary Key)
|   |-- ownerId: string (Foreign Key -> users.uid)
|   |-- name: string
|   |-- licenseNumber: string
|   |-- area: string
|   |-- district: string
|   |-- phone: string
|   |-- hours: string
|   |-- latitude: number
|   |-- longitude: number
|   |-- status: "pending" | "approved" | "rejected"
|   |-- acceptsInsurance: boolean
|   +-- createdAt: timestamp
|
|-- stock/{stockId}
|   |-- id: string (Primary Key)
|   |-- pharmacyId: string (Foreign Key -> pharmacies.id)
|   |-- medicineName: string
|   |-- medicineNameLower: string (prefix search indexed)
|   |-- status: "in_stock" | "low_stock" | "out_of_stock"
|   |-- quantity: number
|   |-- price: number (RWF)
|   +-- updatedAt: timestamp
|
+-- alerts/{alertId}
    |-- id: string (Primary Key)
    |-- userId: string (Foreign Key -> users.uid)
    |-- medicineName: string
    |-- searchArea: string
    |-- isActive: boolean
    +-- createdAt: timestamp
```

### Firestore Security Rules and Access Control

PharmaFind enforces attribute-based and role-based security rules defined in `firestore.rules`:

- **Public Read Access for Medicine Discovery:** Unauthenticated guest users can freely read approved pharmacies and medication stock.
- **Strict Role-Based Registration:** Only authenticated users can register pharmacy documents.
- **Cross-Document Ownership Validation:** Stock item creation, modification, and deletion are gated by cross-document lookups verifying that the requesting user owns the parent pharmacy:
  ```javascript
  match /stock/{stockId} {
    allow read: if true;
    allow create: if signedIn()
      && (isAdmin() || get(/databases/$(database)/documents/pharmacies/$(request.resource.data.pharmacyId)).data.ownerId == request.auth.uid);
    allow update, delete: if signedIn()
      && (isAdmin() || get(/databases/$(database)/documents/pharmacies/$(resource.data.pharmacyId)).data.ownerId == request.auth.uid);
  }
  ```
- **Self-Isolated User Profiles and Alerts:** Profile data and alert documents are readable and editable solely by their respective account owners (`request.auth.uid == userId`).

---

## Codebase Structure

```
lib/
|-- core/                                # Shared cross-cutting foundations
|   |-- constants/                       # AppColors, AppStrings (trilingual), AuthRoutes
|   |-- theme/                           # Light and Dark ThemeData configurations
|   +-- utils/                           # Validators, phone formatters, input matchers
|-- data/                                # Data layer implementation
|   |-- datasources/                     # Firebase Auth, Firestore, local SharedPreferences
|   |-- models/                          # Data models with fromMap/toMap/fromEntity/toEntity
|   +-- repositories/                    # Repository implementations
|-- domain/                              # Pure business layer (zero framework dependencies)
|   |-- entities/                        # Pure domain entities (Immutable Equatable objects)
|   |-- repositories/                    # Abstract repository contracts
|   +-- usecases/                        # Single-responsibility use cases
|       |-- alert/                       # Alert persistence use cases
|       |-- auth/                        # Registration, login, Google OAuth, reset use cases
|       |-- pharmacy/                    # Pharmacy search, stock streaming, stock CRUD use cases
|       +-- settings/                    # Preferences, localization, onboarding use cases
|-- presentation/                        # UI and state management
|   |-- bloc/                            # BLoCs & Cubits (auth, search, pharmacy, alert, settings)
|   |-- screens/                         # Feature screens
|   |   |-- home/                        # HomeScreen, SearchResultsScreen, AvailabilityAlertScreen
|   |   |-- onboarding/                  # LanguageScreen, LoginScreen, RegisterScreen, ForgotPassword
|   |   |-- partner/                     # Dashboard, Stock CRUD, Signup, Verification screens
|   |   |-- pharmacy/                    # PharmacyDetailScreen, DirectionsScreen (Map & Route)
|   |   |-- profile/                     # ProfileScreen, EditProfileScreen
|   |   |-- settings/                    # SettingsScreen
|   |   +-- splash/                      # SplashScreen
|   |-- utils/                           # AuthNavigation, Snackbar helpers
|   +-- widgets/                         # Reusable custom UI components (PharmaFindLogo, PharmacyCard, etc.)
|-- app.dart                             # MaterialApp setup, dynamic theme mode & onGenerateRoute
|-- firebase_options.dart                # Generated Firebase configuration
+-- main.dart                            # Application entry point with MultiBlocProvider injection
```

---

## Getting Started and Setup Guide

### Prerequisites
- **Flutter SDK:** Version `3.29.0` or higher (stable channel).
- **Dart SDK:** Version `3.7.0` or higher (bundled with Flutter).
- **IDE:** Android Studio (with Flutter plugin) or Visual Studio Code (with Flutter and Dart extensions).
- **Platform Toolchains:**
  - **Android:** Android Studio with Android SDK API Level 26+ and Java 17+.
  - **iOS:** macOS with Xcode 16+ and Swift Package Manager.
  - **Web:** Google Chrome browser.

---

### Installation and Execution

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ydejene/pharmafind.git
   cd pharmafind
   ```

2. **Verify toolchain readiness:**
   ```bash
   flutter doctor -v
   ```

3. **Install project dependencies:**
   ```bash
   flutter pub get
   ```

4. **Verify static analysis:**
   ```bash
   flutter analyze
   ```

5. **Run the automated test suite:**
   ```bash
   flutter test
   ```

6. **Launch the application:**
   - **Android Emulator / Physical Device:**
     ```bash
     flutter run -d android
     ```
   - **iOS Simulator:**
     ```bash
     flutter run -d ios
     ```
   - **Web (Google Chrome):**
     ```bash
     flutter run -d chrome
     ```
   - **macOS Desktop:**
     ```bash
     flutter run -d macos
     ```

---

### Firebase Configuration

The application is configured for the Firebase project `pharmafind-6e48a`:
- **Android:** Handled by `android/app/google-services.json` and the Google Services Gradle plugin.
- **iOS:** Handled by `ios/Runner/GoogleService-Info.plist` and Swift Package Manager SDK imports.
- **Web and Desktop:** Initialized through `lib/firebase_options.dart` via `DefaultFirebaseOptions.currentPlatform`.

To deploy Firestore security rules:
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
firebase deploy --only firestore:rules
```

---

## Testing Strategy and Quality Assurance

PharmaFind enforces rigorous software verification with **188 automated tests** passing at a **100% success rate**.

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
