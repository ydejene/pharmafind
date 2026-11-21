# PharmaFind

> **Medicine nearby. Peace of mind.**  
> A production-grade, cross-platform Flutter application addressing prescription access, pharmacy discovery, and medicine availability across Kigali and Rwanda.

[![Flutter](https://img.shields.io/badge/Flutter-3.29.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![State Management](https://img.shields.io/badge/State%20Management-BLoC%20%2F%20Cubit-blueviolet)](https://bloclibrary.dev)
[![Tests](https://img.shields.io/badge/Tests-188%20Passed%20(100%25)-success)](https://github.com/ydejene/pharmafind)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS-lightgrey)](#platform-support)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-brightgreen)](#architectural-blueprint)

---

## Table of Contents

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
```bash
firebase deploy --only firestore:rules
```

---

## Testing Strategy and Quality Assurance

PharmaFind enforces rigorous software verification with **188 automated tests** passing at a **100% success rate**.

```bash
flutter test
```

### Test Coverage Breakdown

- **Unit Tests (`test/unit/`):**
  - Input validation algorithms (`Validators.validateEmail`, `validatePassword`, `RwandaPhoneValidator`).
  - Trilingual localization completeness across English, Kinyarwanda, and French (`app_strings_test.dart`).
  - Pure domain entity immutability and equality (`Equatable` props).
  - Data model serialization (`toMap`, `fromMap`, `toEntity`, `fromEntity`).
  - BLoC and Cubit state transitions using mock data sources (`auth_bloc_test.dart`, `pharmacy_cubit_test.dart`, `search_cubit_test.dart`).
- **Widget Tests (`test/widget/`):**
  - UI component rendering and interaction (`AuthTextField`, `AuthSubmitButton`, `PasswordStrengthIndicator`, `PharmaFindLogo`, `PharmacyCard`).
  - Form validation states and screen transitions (`ProfileScreen`, `EditProfileScreen`, `PartnerSignupScreen`, `PartnerStockScreen`).
- **Integration and Flow Tests (`test/presentation/`):**
  - End-to-end authentication and onboarding user journey (`auth_flow_test.dart`): Language selection to Onboarding to Login to Registration to Password Reset to Guest bypass.
  - Test provider isolation harness (`test/helpers/test_providers.dart`) injecting mock repositories for consistent, isolated test runs.

---

## Platform Support

| Platform | Support Status | Minimum OS Target | Tested Environment |
| :--- | :--- | :--- | :--- |
| **Android** | Fully Supported | Android 8.0 (API Level 26) | Pixel 8 AVD (API 35), Physical Galaxy S21 |
| **iOS** | Fully Supported | iOS 14.0+ | iPhone 17 Pro Simulator (iOS 26.5), iPhone 15 Pro |
| **Web** | Fully Supported | Modern Evergreen Browsers | Google Chrome 158.0+, Safari 17+ |
| **macOS** | Supported | macOS 12.0+ (Monterey) | macOS 15.0+ Sequoia (darwin-x64 / arm64) |

---

## Team Members and Task Allocation

PharmaFind was developed collaboratively as a summative mobile application development project:

| Member | Role | Key Module Responsibilities |
| :--- | :--- | :--- |
| **Jeferson Nkem** | **Team Leader** | Project Architecture, Dual Authentication & Onboarding flows (Email/Password & Google OAuth), Language selection, Core Navigation & Layout Optimization |
| **Yonas Dejene** | **Team Member** | Pharmacy Partner Management, License submission & Verification flow, Partner Dashboard, Stock CRUD operations |
| **Helen Okereke** | **Team Member** | User Account & Profile Management, Medical Insurance Provider preferences, Medicine Availability Alerts (`/notify`), Notification architecture |
| **Tumba II Kongolo** | **Team Member** | Medicine Discovery & Prefix Search (`SearchCubit`), Pharmacy Details Screen, OpenStreetMap & GPS Directions Screen (`flutter_map`, `geolocator`) |

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
