import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';
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
import 'package:pharmafind/presentation/screens/partner/partner_rejected_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

String _en(String key) => AppStrings.get(key, 'en');

Future<void> pumpRejectedScreen(
  WidgetTester tester, {
  PharmacyCubit? pharmacyCubit,
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
      child: MaterialApp(
        home: const PartnerRejectedScreen(),
        routes: {
          '/partner-profile': (_) =>
              const Scaffold(key: Key('partner_profile_screen')),
          '/partner-dashboard': (_) =>
              const Scaffold(key: Key('partner_dashboard_screen')),
          ...routes,
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PartnerRejectedScreen', () {
    testWidgets(
      'renders action needed, rejection checklist, and honest notice',
      (tester) async {
        await pumpRejectedScreen(tester);

        expect(find.text(_en('action_needed')), findsOneWidget);
        expect(find.text(_en('rejected_title')), findsOneWidget);
        expect(find.text(_en('rejected_desc')), findsOneWidget);
        expect(find.text(_en('what_to_check')), findsOneWidget);
        expect(find.text(_en('readable')), findsOneWidget);
        expect(find.text(_en('not_expired')), findsOneWidget);
        expect(find.text(_en('full_visible')), findsOneWidget);
        expect(find.text(_en('edit_pharmacy_info')), findsOneWidget);
        expect(find.text(_en('pharmacy_dashboard')), findsOneWidget);

        expect(
          find.textContaining(
            'Automated document resubmission is currently unavailable',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'displays persisted pharmacy name when a rejected record exists',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-rej-1',
            name: 'City Central Pharmacy',
            area: 'Nyarugenge',
            district: 'Nyarugenge',
            phone: '+250788333444',
            email: 'city@pharma.rw',
            hours: '8:00 AM - 10:00 PM',
            latitude: -1.95,
            longitude: 30.05,
            ownerId: 'owner-rej-1',
            status: 'rejected',
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

        await cubit.loadPharmacy('owner-rej-1');

        await pumpRejectedScreen(tester, pharmacyCubit: cubit);

        expect(find.text('City Central Pharmacy'), findsOneWidget);
      },
    );

    testWidgets('edit pharmacy info button navigates to /partner-profile', (
      tester,
    ) async {
      await pumpRejectedScreen(tester);

      await tester.tap(find.text(_en('edit_pharmacy_info')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('partner_profile_screen')), findsOneWidget);
    });

    testWidgets('dashboard button navigates to /partner-dashboard', (
      tester,
    ) async {
      await pumpRejectedScreen(tester);

      await tester.tap(find.text(_en('pharmacy_dashboard')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('partner_dashboard_screen')), findsOneWidget);
    });
  });
}
