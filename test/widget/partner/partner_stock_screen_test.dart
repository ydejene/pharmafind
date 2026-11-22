import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/data/datasources/mock_auth_datasource.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';
import 'package:pharmafind/data/models/stock_item_model.dart';
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
import 'package:pharmafind/presentation/screens/partner/partner_stock_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

String _en(String key) => AppStrings.get(key, 'en');

class _TestRoleAuthDataSource extends MockAuthDataSource {
  final String userId;
  final String role;
  final bool isAuthenticated;

  _TestRoleAuthDataSource({
    this.userId = 'owner-1',
    this.role = 'partner',
    this.isAuthenticated = true,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!isAuthenticated) return null;
    return UserModel(
      uid: userId,
      email: 'partner@example.com',
      displayName: 'Dr. Jean',
      role: role,
      createdAt: DateTime(2026, 1, 1),
    );
  }
}

class _FailingPharmacyDataSource extends MockPharmacyDataSource {
  _FailingPharmacyDataSource() : super(seedInitialData: false);

  @override
  Future<List<StockItemModel>> getPharmacyStock(String pharmacyId) async {
    throw Exception('Database connection failed');
  }
}

class _DelayedPharmacyDataSource extends MockPharmacyDataSource {
  final Future<PharmacyModel?> pendingFuture;
  _DelayedPharmacyDataSource(this.pendingFuture) : super(seedInitialData: false);

  @override
  Future<PharmacyModel?> getPharmacyByOwner(String ownerId) => pendingFuture;
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

Future<void> pumpStockScreen(
  WidgetTester tester, {
  PharmacyCubit? pharmacyCubit,
  MockAuthDataSource? authDataSource,
  Map<String, WidgetBuilder> routes = const {},
  bool settle = true,
}) async {
  tester.view.physicalSize = const Size(800, 1400);
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
        home: const PartnerStockScreen(),
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login Screen')),
          '/home': (_) => const Scaffold(body: Text('Home Screen')),
          '/partner-profile': (_) =>
              const Scaffold(body: Text('Partner Profile Screen')),
          '/partner-pending': (_) =>
              const Scaffold(body: Text('Partner Pending Screen')),
          '/partner-rejected': (_) =>
              const Scaffold(body: Text('Partner Rejected Screen')),
          '/partner-license': (_) =>
              const Scaffold(body: Text('Partner License Screen')),
          ...routes,
        },
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PartnerStockScreen Tests', () {
    testWidgets('shows login prompt when user is not authenticated', (
      tester,
    ) async {
      await pumpStockScreen(
        tester,
        authDataSource: _TestRoleAuthDataSource(isAuthenticated: false),
      );

      expect(find.text('Authentication Required'), findsOneWidget);
      expect(
        find.text(
          'Please log in with a partner account to manage medicine stock.',
        ),
        findsOneWidget,
      );
      expect(find.text(_en('login')), findsOneWidget);

      await tester.tap(find.text(_en('login')));
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('blocks non-partner accounts with access-required screen', (
      tester,
    ) async {
      await pumpStockScreen(
        tester,
        authDataSource: _TestRoleAuthDataSource(role: 'student'),
      );

      expect(find.text('Partner Access Required'), findsOneWidget);
      expect(
        find.text(
          'Stock management is reserved for verified pharmacy partner accounts.',
        ),
        findsOneWidget,
      );
      expect(find.text(_en('browse_app')), findsOneWidget);

      await tester.tap(find.text(_en('browse_app')));
      await tester.pumpAndSettle();
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets(
      'displays no-pharmacy prompt when partner has no registered pharmacy',
      (tester) async {
        final emptyDataSource = MockPharmacyDataSource(seedInitialData: false);
        final cubit = _buildTestCubit(emptyDataSource);

        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'unregistered-uid'),
        );

        expect(find.text('No Pharmacy Registered'), findsOneWidget);
        expect(
          find.text(
            'You must create your pharmacy profile before managing medicine stock.',
          ),
          findsOneWidget,
        );
        expect(find.text(_en('add_pharmacy_details')), findsOneWidget);

        await tester.tap(find.text(_en('add_pharmacy_details')));
        await tester.pumpAndSettle();
        expect(find.text('Partner Profile Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'displays empty state when pharmacy exists but has no stock items',
      (tester) async {
        final dataSource = MockPharmacyDataSource(seedInitialData: false);
        final pharmacy = PharmacyModel(
          id: 'pharmacy-empty',
          name: 'Empty Pharmacy',
          area: 'Kigali',
          district: 'Nyarugenge',
          phone: '+250788000000',
          email: 'empty@pharmacy.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.95,
          longitude: 30.06,
          ownerId: 'user-empty',
          status: 'approved',
          acceptsInsurance: true,
          createdAt: DateTime(2026, 1, 1),
        );
        await dataSource.createPharmacy(pharmacy);

        final cubit = _buildTestCubit(dataSource);

        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'user-empty'),
        );

        expect(find.text(_en('manage_stock')), findsOneWidget);
        expect(find.text('Empty Pharmacy'), findsOneWidget);
        expect(find.text(_en('no_stock')), findsOneWidget);
        expect(find.byKey(const Key('add_stock_empty_button')), findsOneWidget);
      },
    );

    testWidgets(
      'renders loaded stock item list with formatted info and badges',
      (tester) async {
        final dataSource = MockPharmacyDataSource(seedInitialData: true);
        final cubit = _buildTestCubit(dataSource);

        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'owner-1'),
        );

        expect(find.text(_en('manage_stock')), findsOneWidget);
        expect(
          find.byKey(const Key('add_stock_header_button')),
          findsOneWidget,
        );

        // Seeded medicines for owner-1 (pharm-1): Amoxicillin 500mg, Paracetamol 1000mg
        expect(find.text('Amoxicillin 500mg'), findsOneWidget);
        expect(find.text('Paracetamol 1000mg'), findsOneWidget);

        // Verify badges and prices
        expect(find.text('In Stock'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('validates required fields and numeric bounds in add form', (
      tester,
    ) async {
      final dataSource = MockPharmacyDataSource(seedInitialData: true);
      final cubit = _buildTestCubit(dataSource);

      await pumpStockScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: _TestRoleAuthDataSource(userId: 'owner-1'),
      );

      // Open Add Stock sheet
      await tester.tap(find.byKey(const Key('add_stock_header_button')));
      await tester.pumpAndSettle();

      expect(find.text(_en('add_medicine')), findsWidgets);

      // Submit empty form
      await tester.tap(find.byKey(const Key('submit_stock_button')));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a medicine name'), findsOneWidget);
      expect(find.text('Please enter price in RWF'), findsOneWidget);
      expect(find.text('Please enter quantity'), findsOneWidget);

      // Enter invalid non-positive numbers
      await tester.enterText(
        find.byKey(const Key('stock_medicine_name_input')),
        'Test Medicine',
      );
      await tester.enterText(find.byKey(const Key('stock_price_input')), '0');
      await tester.enterText(
        find.byKey(const Key('stock_quantity_input')),
        '-5',
      );
      await tester.tap(find.byKey(const Key('submit_stock_button')));
      await tester.pumpAndSettle();

      expect(find.text('Price must be greater than 0'), findsOneWidget);
      expect(find.text('Quantity cannot be negative'), findsOneWidget);
    });

    testWidgets(
      'adds a new stock item successfully and links to partner pharmacy',
      (tester) async {
        final dataSource = MockPharmacyDataSource(seedInitialData: true);
        final cubit = _buildTestCubit(dataSource);

        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'owner-1'),
        );

        // Open Add Stock sheet
        await tester.tap(find.byKey(const Key('add_stock_header_button')));
        await tester.pumpAndSettle();

        // Fill valid details
        await tester.enterText(
          find.byKey(const Key('stock_medicine_name_input')),
          'Cetirizine 10mg',
        );
        await tester.enterText(
          find.byKey(const Key('stock_price_input')),
          '4500',
        );
        await tester.enterText(
          find.byKey(const Key('stock_quantity_input')),
          '35',
        );
        await tester.tap(find.byKey(const Key('submit_stock_button')));
        await tester.pumpAndSettle();

        // Success snackbar and item in list
        expect(find.text('Cetirizine 10mg added to stock'), findsOneWidget);
        expect(find.text('Cetirizine 10mg'), findsOneWidget);
        expect(find.textContaining('35 packs · RWF 4,500'), findsOneWidget);

        // Verify correct pharmacy association in cubit state
        final addedItem = cubit.state.stockItems.firstWhere(
          (i) => i.medicineName == 'Cetirizine 10mg',
        );
        expect(addedItem.pharmacyId, 'pharm-1');
        expect(addedItem.price, 4500);
        expect(addedItem.quantity, 35);
      },
    );

    testWidgets(
      'edits an existing stock item preserving pharmacy association',
      (tester) async {
        final dataSource = MockPharmacyDataSource(seedInitialData: true);
        final cubit = _buildTestCubit(dataSource);

        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'owner-1'),
        );

        // Find first item (e.g. stock-1: Amoxicillin 500mg)
        final editButton = find.byKey(const Key('edit_item_stock-1'));
        expect(editButton, findsOneWidget);
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        expect(find.text('${_en('edit')} Amoxicillin 500mg'), findsOneWidget);

        // Edit price and quantity
        await tester.enterText(
          find.byKey(const Key('edit_stock_price_input')),
          '6500',
        );
        await tester.enterText(
          find.byKey(const Key('edit_stock_quantity_input')),
          '80',
        );
        await tester.tap(find.byKey(const Key('save_stock_changes_button')));
        await tester.pumpAndSettle();

        expect(find.text('Amoxicillin 500mg updated'), findsOneWidget);
        expect(find.textContaining('80 packs · RWF 6,500'), findsOneWidget);

        final updated = cubit.state.stockItems.firstWhere(
          (i) => i.id == 'stock-1',
        );
        expect(updated.price, 6500);
        expect(updated.quantity, 80);
        expect(updated.pharmacyId, 'pharm-1');
      },
    );

    testWidgets('deletes stock item with confirmation dialog protection', (
      tester,
    ) async {
      final dataSource = MockPharmacyDataSource(seedInitialData: true);
      final cubit = _buildTestCubit(dataSource);

      await pumpStockScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: _TestRoleAuthDataSource(userId: 'owner-1'),
      );

      expect(find.text('Amoxicillin 500mg'), findsOneWidget);

      // Tap delete button on stock-1
      await tester.tap(find.byKey(const Key('delete_item_stock-1')));
      await tester.pumpAndSettle();

      expect(find.text('Delete Stock Item'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to remove "Amoxicillin 500mg" from your inventory?',
        ),
        findsOneWidget,
      );

      // Cancel deletion first
      await tester.tap(find.byKey(const Key('cancel_delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Amoxicillin 500mg'), findsOneWidget);

      // Tap delete again and confirm
      await tester.tap(find.byKey(const Key('delete_item_stock-1')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_delete_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('"Amoxicillin 500mg" removed from stock'),
        findsOneWidget,
      );
      expect(find.text('Amoxicillin 500mg'), findsNothing);
      expect(cubit.state.stockItems.any((i) => i.id == 'stock-1'), isFalse);
    });

    testWidgets('displays error state with retry when stock fails to load', (
      tester,
    ) async {
      final failingDataSource = _FailingPharmacyDataSource();
      final pharmacy = PharmacyModel(
        id: 'pharmacy-failing',
        name: 'Failing Pharmacy',
        area: 'Kigali',
        district: 'Gasabo',
        phone: '+250788111222',
        email: 'fail@test.rw',
        hours: '8:00 AM - 10:00 PM',
        latitude: -1.94,
        longitude: 30.06,
        ownerId: 'user-fail',
        status: 'approved',
        acceptsInsurance: true,
        createdAt: DateTime(2026, 1, 1),
      );
      await failingDataSource.createPharmacy(pharmacy);

      final cubit = _buildTestCubit(failingDataSource);

      await pumpStockScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: _TestRoleAuthDataSource(userId: 'user-fail'),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('redirects pending partner to partner-pending screen', (
      tester,
    ) async {
      final dataSource = MockPharmacyDataSource(seedInitialData: false);
      final pharmacy = PharmacyModel(
        id: 'pharmacy-pending',
        name: 'Pending Pharmacy',
        area: 'Kigali',
        district: 'Nyarugenge',
        phone: '+250788000111',
        email: 'pending@pharm.rw',
        hours: '8:00 AM - 10:00 PM',
        latitude: -1.95,
        longitude: 30.06,
        ownerId: 'user-pending',
        status: 'pending',
        licenseUrl: 'https://cloudinary.com/lic.pdf',
        rmohCertUrl: 'https://cloudinary.com/rmoh.pdf',
        submittedAt: DateTime(2026, 1, 2),
        createdAt: DateTime(2026, 1, 1),
      );
      await dataSource.createPharmacy(pharmacy);

      final cubit = _buildTestCubit(dataSource);

      await pumpStockScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: _TestRoleAuthDataSource(userId: 'user-pending'),
      );

      // Verify redirected to Partner Pending Screen
      expect(find.text('Partner Pending Screen'), findsOneWidget);
      expect(find.byKey(const Key('add_stock_header_button')), findsNothing);
    });

    testWidgets('redirects rejected partner to partner-rejected screen', (
      tester,
    ) async {
      final dataSource = MockPharmacyDataSource(seedInitialData: false);
      final pharmacy = PharmacyModel(
        id: 'pharmacy-rejected',
        name: 'Rejected Pharmacy',
        area: 'Kigali',
        district: 'Gasabo',
        phone: '+250788000222',
        email: 'rejected@pharm.rw',
        hours: '8:00 AM - 10:00 PM',
        latitude: -1.95,
        longitude: 30.06,
        ownerId: 'user-rejected',
        status: 'rejected',
        rejectionReason: 'Invalid license format',
        licenseUrl: 'https://cloudinary.com/lic.pdf',
        rmohCertUrl: 'https://cloudinary.com/rmoh.pdf',
        submittedAt: DateTime(2026, 1, 2),
        createdAt: DateTime(2026, 1, 1),
      );
      await dataSource.createPharmacy(pharmacy);

      final cubit = _buildTestCubit(dataSource);

      await pumpStockScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: _TestRoleAuthDataSource(userId: 'user-rejected'),
      );

      // Verify redirected to Partner Rejected Screen
      expect(find.text('Partner Rejected Screen'), findsOneWidget);
      expect(find.byKey(const Key('add_stock_header_button')), findsNothing);
    });

    testWidgets(
      'displays documents required guard when partner has unsubmitted documents',
      (tester) async {
        final dataSource = MockPharmacyDataSource(seedInitialData: false);
        final pharmacy = PharmacyModel(
          id: 'pharmacy-unsubmitted',
          name: 'Unsubmitted Pharmacy',
          area: 'Kigali',
          district: 'Nyarugenge',
          phone: '+250788000333',
          email: 'unsub@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.95,
          longitude: 30.06,
          ownerId: 'user-unsubmitted',
          status: 'pending',
          licenseUrl: null,
          rmohCertUrl: null,
          submittedAt: null,
          createdAt: DateTime(2026, 1, 1),
        );
        await dataSource.createPharmacy(pharmacy);

        final cubit = _buildTestCubit(dataSource);

        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'user-unsubmitted'),
        );

        expect(find.text('Verification Documents Required'), findsOneWidget);
        expect(find.text('Upload Documents'), findsOneWidget);

        await tester.tap(find.text('Upload Documents'));
        await tester.pumpAndSettle();
        expect(find.text('Partner License Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'does not grant access using stale pharmacy belonging to another user',
      (tester) async {
        final dataSource = MockPharmacyDataSource(seedInitialData: false);
        final otherUserPharmacy = PharmacyModel(
          id: 'pharmacy-other',
          name: 'Other User Pharmacy',
          area: 'Kigali',
          district: 'Nyarugenge',
          phone: '+250788000444',
          email: 'other@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.95,
          longitude: 30.06,
          ownerId: 'user-other',
          status: 'approved',
          createdAt: DateTime(2026, 1, 1),
        );
        await dataSource.createPharmacy(otherUserPharmacy);

        final cubit = _buildTestCubit(dataSource);
        // Preload other user's approved pharmacy into cubit
        await cubit.loadPharmacy('user-other');

        // Now pump stock screen with different partner 'user-current' who has no pharmacy
        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'user-current'),
        );

        // Stale pharmacy must NOT be displayed; screen must reload and show no pharmacy for user-current
        expect(find.text('Other User Pharmacy'), findsNothing);
        expect(find.text('No Pharmacy Registered'), findsOneWidget);
      },
    );

    testWidgets(
      'loading state displays loading indicator and blocks stock management actions',
      (tester) async {
        final completer = Completer<PharmacyModel?>();
        final dataSource = _DelayedPharmacyDataSource(completer.future);
        final cubit = _buildTestCubit(dataSource);

        // Start loading pharmacy for user
        unawaited(cubit.loadPharmacy('user-loading'));

        await pumpStockScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: _TestRoleAuthDataSource(userId: 'user-loading'),
          settle: false,
        );
        await tester.pump();

        // Verify loading indicator is displayed while pharmacy is loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Header add stock button and stock list are blocked / not present
        expect(find.byKey(const Key('add_stock_header_button')), findsNothing);
        expect(find.byKey(const Key('add_stock_empty_button')), findsNothing);

        // Complete the future to allow test teardown
        completer.complete(null);
        await tester.pumpAndSettle();
      },
    );
  });
}
