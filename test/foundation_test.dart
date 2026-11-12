import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharmafind/data/datasources/auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/datasources/shared_preferences_settings_datasource.dart';
import 'package:pharmafind/data/models/stock_item_model.dart';
import 'package:pharmafind/data/models/user_model.dart';
import 'package:pharmafind/data/repositories/auth_repository_impl.dart';
import 'package:pharmafind/data/repositories/settings_repository_impl.dart';
import 'package:pharmafind/domain/entities/stock_item_entity.dart';
import 'package:pharmafind/domain/entities/user_entity.dart';
import 'package:pharmafind/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/register_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/send_password_reset_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_email_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_in_with_google_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/sign_out_usecase.dart';
import 'package:pharmafind/domain/usecases/auth/update_user_profile_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/get_settings_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/mark_onboarding_seen_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_app_updates_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_dark_mode_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_locale_usecase.dart';
import 'package:pharmafind/domain/usecases/settings/set_stock_alerts_usecase.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_bloc.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_event.dart';
import 'package:pharmafind/presentation/bloc/auth/auth_state.dart';
import 'package:pharmafind/presentation/bloc/settings/settings_cubit.dart';
import 'package:pharmafind/presentation/widgets/pharmafind_logo.dart';

class _FailingAuthDataSource implements IAuthDataSource {
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    throw Exception('Invalid email or password');
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String role = 'patient',
  }) async {
    throw Exception('Registration failed');
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    throw Exception('Google sign-in failed');
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    throw Exception('User not found');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Future<void> updateUserProfile(UserModel user) async {
    throw Exception('Failed to update profile');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserModel and StockItemModel - Mapping and Serialization', () {
    test('UserModel bidirectional mapping with UserEntity preserves all fields', () {
      final createdAt = DateTime(2025, 1, 15, 10, 30);
      final entity = UserEntity(
        uid: 'u-123',
        email: 'john@example.com',
        displayName: 'John Doe',
        role: 'patient',
        insuranceProvider: 'RSSB',
        insuranceId: 'INS-9988',
        phone: '+250788111222',
        createdAt: createdAt,
      );

      final model = UserModel.fromEntity(entity);
      expect(model.uid, entity.uid);
      expect(model.email, entity.email);
      expect(model.displayName, entity.displayName);
      expect(model.role, entity.role);
      expect(model.insuranceProvider, entity.insuranceProvider);
      expect(model.insuranceId, entity.insuranceId);
      expect(model.phone, entity.phone);
      expect(model.createdAt, entity.createdAt);

      final mappedBack = model.toEntity();
      expect(mappedBack, equals(entity));
    });

    test('UserModel serialization preserves DateTime and supports fromMap parsing', () {
      final createdAt = DateTime(2025, 2, 1, 12, 0);
      final model = UserModel(
        uid: 'u-456',
        email: 'jane@example.com',
        displayName: 'Jane Doe',
        role: 'partner',
        insuranceProvider: 'MMI',
        insuranceId: 'INS-4455',
        phone: '+250788333444',
        createdAt: createdAt,
      );

      final map = model.toMap();
      expect(map['email'], 'jane@example.com');
      expect(map['displayName'], 'Jane Doe');
      expect(map['role'], 'partner');
      expect(map['insuranceProvider'], 'MMI');
      expect(map['createdAt'], isA<DateTime>());
      expect(map['createdAt'], createdAt);

      // fromMap with DateTime
      final fromDateTimeMap = UserModel.fromMap(map, 'u-456');
      expect(fromDateTimeMap.createdAt, createdAt);
      expect(fromDateTimeMap.isPartner, isTrue);

      // fromMap with ISO String
      final stringDateMap = Map<String, dynamic>.from(map);
      stringDateMap['createdAt'] = createdAt.toIso8601String();
      final fromStringMap = UserModel.fromMap(stringDateMap, 'u-456');
      expect(fromStringMap.createdAt, createdAt);
    });

    test('StockItemModel bidirectional mapping with StockItemEntity preserves int price', () {
      final updatedAt = DateTime(2025, 3, 1, 9, 0);
      final entity = StockItemEntity(
        id: 'stock-100',
        pharmacyId: 'pharm-10',
        pharmacyName: 'Kigali Pharmacy',
        pharmacyArea: 'Nyarugenge',
        pharmacyPhone: '+250788555666',
        pharmacyHours: '24/7',
        pharmacyLat: -1.95,
        pharmacyLng: 30.06,
        medicineName: 'Paracetamol 500mg',
        status: 'in_stock',
        quantity: 50,
        price: 1500,
        updatedAt: updatedAt,
      );

      final model = StockItemModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.price, 1500);
      expect(model.price, isA<int>());
      expect(model.quantity, 50);

      final mappedBack = model.toEntity();
      expect(mappedBack, equals(entity));
    });

    test('StockItemModel serialization and helpers', () {
      final updatedAt = DateTime(2025, 3, 1, 9, 0);
      final model = StockItemModel(
        id: 'stock-200',
        pharmacyId: 'pharm-20',
        pharmacyName: 'Remera Pharmacy',
        medicineName: 'Amoxicillin',
        quantity: 15,
        price: 3500,
        status: 'low_stock',
        updatedAt: updatedAt,
      );

      final map = model.toMap();
      expect(map['price'], 3500);
      expect(map['price'], isA<int>());
      expect(map['updatedAt'], isA<DateTime>());

      final restored = StockItemModel.fromMap(map, 'stock-200');
      expect(restored.price, 3500);
      expect(restored.isLowStock, isTrue);
      expect(restored.formattedPrice, 'RWF 3,500');

      final expensive = StockItemModel(
        id: 'exp',
        pharmacyId: 'p',
        pharmacyName: 'P',
        medicineName: 'M',
        price: 125000,
        updatedAt: DateTime.now(),
      );
      expect(expensive.formattedPrice, 'RWF 125,000');
    });

    test('StockItemModel Equatable comparison checks equality on props', () {
      final now = DateTime.now();
      final item1 = StockItemModel(
        id: 's-1',
        pharmacyId: 'p-1',
        pharmacyName: 'Pharm',
        medicineName: 'Med',
        status: 'in_stock',
        quantity: 10,
        price: 2000,
        updatedAt: now,
      );
      final item2 = StockItemModel(
        id: 's-1',
        pharmacyId: 'p-1',
        pharmacyName: 'Pharm',
        medicineName: 'Med',
        status: 'in_stock',
        quantity: 10,
        price: 2000,
        updatedAt: now,
      );
      expect(item1, equals(item2));
    });
  });

  group('Settings Pipeline - DataSource, Repository, UseCases, and SettingsCubit', () {
    test('Settings pipeline initializes with sensible defaults when SharedPreferences is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = SharedPreferencesSettingsDataSource(prefs: prefs);
      final repository = SettingsRepositoryImpl(localDataSource: dataSource);
      final cubit = SettingsCubit(
        getSettings: GetSettingsUseCase(repository),
        setLocaleUseCase: SetLocaleUseCase(repository),
        setDarkModeUseCase: SetDarkModeUseCase(repository),
        setStockAlertsUseCase: SetStockAlertsUseCase(repository),
        setAppUpdatesUseCase: SetAppUpdatesUseCase(repository),
        markOnboardingSeenUseCase: MarkOnboardingSeenUseCase(repository),
      );

      expect(cubit.state.locale, 'en');
      expect(cubit.state.isDarkMode, isFalse);
      expect(cubit.state.stockAlerts, isTrue);
      expect(cubit.state.appUpdates, isFalse);
      expect(cubit.state.hasSeenOnboarding, isFalse);

      await cubit.close();
    });

    test('Settings pipeline loads existing persisted preferences correctly', () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'rw',
        'isDarkMode': true,
        'stockAlerts': false,
        'appUpdates': true,
        'hasSeenOnboarding': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final dataSource = SharedPreferencesSettingsDataSource(prefs: prefs);
      final repository = SettingsRepositoryImpl(localDataSource: dataSource);
      final cubit = SettingsCubit(
        getSettings: GetSettingsUseCase(repository),
        setLocaleUseCase: SetLocaleUseCase(repository),
        setDarkModeUseCase: SetDarkModeUseCase(repository),
        setStockAlertsUseCase: SetStockAlertsUseCase(repository),
        setAppUpdatesUseCase: SetAppUpdatesUseCase(repository),
        markOnboardingSeenUseCase: MarkOnboardingSeenUseCase(repository),
      );

      expect(cubit.state.locale, 'rw');
      expect(cubit.state.isDarkMode, isTrue);
      expect(cubit.state.stockAlerts, isFalse);
      expect(cubit.state.appUpdates, isTrue);
      expect(cubit.state.hasSeenOnboarding, isTrue);

      await cubit.close();
    });

    test('SettingsCubit mutation methods persist changes to SharedPreferences and update state', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dataSource = SharedPreferencesSettingsDataSource(prefs: prefs);
      final repository = SettingsRepositoryImpl(localDataSource: dataSource);
      final cubit = SettingsCubit(
        getSettings: GetSettingsUseCase(repository),
        setLocaleUseCase: SetLocaleUseCase(repository),
        setDarkModeUseCase: SetDarkModeUseCase(repository),
        setStockAlertsUseCase: SetStockAlertsUseCase(repository),
        setAppUpdatesUseCase: SetAppUpdatesUseCase(repository),
        markOnboardingSeenUseCase: MarkOnboardingSeenUseCase(repository),
      );

      await cubit.setLocale('fr');
      expect(cubit.state.locale, 'fr');
      expect(prefs.getString('locale'), 'fr');

      await cubit.setDarkMode(true);
      expect(cubit.state.isDarkMode, isTrue);
      expect(prefs.getBool('isDarkMode'), isTrue);

      await cubit.setStockAlerts(false);
      expect(cubit.state.stockAlerts, isFalse);
      expect(prefs.getBool('stockAlerts'), isFalse);

      await cubit.setAppUpdates(true);
      expect(cubit.state.appUpdates, isTrue);
      expect(prefs.getBool('appUpdates'), isTrue);

      await cubit.markOnboardingSeen();
      expect(cubit.state.hasSeenOnboarding, isTrue);
      expect(prefs.getBool('hasSeenOnboarding'), isTrue);

      await cubit.close();
    });
  });

  group('Auth Pipeline - MockAuthDataSource, Repository, UseCases, and AuthBloc', () {
    late MockAuthDataSource mockDataSource;
    late AuthRepositoryImpl repository;
    late AuthBloc authBloc;

    setUp(() {
      mockDataSource = MockAuthDataSource();
      repository = AuthRepositoryImpl(datasource: mockDataSource);
      authBloc = AuthBloc(
        getCurrentUser: GetCurrentUserUseCase(repository),
        signInWithEmail: SignInWithEmailUseCase(repository),
        registerWithEmail: RegisterWithEmailUseCase(repository),
        signInWithGoogle: SignInWithGoogleUseCase(repository),
        sendPasswordReset: SendPasswordResetUseCase(repository),
        signOut: SignOutUseCase(repository),
        updateUserProfile: UpdateUserProfileUseCase(repository),
      );
    });

    tearDown(() async {
      await authBloc.close();
    });

    test('AuthCheckRequested emits AuthUnauthenticated when no user is signed in', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(AuthCheckRequested());
      await pumpEventQueue();

      expect(states, [isA<AuthUnauthenticated>()]);
      await subscription.cancel();
    });

    test('AuthLoginRequested emits [AuthLoading, AuthAuthenticated] on success', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const AuthLoginRequested(
        email: 'user@example.com',
        password: 'password123',
      ));
      await pumpEventQueue();
      await Future.delayed(const Duration(milliseconds: 500));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      final authenticated = states[1] as AuthAuthenticated;
      expect(authenticated.user.email, 'user@example.com');
      expect(authenticated.user.displayName, 'user');

      await subscription.cancel();
    });

    test('AuthRegisterRequested emits [AuthLoading, AuthAuthenticated] with registered role', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(const AuthRegisterRequested(
        email: 'partner@example.com',
        password: 'secretpassword',
        displayName: 'Partner User',
        role: 'partner',
      ));
      await pumpEventQueue();
      await Future.delayed(const Duration(milliseconds: 500));

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthAuthenticated>());
      final authenticated = states[1] as AuthAuthenticated;
      expect(authenticated.user.email, 'partner@example.com');
      expect(authenticated.user.displayName, 'Partner User');
      expect(authenticated.user.role, 'partner');
      expect(authenticated.user.isPartner, isTrue);

      await subscription.cancel();
    });

    test('AuthLogoutRequested signs out and emits AuthUnauthenticated', () async {
      final states = <AuthState>[];
      final subscription = authBloc.stream.listen(states.add);

      authBloc.add(AuthLogoutRequested());
      await pumpEventQueue();

      expect(states, [isA<AuthUnauthenticated>()]);
      expect(mockDataSource.currentUser, isNull);

      await subscription.cancel();
    });

    test('AuthBloc emits [AuthLoading, AuthError] when authentication fails', () async {
      final failingDataSource = _FailingAuthDataSource();
      final failingRepo = AuthRepositoryImpl(datasource: failingDataSource);
      final failingBloc = AuthBloc(
        getCurrentUser: GetCurrentUserUseCase(failingRepo),
        signInWithEmail: SignInWithEmailUseCase(failingRepo),
        registerWithEmail: RegisterWithEmailUseCase(failingRepo),
        signInWithGoogle: SignInWithGoogleUseCase(failingRepo),
        sendPasswordReset: SendPasswordResetUseCase(failingRepo),
        signOut: SignOutUseCase(failingRepo),
        updateUserProfile: UpdateUserProfileUseCase(failingRepo),
      );

      final states = <AuthState>[];
      final subscription = failingBloc.stream.listen(states.add);

      failingBloc.add(const AuthLoginRequested(
        email: 'fail@example.com',
        password: 'wrong',
      ));
      await pumpEventQueue();

      expect(states.length, 2);
      expect(states[0], isA<AuthLoading>());
      expect(states[1], isA<AuthError>());
      final errorState = states[1] as AuthError;
      expect(errorState.message, contains('Invalid email or password'));

      await subscription.cancel();
      await failingBloc.close();
    });
  });

  group('PharmaFind UI Components Widget Tests', () {
    testWidgets('PharmaFindLogo renders logo icons and branding text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PharmaFindLogo(size: 60),
          ),
        ),
      );

      expect(find.byType(PharmaFindLogo), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == 'PharmaFind',
        ),
        findsOneWidget,
      );
    });

    testWidgets('PharmaFindLogo hides branding text when showText is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PharmaFindLogo(showText: false),
          ),
        ),
      );

      expect(find.byType(PharmaFindLogo), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText() == 'PharmaFind',
        ),
        findsNothing,
      );
    });
  });
}
