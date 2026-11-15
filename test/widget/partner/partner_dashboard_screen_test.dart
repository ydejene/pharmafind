import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';
import 'package:pharmafind/data/models/user_model.dart';
import 'package:pharmafind/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmafind/domain/usecases/pharmacy/add_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/create_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/delete_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_by_owner_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_stock_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/watch_pharmacy_stock_usecase.dart';
import 'package:pharmafind/presentation/bloc/pharmacy/pharmacy_cubit.dart';
import 'package:pharmafind/presentation/screens/partner/partner_dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

String _en(String key) => AppStrings.get(key, 'en');

class _TestRoleAuthDataSource extends MockAuthDataSource {
  final String userId;
  final String role;
  final bool isAuthenticated;

  _TestRoleAuthDataSource({
    this.userId = 'user-1',
    this.role = 'partner',
    this.isAuthenticated = true,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!isAuthenticated) return null;
    return UserModel(
      uid: userId,
      email: 'user@example.com',
      displayName: 'Dr. Jean',
      role: role,
      createdAt: DateTime(2026, 1, 1),
    );
  }
}

class _FailingPharmacyDataSource extends MockPharmacyDataSource {
  _FailingPharmacyDataSource() : super(seedInitialData: false);

  @override
  Future<PharmacyModel?> getPharmacyByOwner(String ownerId) async {
    throw Exception('Server timeout loading pharmacy');
  }
}

PharmacyCubit _buildTestCubit(MockPharmacyDataSource dataSource) {
  final repo = PharmacyRepositoryImpl(datasource: dataSource);
  return PharmacyCubit(
    getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
    getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
    createPharmacyUseCase: CreatePharmacyUseCase(repo),
    updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
    addStockItemUseCase: AddStockItemUseCase(repo),
    updateStockItemUseCase: UpdateStockItemUseCase(repo),
    deleteStockItemUseCase: DeleteStockItemUseCase(repo),
    watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
  );
}

Future<void> pumpDashboardScreen(
  WidgetTester tester, {
  PharmacyCubit? pharmacyCubit,
  MockAuthDataSource? authDataSource,
  Map<String, WidgetBuilder> routes = const {},
}) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    withPartnerTestProviders(
      settingsCubit: buildTestSettingsCubit(prefs),
      pharmacyCubit: pharmacyCubit,
      authDataSource: authDataSource ?? _TestRoleAuthDataSource(),
      child: MaterialApp(
        home: const PartnerDashboardScreen(),
        routes: {
          '/home': (_) => const Scaffold(key: Key('home_screen')),
          '/login': (_) => const Scaffold(key: Key('login_screen')),
          '/partner-profile': (_) =>
              const Scaffold(key: Key('partner_profile_screen')),
          '/partner-pending': (_) =>
              const Scaffold(key: Key('partner_pending_screen')),
          '/partner-rejected': (_) =>
              const Scaffold(key: Key('partner_rejected_screen')),
          ...routes,
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PartnerDashboardScreen', () {
    testWidgets('shows login prompt when user is not authenticated', (
      tester,
    ) async {
      await pumpDashboardScreen(
        tester,
        authDataSource: _TestRoleAuthDataSource(isAuthenticated: false),
      );

      expect(find.text('Authentication Required'), findsOneWidget);
      expect(find.text(_en('login')), findsOneWidget);

      await tester.tap(find.text(_en('login')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_screen')), findsOneWidget);
    });

    testWidgets(
      'blocks ordinary student/patient accounts from partner portal',
      (tester) async {
        await pumpDashboardScreen(
          tester,
          authDataSource: _TestRoleAuthDataSource(role: 'patient'),
        );

        expect(find.text('Partner Access Required'), findsOneWidget);
        expect(find.text(_en('browse_app')), findsOneWidget);

        await tester.tap(find.text(_en('browse_app')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('home_screen')), findsOneWidget);
      },
    );

    testWidgets(
      'displays empty state when partner has no registered pharmacy',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        final cubit = _buildTestCubit(mockDataSource);

        await pumpDashboardScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'partner-no-pharm'),
        );

        expect(find.text('No Pharmacy Registered'), findsOneWidget);
        expect(find.text(_en('add_pharmacy_details')), findsOneWidget);

        await tester.tap(find.text(_en('add_pharmacy_details')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('partner_profile_screen')), findsOneWidget);
      },
    );

    testWidgets('displays approved pharmacy status, details, and navigation', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-app-1',
          name: 'Kigali City Pharmacy',
          area: 'Downtown',
          district: 'Nyarugenge',
          phone: '+250788555666',
          email: 'kigali@citypharm.rw',
          hours: '24/7 Service',
          latitude: -1.95,
          longitude: 30.06,
          ownerId: 'partner-owner-1',
          status: 'approved',
          acceptsInsurance: true,
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final cubit = _buildTestCubit(mockDataSource);
      await cubit.loadPharmacy('partner-owner-1');

      await pumpDashboardScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: _TestRoleAuthDataSource(userId: 'partner-owner-1'),
      );

      // Verify name, status, and details
      expect(find.text('Kigali City Pharmacy'), findsWidgets);
      expect(find.text('VERIFIED & ACTIVE'), findsOneWidget);
      expect(find.text('Downtown, Nyarugenge'), findsOneWidget);
      expect(find.text('+250788555666'), findsOneWidget);
      expect(find.text('24/7 Service'), findsOneWidget);
      expect(find.text('Insurance'), findsOneWidget);

      // Navigate to profile editing
      await tester.tap(find.text(_en('pharmacy_profile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('partner_profile_screen')), findsOneWidget);
    });

    testWidgets(
      'displays pending verification status badge and pending navigation',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-pen-1',
            name: 'Pending Review Pharmacy',
            area: 'Kicukiro',
            district: 'Kicukiro',
            phone: '+250788777888',
            email: 'pending@pharma.rw',
            hours: '8:00 AM - 8:00 PM',
            latitude: -1.96,
            longitude: 30.08,
            ownerId: 'partner-pending-1',
            status: 'pending',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final cubit = _buildTestCubit(mockDataSource);
        await cubit.loadPharmacy('partner-pending-1');

        await pumpDashboardScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'partner-pending-1'),
        );

        expect(find.text('VERIFICATION IN PROGRESS'), findsOneWidget);
        expect(find.text('Verification Status'), findsOneWidget);

        await tester.tap(find.text('Verification Status'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('partner_pending_screen')), findsOneWidget);
      },
    );

    testWidgets(
      'displays rejected verification status badge and rejection navigation',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-rej-1',
            name: 'Rejected Documents Pharmacy',
            area: 'Gisozi',
            district: 'Gasabo',
            phone: '+250788444333',
            email: 'gisozi@pharma.rw',
            hours: '8:00 AM - 10:00 PM',
            latitude: -1.93,
            longitude: 30.07,
            ownerId: 'partner-rej-1',
            status: 'rejected',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final cubit = _buildTestCubit(mockDataSource);
        await cubit.loadPharmacy('partner-rej-1');

        await pumpDashboardScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'partner-rej-1'),
        );

        expect(find.text('VERIFICATION UNSUCCESSFUL'), findsOneWidget);
        expect(find.text('Rejection Details'), findsOneWidget);

        await tester.tap(find.text('Rejection Details'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('partner_rejected_screen')),
          findsOneWidget,
        );
      },
    );

    testWidgets('handles error state with retry button', (tester) async {
      final failingDataSource = _FailingPharmacyDataSource();
      final cubit = _buildTestCubit(failingDataSource);

      await pumpDashboardScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: _TestRoleAuthDataSource(userId: 'partner-err-1'),
      );

      expect(
        find.textContaining('Server timeout loading pharmacy'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
      'does not display fabricated statistics or fake activity numbers',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-stat-1',
            name: 'Real Data Pharmacy',
            area: 'Remera',
            district: 'Gasabo',
            phone: '+250788111222',
            email: 'real@data.rw',
            hours: '8:00 AM - 10:00 PM',
            latitude: -1.94,
            longitude: 30.06,
            ownerId: 'partner-stat-1',
            status: 'approved',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final cubit = _buildTestCubit(mockDataSource);
        await cubit.loadPharmacy('partner-stat-1');

        await pumpDashboardScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'partner-stat-1'),
        );

        // Verify that reference repo fake stats are NOT displayed
        expect(find.text('142'), findsNothing); // Fake view count
        expect(find.text('38'), findsNothing); // Fake call count
        expect(
          find.textContaining('people searched for a medicine'),
          findsNothing,
        );
      },
    );
  });
}
