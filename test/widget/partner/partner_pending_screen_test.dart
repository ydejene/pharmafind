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
import 'package:pharmafind/presentation/screens/partner/partner_pending_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

String _en(String key) => AppStrings.get(key, 'en');

class _AuthedPartnerDataSource extends MockAuthDataSource {
  final String userId;
  _AuthedPartnerDataSource({required this.userId});

  @override
  Future<UserModel?> getCurrentUser() async => UserModel(
    uid: userId,
    email: 'partner@example.com',
    displayName: 'Dr. Partner',
    role: 'partner',
    createdAt: DateTime(2026, 1, 1),
  );
}

Future<void> pumpPendingScreen(
  WidgetTester tester, {
  PharmacyCubit? pharmacyCubit,
  MockAuthDataSource? authDataSource,
  Map<String, WidgetBuilder> routes = const {},
}) async {
  tester.view.physicalSize = const Size(800, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    withPartnerTestProviders(
      settingsCubit: buildTestSettingsCubit(prefs),
      pharmacyCubit: pharmacyCubit,
      authDataSource: authDataSource,
      child: MaterialApp(
        home: const PartnerPendingScreen(),
        routes: {
          '/home': (_) => const Scaffold(key: Key('home')),
          '/partner-profile': (_) => const Scaffold(key: Key('profile')),
          '/partner-license': (_) => const Scaffold(key: Key('license')),
          '/partner-rejected': (_) => const Scaffold(key: Key('rejected')),
          '/partner-dashboard': (_) => const Scaffold(key: Key('dashboard')),
          ...routes,
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PartnerPendingScreen', () {
    testWidgets(
      'renders pending text elements and status notice when no record exists',
      (tester) async {
        await pumpPendingScreen(tester);

        expect(find.text(_en('under_review')), findsOneWidget);
        expect(find.text(_en('pending_title')), findsOneWidget);
        expect(find.text(_en('pending_desc')), findsOneWidget);
        expect(find.text(_en('review_time')), findsOneWidget);
        expect(find.text(_en('check_status')), findsOneWidget);
        expect(find.text(_en('browse_app')), findsOneWidget);

        // Honesty notice when no persisted record exists
        expect(
          find.textContaining('No persisted pharmacy record exists yet'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays persisted pharmacy name when a pharmacy record exists',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-pending-1',
            name: 'Kigali Care Pharmacy',
            area: 'Kacyiru',
            district: 'Gasabo',
            phone: '+250788111222',
            email: 'kigali@care.rw',
            hours: '8:00 AM - 10:00 PM',
            latitude: -1.94,
            longitude: 30.06,
            ownerId: 'owner-123',
            status: 'pending',
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final repo = PharmacyRepositoryImpl(datasource: mockDataSource);
        final cubit = PharmacyCubit(
          getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
          getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
          createPharmacyUseCase: CreatePharmacyUseCase(repo),
          updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
          addStockItemUseCase: AddStockItemUseCase(repo),
          updateStockItemUseCase: UpdateStockItemUseCase(repo),
          deleteStockItemUseCase: DeleteStockItemUseCase(repo),
          watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
        );

        await cubit.loadPharmacy('owner-123');

        await pumpPendingScreen(tester, pharmacyCubit: cubit);

        expect(find.text('Kigali Care Pharmacy'), findsOneWidget);
        // Status notice should not appear when persisted record exists
        expect(
          find.textContaining('No persisted pharmacy record exists yet'),
          findsNothing,
        );
      },
    );

    testWidgets('check status navigates to profile if no pharmacy exists', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      final repo = PharmacyRepositoryImpl(datasource: mockDataSource);
      final cubit = PharmacyCubit(
        getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
        getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
        createPharmacyUseCase: CreatePharmacyUseCase(repo),
        updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
        addStockItemUseCase: AddStockItemUseCase(repo),
        updateStockItemUseCase: UpdateStockItemUseCase(repo),
        deleteStockItemUseCase: DeleteStockItemUseCase(repo),
        watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
      );

      final authSource = _AuthedPartnerDataSource(userId: 'owner-123');

      await pumpPendingScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: authSource,
      );

      await tester.tap(find.text(_en('check_status')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile')), findsOneWidget);
    });

    testWidgets('check status shows review snackbar when still pending (no bypass)', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-123',
          name: 'Pending Pharmacy',
          area: 'Remera',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'test@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'owner-123',
          status: 'pending',
          createdAt: DateTime(2026, 1, 1),
          submittedAt: DateTime(2026, 1, 2),
          licenseUrl: 'https://res.cloudinary.com/demo/raw/upload/lic.pdf',
          licensePublicId: 'lic_pub',
          rmohCertUrl: 'https://res.cloudinary.com/demo/raw/upload/rmoh.pdf',
          rmohCertPublicId: 'rmoh_pub',
        ),
      );
      final repo = PharmacyRepositoryImpl(datasource: mockDataSource);
      final cubit = PharmacyCubit(
        getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
        getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
        createPharmacyUseCase: CreatePharmacyUseCase(repo),
        updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
        addStockItemUseCase: AddStockItemUseCase(repo),
        updateStockItemUseCase: UpdateStockItemUseCase(repo),
        deleteStockItemUseCase: DeleteStockItemUseCase(repo),
        watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
      );

      final authSource = _AuthedPartnerDataSource(userId: 'owner-123');

      await pumpPendingScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: authSource,
      );

      await tester.tap(find.text(_en('check_status')));
      await tester.pumpAndSettle();

      expect(find.text('Verification is still under review.'), findsOneWidget);
      expect(find.byKey(const Key('dashboard')), findsNothing);
    });

    testWidgets('check status navigates to dashboard when approved', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-123',
          name: 'Approved Pharmacy',
          area: 'Remera',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'test@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'owner-123',
          status: 'approved',
          createdAt: DateTime(2026, 1, 1),
          submittedAt: DateTime(2026, 1, 2),
          licenseUrl: 'https://res.cloudinary.com/demo/raw/upload/lic.pdf',
          licensePublicId: 'lic_pub',
          rmohCertUrl: 'https://res.cloudinary.com/demo/raw/upload/rmoh.pdf',
          rmohCertPublicId: 'rmoh_pub',
        ),
      );
      final repo = PharmacyRepositoryImpl(datasource: mockDataSource);
      final cubit = PharmacyCubit(
        getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
        getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
        createPharmacyUseCase: CreatePharmacyUseCase(repo),
        updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
        addStockItemUseCase: AddStockItemUseCase(repo),
        updateStockItemUseCase: UpdateStockItemUseCase(repo),
        deleteStockItemUseCase: DeleteStockItemUseCase(repo),
        watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
      );

      final authSource = _AuthedPartnerDataSource(userId: 'owner-123');

      await pumpPendingScreen(
        tester,
        pharmacyCubit: cubit,
        authDataSource: authSource,
      );

      await tester.tap(find.text(_en('check_status')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard')), findsOneWidget);
    });

    testWidgets('browse app navigates to /home', (tester) async {
      await pumpPendingScreen(tester);

      await tester.tap(find.text(_en('browse_app')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home')), findsOneWidget);
    });
  });
}
