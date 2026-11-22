import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/auth_routes.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';
import 'package:pharmafind/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmafind/domain/entities/pharmacy_entity.dart';
import 'package:pharmafind/domain/usecases/pharmacy/add_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/create_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/delete_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_by_owner_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_stock_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/watch_pharmacy_stock_usecase.dart';
import 'package:pharmafind/presentation/bloc/pharmacy/pharmacy_cubit.dart';
import 'package:pharmafind/presentation/utils/partner_navigation.dart';

class _FailingPharmacyDataSource extends MockPharmacyDataSource {
  _FailingPharmacyDataSource() : super(seedInitialData: false);

  @override
  Future<PharmacyModel?> getPharmacyByOwner(String ownerId) async {
    throw Exception('Firestore offline');
  }
}

void main() {
  group('PartnerNavigation.getPartnerDestination', () {
    PharmacyEntity createTestPharmacy({
      String id = 'pharm-123',
      String status = 'pending',
      String? licenseUrl = 'https://res.cloudinary.com/demo/raw/upload/license.pdf',
      String? rmohCertUrl = 'https://res.cloudinary.com/demo/raw/upload/rmoh.pdf',
      DateTime? submittedAt,
      String? rejectionReason,
    }) {
      return PharmacyEntity(
        id: id,
        name: 'Test Pharmacy',
        area: 'Remera',
        district: 'Gasabo',
        phone: '+250788000000',
        email: 'test@pharmacy.rw',
        latitude: -1.9441,
        longitude: 30.0619,
        status: status,
        ownerId: 'owner-123',
        createdAt: DateTime(2026, 1, 1),
        licenseUrl: licenseUrl,
        licensePublicId: licenseUrl != null ? 'lic_pub_1' : null,
        rmohCertUrl: rmohCertUrl,
        rmohCertPublicId: rmohCertUrl != null ? 'rmoh_pub_1' : null,
        submittedAt: submittedAt ?? DateTime(2026, 1, 2),
        rejectionReason: rejectionReason,
      );
    }

    test('returns partnerProfile when pharmacy is null', () {
      final destination = PartnerNavigation.getPartnerDestination(null);
      expect(destination, AuthRoutes.partnerProfile);
    });

    test('returns partnerProfile when pharmacy id is empty', () {
      final pharmacy = createTestPharmacy(id: '');
      final destination = PartnerNavigation.getPartnerDestination(pharmacy);
      expect(destination, AuthRoutes.partnerProfile);
    });

    test('returns partnerLicense when submittedAt is null', () {
      final pharmacy = PharmacyEntity(
        id: 'pharm-123',
        name: 'Test Pharmacy',
        area: 'Remera',
        phone: '+250788000000',
        email: 'test@pharmacy.rw',
        latitude: -1.9441,
        longitude: 30.0619,
        status: 'pending',
        ownerId: 'owner-123',
        createdAt: DateTime(2026, 1, 1),
        submittedAt: null,
      );
      final destination = PartnerNavigation.getPartnerDestination(pharmacy);
      expect(destination, AuthRoutes.partnerLicense);
    });

    test('returns partnerLicense when licenseUrl is null or empty', () {
      final pharmacyNull = createTestPharmacy(licenseUrl: null);
      expect(PartnerNavigation.getPartnerDestination(pharmacyNull), AuthRoutes.partnerLicense);

      final pharmacyEmpty = createTestPharmacy(licenseUrl: '');
      expect(PartnerNavigation.getPartnerDestination(pharmacyEmpty), AuthRoutes.partnerLicense);
    });

    test('returns partnerLicense when rmohCertUrl is null or empty', () {
      final pharmacyNull = createTestPharmacy(rmohCertUrl: null);
      expect(PartnerNavigation.getPartnerDestination(pharmacyNull), AuthRoutes.partnerLicense);

      final pharmacyEmpty = createTestPharmacy(rmohCertUrl: '');
      expect(PartnerNavigation.getPartnerDestination(pharmacyEmpty), AuthRoutes.partnerLicense);
    });

    test('returns partnerRejected when status is rejected', () {
      final pharmacy = createTestPharmacy(
        status: 'rejected',
        rejectionReason: 'Invalid license document',
      );
      final destination = PartnerNavigation.getPartnerDestination(pharmacy);
      expect(destination, AuthRoutes.partnerRejected);
    });

    test('returns partnerDashboard when status is approved', () {
      final pharmacy = createTestPharmacy(status: 'approved');
      final destination = PartnerNavigation.getPartnerDestination(pharmacy);
      expect(destination, AuthRoutes.partnerDashboard);
    });

    test('returns partnerPending when submitted and status is pending', () {
      final pharmacy = createTestPharmacy(status: 'pending');
      final destination = PartnerNavigation.getPartnerDestination(pharmacy);
      expect(destination, AuthRoutes.partnerPending);
    });
  });

  group('PartnerNavigation.routePartner', () {
    late MockPharmacyDataSource mockDataSource;
    late PharmacyRepositoryImpl repo;
    late PharmacyCubit cubit;

    setUp(() {
      mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      repo = PharmacyRepositoryImpl(datasource: mockDataSource);
      cubit = PharmacyCubit(
        getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
        getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
        createPharmacyUseCase: CreatePharmacyUseCase(repo),
        updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
        addStockItemUseCase: AddStockItemUseCase(repo),
        updateStockItemUseCase: UpdateStockItemUseCase(repo),
        deleteStockItemUseCase: DeleteStockItemUseCase(repo),
        watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
      );
    });

    tearDown(() {
      cubit.close();
    });

    Widget buildTestApp({required Widget child}) {
      return BlocProvider<PharmacyCubit>.value(
        value: cubit,
        child: MaterialApp(
          routes: {
            AuthRoutes.partnerProfile: (_) => const Scaffold(key: Key('profile_target')),
            AuthRoutes.partnerLicense: (_) => const Scaffold(key: Key('license_target')),
            AuthRoutes.partnerPending: (_) => const Scaffold(key: Key('pending_target')),
            AuthRoutes.partnerRejected: (_) => const Scaffold(key: Key('rejected_target')),
            AuthRoutes.partnerDashboard: (_) => const Scaffold(key: Key('dashboard_target')),
          },
          home: child,
        ),
      );
    }

    testWidgets('routes to partnerProfile when no pharmacy genuinely exists', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PartnerNavigation.routePartner(context, 'owner-new'),
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('profile_target')), findsOneWidget);
    });

    testWidgets('routes to partnerDashboard when pharmacy exists and is approved', (tester) async {
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-app-1',
          name: 'Approved Pharmacy',
          area: 'Kacyiru',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'app@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'owner-app',
          status: 'approved',
          createdAt: DateTime(2026, 1, 1),
          submittedAt: DateTime(2026, 1, 2),
          licenseUrl: 'https://res.cloudinary.com/demo/raw/upload/lic.pdf',
          licensePublicId: 'lic_pub',
          rmohCertUrl: 'https://res.cloudinary.com/demo/raw/upload/rmoh.pdf',
          rmohCertPublicId: 'rmoh_pub',
        ),
      );

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PartnerNavigation.routePartner(context, 'owner-app'),
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dashboard_target')), findsOneWidget);
    });

    testWidgets('waits for in-progress loading instead of treating null as missing', (tester) async {
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-pend-1',
          name: 'Pending Pharmacy',
          area: 'Kacyiru',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'app@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'owner-wait',
          status: 'pending',
          createdAt: DateTime(2026, 1, 1),
          submittedAt: DateTime(2026, 1, 2),
          licenseUrl: 'https://res.cloudinary.com/demo/raw/upload/lic.pdf',
          licensePublicId: 'lic_pub',
          rmohCertUrl: 'https://res.cloudinary.com/demo/raw/upload/rmoh.pdf',
          rmohCertPublicId: 'rmoh_pub',
        ),
      );

      // Trigger load which emits loading
      cubit.loadPharmacy('owner-wait');

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PartnerNavigation.routePartner(context, 'owner-wait'),
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Successfully waited and routed to pending, NOT profile!
      expect(find.byKey(const Key('pending_target')), findsOneWidget);
      expect(find.byKey(const Key('profile_target')), findsNothing);
    });

    testWidgets('shows error snackbar with retry when fetch fails and does not navigate', (tester) async {
      final failingDataSource = _FailingPharmacyDataSource();
      final failingRepo = PharmacyRepositoryImpl(datasource: failingDataSource);
      final failingCubit = PharmacyCubit(
        getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(failingRepo),
        getPharmacyStockUseCase: GetPharmacyStockUseCase(failingRepo),
        createPharmacyUseCase: CreatePharmacyUseCase(failingRepo),
        updatePharmacyUseCase: UpdatePharmacyUseCase(failingRepo),
        addStockItemUseCase: AddStockItemUseCase(failingRepo),
        updateStockItemUseCase: UpdateStockItemUseCase(failingRepo),
        deleteStockItemUseCase: DeleteStockItemUseCase(failingRepo),
        watchPharmacyStockUseCase: WatchPharmacyStockUseCase(failingRepo),
      );
      addTearDown(failingCubit.close);

      await tester.pumpWidget(
        BlocProvider<PharmacyCubit>.value(
          value: failingCubit,
          child: MaterialApp(
            routes: {
              AuthRoutes.partnerProfile: (_) => const Scaffold(key: Key('profile_target')),
              AuthRoutes.partnerDashboard: (_) => const Scaffold(key: Key('dashboard_target')),
            },
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PartnerNavigation.routePartner(context, 'owner-err'),
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Firestore offline'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      // Did NOT navigate anywhere
      expect(find.byKey(const Key('profile_target')), findsNothing);
      expect(find.byKey(const Key('dashboard_target')), findsNothing);
    });

    testWidgets('prevents using stale pharmacy data from a different user', (tester) async {
      // Current cubit state has a pharmacy belonging to 'other-user'
      cubit.emit(
        cubit.state.copyWith(
          status: PharmacyStatus.loaded,
          pharmacy: PharmacyEntity(
            id: 'pharm-other',
            name: 'Other Pharmacy',
            area: 'Remera',
            district: 'Gasabo',
            phone: '+250788000000',
            email: 'other@pharm.rw',
            hours: '8:00 AM - 10:00 PM',
            latitude: -1.94,
            longitude: 30.06,
            ownerId: 'other-user',
            status: 'approved',
            createdAt: DateTime(2026, 1, 1),
            submittedAt: DateTime(2026, 1, 2),
            licenseUrl: 'https://res.cloudinary.com/demo/raw/upload/lic.pdf',
            licensePublicId: 'lic_pub',
            rmohCertUrl: 'https://res.cloudinary.com/demo/raw/upload/rmoh.pdf',
            rmohCertPublicId: 'rmoh_pub',
          ),
        ),
      );

      // In database, 'current-user' has no pharmacy record yet
      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PartnerNavigation.routePartner(context, 'current-user'),
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Detected stale data, reloaded for 'current-user', and navigated to profile (not dashboard!)
      expect(find.byKey(const Key('profile_target')), findsOneWidget);
      expect(find.byKey(const Key('dashboard_target')), findsNothing);
    });
  });
}
