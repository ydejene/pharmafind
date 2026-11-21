# PharmaFind 🏥💊

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

## 📑 Table of Contents

- [Overview & Healthcare Impact](#overview--healthcare-impact)
- [Key Features](#key-features)
- [Architectural Blueprint](#architectural-blueprint)
- [State Management Matrix](#state-management-matrix)
- [Database Schema & Security Architecture](#database-schema--security-architecture)
- [Codebase Structure](#codebase-structure)
- [Getting Started & Setup Guide](#getting-started--setup-guide)
  - [Prerequisites](#prerequisites)
  - [Installation & Execution](#installation--execution)
  - [Firebase Configuration](#firebase-configuration)
- [Testing Strategy & Quality Assurance](#testing-strategy--quality-assurance)
- [Platform Support](#platform-support)
- [Team Members & Task Allocation](#team-members--task-allocation)
- [License](#license)

---

## 🌍 Overview & Healthcare Impact

In urban communities across Sub-Saharan Africa, finding prescribed medications is often an arduous, fragmented ordeal. Patients frequently navigate physical fatigue and emotional distress, travelling from pharmacy to pharmacy across Kigali only to find critical prescription items out of stock.

**PharmaFind** bridges this vital healthcare accessibility gap:
- **Centralizes Pharmacy Information:** Surfaces verified community pharmacies in Kigali (Kimironko, Nyarutarama, Remera, Kicukiro, Kiyovu, etc.).
- **Real-Time Inventory Transparency:** Allows patients to verify real-time medication availability, stock levels, packaging types, and transparent pricing in Rwandan Francs (RWF).
- **Direct Geolocation & Navigation:** Provides GPS routing directly from the user's live position to the dispensing pharmacy.
- **Support for Sustainable Development Goals (SDG 3):** Promotes Good Health and Well-Being by shortening the critical window between clinical diagnosis and medication intake.

---

## ✨ Key Features

### 🔍 1. Granular Medicine Discovery & Search
- **Sub-Second Search Pipeline:** Instant prefix queries powered by `SearchCubit` with normalized lowercase indexing (`medicineNameLower`).
- **Comprehensive Stock Status:** Badges indicate *In Stock* (with pack quantities), *Low Stock*, or *Out of Stock*.
- **Price Transparency:** Real-time unit pricing formatted in RWF.
- **Stock Reconfirmation:** Community-driven stock validation allowing users to confirm inventory on-site with a single tap.

### 📍 2. Interactive Map & Live GPS Directions
- **OpenStreetMap & FlutterMap Integration:** Zero proprietary API key lock-in, rendering vector-tiled mapping with smooth pan and pinch-to-zoom.
- **Dynamic Camera-Fit Bounds:** Mathematical auto-framing algorithm (`_fitMapToMarkers`) that dynamically calculates `LatLngBounds` between user GPS and pharmacy coordinates, with custom asymmetrical padding for UI overlays.
- **External Maps Intent:** Native integration launching Google Maps or Apple Maps app directions via `geo:` and `https://www.google.com/maps/dir/` URI protocols.
- **Direct Telephony Integration:** One-tap calling to pharmacy dispensaries via `tel:` URLs.

### 🔔 3. Medicine Availability Alerts
- **Notification Requests:** Users can create custom availability alerts when a prescription medicine is currently unavailable or out of stock in their district.
- **Persistent Firestore Storage:** Monitored alerts stored in the `/alerts` collection, tied directly to the user's account for automated inventory notification triggers.

### 🏪 4. Pharmacy Partner Management Portal
- **Role-Based Authentication:** Dedicated partner experience for licensed pharmacy owners.
- **Verification Workflow:** Multi-stage lifecycle tracking for pharmacy onboarding (`pending`, `approved`, `rejected`) with license number validation.
- **Stock Inventory CRUD:** Real-time management interface to add new medicines, update quantities and prices, toggle stock status, and remove discontinued medications.
- **Live Inventory Synchronization:** Reactive stream subscriptions via `WatchPharmacyStockUseCase` with automatic leak-free disposal.

### 🔐 5. Dual Authentication & Role Partitioning
- **Flexible Access:** Guest browsing enabled out-of-the-box; users can search medicines without mandatory login.
- **Email & Password Authentication:** Client-side validation with real-time password strength evaluation (regex-based tracking length, numbers, casing, and symbols).
- **Google OAuth Integration:** Seamless single-tap sign-in via `GoogleSignIn` and Firebase Authentication.
- **Secure Password Reset:** Automated self-service email dispatch for forgotten passwords.

### 🌐 6. Trilingual Clinical Localization
- **Native Language Switching:** Immediate switching across **English**, **Kinyarwanda** (*Murakaza neza*), and **French** (*Bienvenue*) without application reload.
- **Clinical Terminology:** Accurate local translations for dosage forms, insurance co-pays, dispensary hours, and stock states.

### 🛡️ 7. Medical Insurance Provider Profiles
- **Insurance Scheme Selection:** Support for major Rwandan insurance partners including **RSSB Medical Scheme (RAMA)**, **Britam**, **Eden Care**, **Radiant**, and **MMI**.
- **Member Policy Management:** Secure storage of insurance policy IDs to expedite in-person dispensary billing.

---

## 🏛️ Architectural Blueprint

PharmaFind is engineered strictly following **Clean Architecture** principles, enforcing separation of concerns, high testability, and framework independence.

```
                  ┌────────────────────────────────────────┐
                  │           Presentation Layer           │
                  │  (Screens, Widgets, BLoCs & Cubits)    │
                  └───────────────────┬────────────────────┘
                                      │ depends on
                                      ▼
                  ┌────────────────────────────────────────┐
                  │              Domain Layer              │
                  │ (Entities, Use Cases, Repos Contracts) │
                  └───────────────────▲────────────────────┘
                                      │ implements
                                      │
                  ┌───────────────────┴────────────────────┐
                  │               Data Layer               │
                  │ (Models, Repositories, Remote & Local) │
                  └────────────────────────────────────────┘
```

1. **Domain Layer (Pure Dart):**
   - Independent of Flutter, Firebase, or any third-party framework.
   - Contains pure business models (`UserEntity`, `PharmacyEntity`, `StockItemEntity`, `AlertEntity`, `SettingsEntity`).
   - Declares granular, single-responsibility use cases (`SearchMedicineUseCase`, `GetPharmacyStockUseCase`, `SignInWithEmailUseCase`, `CreateAlertUseCase`, etc.).
   - Specifies abstract repository interfaces (`IAuthRepository`, `IPharmacyRepository`, `IAlertRepository`, `ISettingsRepository`).

2. **Data Layer:**
   - Implements domain repository contracts (`AuthRepositoryImpl`, `PharmacyRepositoryImpl`, `AlertRepositoryImpl`, `SettingsRepositoryImpl`).
   - Serializes data via Models (`UserModel`, `PharmacyModel`, `StockItemModel`, `AlertModel`) with explicit `toEntity()` and `fromEntity()` transformations.
   - Integrates remote datasources (`FirebaseAuthDataSource`, `FirestorePharmacyDataSource`, `FirestoreAlertDataSource`) and local persistence (`SharedPreferencesSettingsDataSource`, `MockPharmacyDataSource`, `MockAuthDataSource`).

3. **Presentation Layer:**
   - Driven by `flutter_bloc` (BLoC and Cubit pattern).
   - UI widgets observe immutable states emitted by Cubits/BLoCs via `BlocBuilder`, `BlocConsumer`, and `BlocListener`.
   - UI widgets do not perform direct I/O, business validation, or direct database calls.

---

## ⚙️ State Management Matrix

| BLoC / Cubit | Scope & Role | Input Triggers | Emitted States |
| :--- | :--- | :--- | :--- |
| **`AuthBloc`** | Global Authentication lifecycle | `AuthCheckRequested`, `AuthLoginRequested`, `AuthRegisterRequested`, `AuthGoogleSignInRequested`, `AuthLogoutRequested` | `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthUnauthenticated`, `AuthError`, `AuthPasswordResetSent` |
| **`SearchCubit`** | Medicine query & pharmacy selection | `searchMedicine(query)`, `selectResult(stockItem)`, `clearSearch()` | `SearchState` (`initial`, `loading`, `loaded`, `error`, query string, results list, selectedItem) |
| **`PharmacyCubit`** | Partner pharmacy profile & stock CRUD | `loadPharmacy(ownerId)`, `createPharmacy()`, `addStockItem()`, `updateStockItem()`, `deleteStockItem()`, `subscribeToStock()` | `PharmacyState` (`initial`, `loading`, `loaded`, `error`, pharmacy entity, stockItems list) |
| **`AlertCubit`** | Availability alert creation & management | `createAlert(userId, medicine, area)`, `reset()` | `AlertState` (`initial`, `loading`, `saved`, `error`, errorMessage) |
| **`SettingsCubit`** | Theme, localization & preference cache | `setLocale(code)`, `setDarkMode(bool)`, `setStockAlerts(bool)`, `setAppUpdates(bool)`, `markOnboardingSeen()` | `SettingsState` (locale: `en`/`rw`/`fr`, isDarkMode, stockAlerts, appUpdates, hasSeenOnboarding) |

---

## 🗄️ Database Schema & Security Architecture

PharmaFind uses Google Cloud Firestore organized into normalized top-level collections optimized for fast querying and granular security rules:

```
cloud_firestore
├── users/{userId}
│   ├── uid: string (PK)
│   ├── email: string
│   ├── displayName: string
│   ├── role: "patient" | "partner" | "admin"
│   ├── phone: string
│   ├── insuranceProvider: string
│   ├── insuranceId: string
│   └── createdAt: timestamp
│
├── pharmacies/{pharmacyId}
│   ├── id: string (PK)
│   ├── ownerId: string (FK -> users.uid)
│   ├── name: string
│   ├── licenseNumber: string
│   ├── area: string
│   ├── district: string
│   ├── phone: string
│   ├── hours: string
│   ├── latitude: number
│   ├── longitude: number
│   ├── status: "pending" | "approved" | "rejected"
│   ├── acceptsInsurance: boolean
│   └── createdAt: timestamp
│
├── stock/{stockId}
│   ├── id: string (PK)
│   ├── pharmacyId: string (FK -> pharmacies.id)
│   ├── medicineName: string
│   ├── medicineNameLower: string (prefix-search indexed)
│   ├── status: "in_stock" | "low_stock" | "out_of_stock"
│   ├── quantity: number
│   ├── price: number (RWF)
│   └── updatedAt: timestamp
│
└── alerts/{alertId}
    ├── id: string (PK)
    ├── userId: string (FK -> users.uid)
    ├── medicineName: string
    ├── searchArea: string
    ├── isActive: boolean
    └── createdAt: timestamp
```

### 🛡️ Firestore Security Rules Highlights (`firestore.rules`)
- **Public Read for Discovery:** Unauthenticated guest users can freely browse approved pharmacies and medicine stock.
- **Strict Role-Based Access Control (RBAC):** Only registered users with verified partner accounts can create pharmacy profiles.
- **Cross-Document Attribute Validation:** To modify or delete an item in `/stock/{stockId}`, Firestore rules execute cross-document validation to guarantee that the requesting user's UID matches the `ownerId` of the referenced parent pharmacy document:
  ```javascript
  match /stock/{stockId} {
    allow read: if true;
    allow create: if signedIn()
      && (isAdmin() || get(/databases/$(database)/documents/pharmacies/$(request.resource.data.pharmacyId)).data.ownerId == request.auth.uid);
    allow update, delete: if signedIn()
      && (isAdmin() || get(/databases/$(database)/documents/pharmacies/$(resource.data.pharmacyId)).data.ownerId == request.auth.uid);
  }
  ```
- **Self-Isolated User Profiles & Alerts:** Users can only view, edit, or delete their own profile data and alert requests (`request.auth.uid == userId`).

---

## 📂 Codebase Structure

```
lib/
├── core/                                # Shared cross-cutting foundations
│   ├── constants/                       # AppColors, AppStrings (trilingual), AuthRoutes
│   ├── theme/                           # Light and Dark ThemeData definitions
│   └── utils/                           # Validators, phone formatters, input matchers
├── data/                                # Data layer implementation
│   ├── datasources/                     # Firebase Auth, Firestore, local SharedPreferences
│   ├── models/                          # Data models with fromMap/toMap/fromEntity/toEntity
│   └── repositories/                    # Repository implementations
├── domain/                              # Pure business layer (zero framework dependencies)
│   ├── entities/                        # Pure domain entities (Immutable Equatable objects)
│   ├── repositories/                    # Abstract repository contracts
│   └── usecases/                        # Single-responsibility use cases
│       ├── alert/                       # Alert persistence use cases
│       ├── auth/                        # Registration, login, Google OAuth, reset use cases
│       ├── pharmacy/                    # Pharmacy search, stock streaming, stock CRUD use cases
│       └── settings/                    # Preferences, localization, onboarding use cases
├── presentation/                        # UI and state management
│   ├── bloc/                            # BLoCs & Cubits (auth, search, pharmacy, alert, settings)
│   ├── screens/                         # Feature screens
│   │   ├── home/                        # HomeScreen, SearchResultsScreen, AvailabilityAlertScreen
│   │   ├── onboarding/                  # LanguageScreen, LoginScreen, RegisterScreen, ForgotPassword
│   │   ├── partner/                     # Dashboard, Stock CRUD, Signup, Verification screens
│   │   ├── pharmacy/                    # PharmacyDetailScreen, DirectionsScreen (Map & Route)
│   │   ├── profile/                     # ProfileScreen, EditProfileScreen
│   │   ├── settings/                    # SettingsScreen
│   │   └── splash/                      # SplashScreen
│   ├── utils/                           # AuthNavigation, Snackbar helpers
│   └── widgets/                         # Reusable custom UI components (PharmaFindLogo, PharmacyCard, etc.)
├── app.dart                             # MaterialApp setup, dynamic theme mode & onGenerateRoute
├── firebase_options.dart                # Generated Firebase configuration
└── main.dart                            # Application entry point with MultiBlocProvider injection
```

---

## 🚀 Getting Started & Setup Guide

### Prerequisites
- **Flutter SDK:** Version `3.29.0` or higher (stable channel).
- **Dart SDK:** Version `3.7.0` or higher (bundled with Flutter).
- **IDE:** Android Studio (with Flutter plugin) or VS Code (with Flutter & Dart extensions).
- **Platform Toolchains:**
  - **Android:** Android Studio with Android SDK API Level 26+ and Java 17+.
  - **iOS:** macOS with Xcode 16+ and CocoaPods / Swift Package Manager.
  - **Web:** Google Chrome browser.

---

### Installation & Execution

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
   - **On Android Emulator / Physical Device:**
     ```bash
     flutter run -d android
     ```
   - **On iOS Simulator:**
     ```bash
     flutter run -d ios
     ```
   - **On Google Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```
   - **On macOS Desktop:**
     ```bash
     flutter run -d macos
     ```

---

### Firebase Configuration

The project connects to the Firebase project `pharmafind-6e48a`:
- **Android:** Handled via `android/app/google-services.json` and the Google Services Gradle plugin.
- **iOS:** Handled via `ios/Runner/GoogleService-Info.plist` and Swift Package Manager SDK imports.
- **Web & Desktop:** Initialized via `lib/firebase_options.dart` through `DefaultFirebaseOptions.currentPlatform`.

To deploy Firestore security rules:
```bash
firebase deploy --only firestore:rules
```

---

## 🧪 Testing Strategy & Quality Assurance

PharmaFind enforces rigorous software verification with **188 automated tests** passing at a **100% success rate**.

```bash
flutter test
```

### Test Coverage Hierarchy:
- **Unit Tests (`test/unit/`):**
  - Validation logic (`Validators.validateEmail`, `validatePassword`, `RwandaPhoneValidator`).
  - String localization completeness across English, Kinyarwanda, and French (`app_strings_test.dart`).
  - Pure domain entity immutability and equality (`Equatable` props).
  - Data model serialization (`toMap`, `fromMap`, `toEntity`, `fromEntity`).
  - BLoC & Cubit state transitions using mock data sources (`auth_bloc_test.dart`, `pharmacy_cubit_test.dart`, `search_cubit_test.dart`).
- **Widget Tests (`test/widget/`):**
  - UI component rendering and interaction (`AuthTextField`, `AuthSubmitButton`, `PasswordStrengthIndicator`, `PharmaFindLogo`, `PharmacyCard`).
  - Screen rendering and validation behavior (`ProfileScreen`, `EditProfileScreen`, `PartnerSignupScreen`, `PartnerStockScreen`).
- **Integration & Flow Tests (`test/presentation/`):**
  - Complete authentication and onboarding user journey (`auth_flow_test.dart`): Language selection $\rightarrow$ Onboarding $\rightarrow$ Login $\rightarrow$ Registration $\rightarrow$ Password Reset $\rightarrow$ Guest bypass to Home.
  - Test provider isolation harness (`test/helpers/test_providers.dart`) injecting mock repositories to ensure isolated, reproducible test runs.

---

## 📱 Platform Support

| Platform | Support Status | Minimum OS Target | Tested Environment |
| :--- | :--- | :--- | :--- |
| **Android** | Fully Supported | Android 8.0 (API Level 26) | Pixel 8 AVD (API 35), Physical Galaxy S21 |
| **iOS** | Fully Supported | iOS 14.0+ | iPhone 17 Pro Simulator (iOS 26.5), iPhone 15 Pro |
| **Web** | Fully Supported | Modern Evergreen Browsers | Google Chrome 158.0+, Safari 17+ |
| **macOS** | Supported | macOS 12.0+ (Monterey) | macOS 15.0+ Sequoia (darwin-x64 / arm64) |

---

## 👥 Team Members & Task Allocation

PharmaFind was developed collaboratively as a summative mobile application project:

| Member | Role | Key Module Responsibilities |
| :--- | :--- | :--- |
| **Jeferson Nkem** | **Team Leader** | Project Architecture, Dual Authentication & Onboarding flows (Email/Password & Google OAuth), Language selection, Core Navigation & Layout Optimization |
| **Yonas Dejene** | **Team Member** | Pharmacy Partner Management, License submission & Verification flow, Partner Dashboard, Stock CRUD operations |
| **Helen Okereke** | **Team Member** | User Account & Profile Management, Medical Insurance Provider preferences, Medicine Availability Alerts (`/notify`), Notification architecture |
| **Tumba II Kongolo** | **Team Member** | Medicine Discovery & Prefix Search (`SearchCubit`), Pharmacy Details Screen, OpenStreetMap & GPS Directions Screen (`flutter_map`, `geolocator`) |

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.
