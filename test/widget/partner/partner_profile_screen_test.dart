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
import 'package:pharmafind/presentation/screens/partner/partner_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

String _en(String key) => AppStrings.get(key, 'en');

class _TestPartnerAuthDataSource extends MockAuthDataSource {
  final String userId;

  _TestPartnerAuthDataSource({this.userId = 'partner-user-123'});

  @override
  Future<UserModel?> getCurrentUser() async => UserModel(
    uid: userId,
    email: 'partner@pharmacy.rw',
    displayName: 'Dr. Partner',
    role: 'partner',
    phone: '+250788111222',
    createdAt: DateTime(2026, 1, 1),
  );
}

PharmacyCubit _buildTestPharmacyCubit(MockPharmacyDataSource dataSource) {
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

Future<void> pumpProfileScreen(
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
      authDataSource: authDataSource ?? _TestPartnerAuthDataSource(),
      child: MaterialApp(
        home: const PartnerProfileScreen(),
        routes: {
          '/partner-pending': (_) => const Scaffold(key: Key('pending_screen')),
          ...routes,
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PartnerProfileScreen', () {
    testWidgets(
      'renders creation form with pre-filled defaults and validates required fields',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        final cubit = _buildTestPharmacyCubit(mockDataSource);

        await pumpProfileScreen(tester, pharmacyCubit: cubit);

        // Verify form elements render
        expect(find.text(_en('add_pharmacy_details')), findsOneWidget);
        expect(find.text(_en('save_profile')), findsOneWidget);
        expect(
          find.text('Insurance'),
          findsNothing,
        ); // label is accepts_insurance

        // Clear the required text fields to trigger validation
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), ''); // Name
        await tester.enterText(textFields.at(1), ''); // Area
        await tester.enterText(textFields.at(2), ''); // District
        await tester.enterText(textFields.at(3), ''); // Phone
        await tester.enterText(textFields.at(4), ''); // Email
        await tester.enterText(textFields.at(5), ''); // Hours
        await tester.enterText(textFields.at(6), ''); // Lat
        await tester.enterText(textFields.at(7), ''); // Lng
        await tester.pump();

        await tester.tap(find.text(_en('save_profile')));
        await tester.pumpAndSettle();

        expect(find.text('Pharmacy name is required'), findsOneWidget);
        expect(find.text('Area is required'), findsOneWidget);
        expect(find.text('District is required'), findsOneWidget);
        expect(find.text('Phone number is required'), findsOneWidget);
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Operating hours is required'), findsOneWidget);
      },
    );

    testWidgets(
      'creates pharmacy profile with authenticated owner UID and initial pending status',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        final cubit = _buildTestPharmacyCubit(mockDataSource);
        final authSource = _TestPartnerAuthDataSource(
          userId: 'partner-uid-789',
        );

        await pumpProfileScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: authSource,
        );

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Hope Pharmacy Remera');
        await tester.enterText(textFields.at(1), 'Remera');
        await tester.enterText(textFields.at(2), 'Gasabo');
        await tester.enterText(textFields.at(3), '+250788123456');
        await tester.enterText(textFields.at(4), 'hope@pharmacy.rw');
        await tester.enterText(textFields.at(5), '8:00 AM - 10:00 PM');
        await tester.enterText(textFields.at(6), '-1.9500');
        await tester.enterText(textFields.at(7), '30.1100');
        await tester.pump();

        await tester.tap(find.text(_en('save_profile')));
        await tester.pumpAndSettle();

        // Successful creation navigates to /partner-pending
        expect(find.byKey(const Key('pending_screen')), findsOneWidget);

        // Verify the persisted entity in repository has correct ownerId and pending status
        final createdPharmacy = await mockDataSource.getPharmacyByOwner(
          'partner-uid-789',
        );
        expect(createdPharmacy, isNotNull);
        expect(createdPharmacy!.name, 'Hope Pharmacy Remera');
        expect(createdPharmacy.ownerId, 'partner-uid-789');
        expect(createdPharmacy.status, 'pending');
        expect(createdPharmacy.area, 'Remera');
        expect(createdPharmacy.district, 'Gasabo');
        expect(createdPharmacy.acceptsInsurance, isTrue);
      },
    );

    testWidgets(
      'populates existing pharmacy and preserves verification status when editing',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        // Pre-seed an approved pharmacy
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-approved-1',
            name: 'Original Pharmacy Name',
            area: 'Kacyiru',
            district: 'Gasabo',
            phone: '+250788999888',
            email: 'orig@pharma.rw',
            hours: '7:00 AM - 9:00 PM',
            latitude: -1.94,
            longitude: 30.06,
            ownerId: 'owner-edit-1',
            status: 'approved', // Must be preserved!
            acceptsInsurance: true,
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final cubit = _buildTestPharmacyCubit(mockDataSource);
        await cubit.loadPharmacy('owner-edit-1');

        final authSource = _TestPartnerAuthDataSource(userId: 'owner-edit-1');

        await pumpProfileScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: authSource,
        );

        // Verify edit mode header and pre-filled name
        expect(find.text('Edit pharmacy information'), findsOneWidget);
        expect(find.text('Current Status: APPROVED'), findsOneWidget);
        expect(find.text('Original Pharmacy Name'), findsOneWidget);
        expect(find.text(_en('save_changes')), findsOneWidget);

        // Change pharmacy name and operating hours
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Updated Pharmacy Name');
        await tester.enterText(textFields.at(5), '24 Hours');
        await tester.pump();

        await tester.tap(find.text(_en('save_changes')));
        await tester.pumpAndSettle();

        // Verify snackbar
        expect(find.text(_en('profile_saved')), findsOneWidget);

        // Verify the persisted record was updated and retained 'approved' status!
        final updatedPharmacy = await mockDataSource.getPharmacyByOwner(
          'owner-edit-1',
        );
        expect(updatedPharmacy, isNotNull);
        expect(updatedPharmacy!.name, 'Updated Pharmacy Name');
        expect(updatedPharmacy.hours, '24 Hours');
        expect(
          updatedPharmacy.status,
          'approved',
        ); // Verification status NOT reset to pending!
      },
    );

    testWidgets(
      'preserves rejected verification status when editing rejected profile',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-rej-1',
            name: 'Rejected Pharmacy',
            area: 'Nyarugenge',
            district: 'Nyarugenge',
            phone: '+250788333444',
            email: 'rej@pharma.rw',
            hours: '8:00 AM - 10:00 PM',
            latitude: -1.95,
            longitude: 30.05,
            ownerId: 'owner-rej-1',
            status: 'rejected',
            acceptsInsurance: false,
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final cubit = _buildTestPharmacyCubit(mockDataSource);
        await cubit.loadPharmacy('owner-rej-1');

        final authSource = _TestPartnerAuthDataSource(userId: 'owner-rej-1');

        await pumpProfileScreen(
          tester,
          pharmacyCubit: cubit,
          authDataSource: authSource,
        );

        expect(find.text('Current Status: REJECTED'), findsOneWidget);

        // Save changes
        await tester.tap(find.text(_en('save_changes')));
        await tester.pumpAndSettle();

        final updatedPharmacy = await mockDataSource.getPharmacyByOwner(
          'owner-rej-1',
        );
        expect(updatedPharmacy!.status, 'rejected'); // Status preserved
      },
    );

    testWidgets('displays error snackbar when pharmacy update fails', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      final cubit = _buildTestPharmacyCubit(mockDataSource);

      await pumpProfileScreen(tester, pharmacyCubit: cubit);

      // Simulate cubit error emission
      cubit.emit(
        cubit.state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: 'Database connection failed',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Database connection failed'), findsOneWidget);
    });
  });
}
