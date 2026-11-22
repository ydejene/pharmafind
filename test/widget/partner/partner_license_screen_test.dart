import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmafind/core/constants/app_strings.dart';
import 'package:pharmafind/data/datasources/cloudinary_datasource.dart';
import 'package:pharmafind/data/datasources/mock_cloudinary_datasource.dart';
import 'package:pharmafind/data/datasources/mock_pharmacy_datasource.dart';
import 'package:pharmafind/data/models/pharmacy_model.dart';
import 'package:pharmafind/data/repositories/pharmacy_repository_impl.dart';
import 'package:pharmafind/domain/usecases/pharmacy/add_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/create_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/delete_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_by_owner_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/get_pharmacy_stock_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/submit_verification_documents_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_pharmacy_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/update_stock_item_usecase.dart';
import 'package:pharmafind/domain/usecases/pharmacy/watch_pharmacy_stock_usecase.dart';
import 'package:pharmafind/presentation/bloc/pharmacy/pharmacy_cubit.dart';
import 'package:pharmafind/presentation/screens/partner/partner_license_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'partner_test_helper.dart';

String _en(String key) => AppStrings.get(key, 'en');

base class _TestPlatformFile extends PlatformFile {
  @override
  final String name;
  final Uint8List bytes;

  _TestPlatformFile({required this.name, required this.bytes});

  @override
  Uri get uri => Uri.parse('file:///$name');

  @override
  Never get xFile => throw UnimplementedError();

  @override
  int? lengthSync() => bytes.length;

  @override
  Future<int?> length() async => bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

class _MockFilePickerPlatform extends FilePickerPlatform {
  PlatformFile? Function()? onPickFile;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    if (onPickFile != null) {
      return onPickFile!();
    }
    return null;
  }
}

PharmacyCubit _buildTestPharmacyCubit(
  MockPharmacyDataSource dataSource, [
  ICloudinaryDataSource? cloudinaryDataSource,
]) {
  final repo = PharmacyRepositoryImpl(
    datasource: dataSource,
    cloudinaryDatasource: cloudinaryDataSource,
  );
  return PharmacyCubit(
    getPharmacyByOwnerUseCase: GetPharmacyByOwnerUseCase(repo),
    getPharmacyStockUseCase: GetPharmacyStockUseCase(repo),
    createPharmacyUseCase: CreatePharmacyUseCase(repo),
    updatePharmacyUseCase: UpdatePharmacyUseCase(repo),
    addStockItemUseCase: AddStockItemUseCase(repo),
    updateStockItemUseCase: UpdateStockItemUseCase(repo),
    deleteStockItemUseCase: DeleteStockItemUseCase(repo),
    watchPharmacyStockUseCase: WatchPharmacyStockUseCase(repo),
    submitVerificationDocumentsUseCase:
        SubmitVerificationDocumentsUseCase(repo),
  );
}

Future<void> pumpLicenseScreen(
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
        home: const PartnerLicenseScreen(),
        routes: {
          '/partner-pending': (_) => const Scaffold(key: Key('pending')),
          ...routes,
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _MockFilePickerPlatform mockPicker;

  setUp(() {
    mockPicker = _MockFilePickerPlatform();
    FilePickerPlatform.instance = mockPicker;
  });

  group('PartnerLicenseScreen', () {
    testWidgets(
      'renders upload cards, prototype privacy notice, and initially disabled submit button',
      (tester) async {
        await pumpLicenseScreen(tester);

        expect(find.text(_en('verification')), findsOneWidget);
        expect(find.text(_en('upload_docs')), findsOneWidget);
        expect(find.text(_en('pharmacy_license')), findsWidgets);
        expect(find.text(_en('rmoh_cert')), findsOneWidget);

        // Prototype privacy notice
        expect(
          find.textContaining('Prototype Privacy Notice:'),
          findsOneWidget,
        );

        final submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNull);
      },
    );

    testWidgets('file selection updates card with filename and allows replacing files', (
      tester,
    ) async {
      int pickCount = 0;
      mockPicker.onPickFile = () {
        pickCount++;
        if (pickCount == 1) {
          return _TestPlatformFile(
            name: 'license_v1.pdf',
            bytes: Uint8List.fromList([1, 2, 3]),
          );
        } else {
          return _TestPlatformFile(
            name: 'license_v2.png',
            bytes: Uint8List.fromList([4, 5, 6]),
          );
        }
      };

      await pumpLicenseScreen(tester);

      // Tap first upload card
      await tester.tap(find.text(_en('upload_license')));
      await tester.pumpAndSettle();

      expect(find.text('license_v1.pdf (Tap to replace)'), findsOneWidget);

      // Tap again to replace
      await tester.tap(find.text('license_v1.pdf (Tap to replace)'));
      await tester.pumpAndSettle();

      expect(find.text('license_v2.png (Tap to replace)'), findsOneWidget);
    });

    testWidgets(
      'submit button enables only when both documents are selected',
      (tester) async {
        mockPicker.onPickFile = () => _TestPlatformFile(
              name: 'document.pdf',
              bytes: Uint8List.fromList([1, 2, 3]),
            );

        await pumpLicenseScreen(tester);

        // Tap first upload card (Pharmacy License)
        await tester.tap(find.text(_en('upload_license')));
        await tester.pumpAndSettle();

        // Still disabled because second doc is not selected
        var submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNull);

        // Tap second upload card (RMOH Certificate)
        await tester.tap(find.text(_en('upload_rmoh')));
        await tester.pumpAndSettle();

        // Now enabled
        submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNotNull);
      },
    );

    testWidgets('shows error when submitting without a persisted pharmacy profile', (
      tester,
    ) async {
      mockPicker.onPickFile = () => _TestPlatformFile(
            name: 'doc.pdf',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

      await pumpLicenseScreen(tester);

      // Pick both files
      await tester.tap(find.text(_en('upload_license')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_en('upload_rmoh')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en('submit_review')));
      await tester.pumpAndSettle();

      expect(
        find.text('No pharmacy profile found. Please register your pharmacy profile first.'),
        findsOneWidget,
      );
    });

    testWidgets('submitting both documents persists metadata and navigates to /partner-pending', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-test-1',
          name: 'Test Pharmacy',
          area: 'Remera',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'test@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'owner-test-1',
          status: 'pending',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final cubit = _buildTestPharmacyCubit(mockDataSource);
      await cubit.loadPharmacy('owner-test-1');

      mockPicker.onPickFile = () => _TestPlatformFile(
            name: 'sample_doc.pdf',
            bytes: Uint8List.fromList([1, 2, 3, 4]),
          );

      await pumpLicenseScreen(tester, pharmacyCubit: cubit);

      await tester.tap(find.text(_en('upload_license')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_en('upload_rmoh')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en('submit_review')));
      await tester.pump(); // Start submission
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pending')), findsOneWidget);
    });

    testWidgets('upload error keeps user on license screen and displays error snackbar', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-test-err',
          name: 'Err Pharmacy',
          area: 'Remera',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'test@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'owner-err',
          status: 'pending',
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final mockCloudinary = MockCloudinaryDataSource()
        ..shouldThrow = true
        ..errorMessage = 'Cloudinary upload timed out';
      final cubit = _buildTestPharmacyCubit(mockDataSource, mockCloudinary);
      await cubit.loadPharmacy('owner-err');

      mockPicker.onPickFile = () => _TestPlatformFile(
            name: 'test.pdf',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

      await pumpLicenseScreen(tester, pharmacyCubit: cubit);

      await tester.tap(find.text(_en('upload_license')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_en('upload_rmoh')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(_en('submit_review')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.textContaining('Cloudinary upload timed out'), findsOneWidget);
      // Remained on license screen
      expect(find.byKey(const Key('pending')), findsNothing);
    });

    testWidgets(
      'displays existing documents on file and enables submit when only one replacement is selected',
      (tester) async {
        final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
        await mockDataSource.createPharmacy(
          PharmacyModel(
            id: 'pharm-test-resub',
            name: 'Resubmission Pharmacy',
            area: 'Remera',
            district: 'Gasabo',
            phone: '+250788111222',
            email: 'test@pharm.rw',
            hours: '8:00 AM - 10:00 PM',
            latitude: -1.94,
            longitude: 30.06,
            ownerId: 'owner-resub',
            status: 'rejected',
            rejectionReason: 'RMOH certificate blurry',
            licenseUrl: 'https://res.cloudinary.com/test/raw/upload/valid_license.pdf',
            licensePublicId: 'partner-verification/valid_license.pdf',
            rmohCertUrl: 'https://res.cloudinary.com/test/raw/upload/blurry_rmoh.pdf',
            rmohCertPublicId: 'partner-verification/blurry_rmoh.pdf',
            submittedAt: DateTime(2026, 1, 1),
            reviewedAt: DateTime(2026, 1, 2),
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        final cubit = _buildTestPharmacyCubit(mockDataSource);
        await cubit.loadPharmacy('owner-resub');

        mockPicker.onPickFile = () => _TestPlatformFile(
              name: 'replacement_rmoh.pdf',
              bytes: Uint8List.fromList([7, 8, 9]),
            );

        await pumpLicenseScreen(tester, pharmacyCubit: cubit);

        // Both documents should indicate they are on file
        expect(find.text('ON FILE'), findsNWidgets(2));
        expect(find.textContaining('valid_license.pdf (Tap to replace)'), findsOneWidget);
        expect(find.textContaining('blurry_rmoh.pdf (Tap to replace)'), findsOneWidget);

        // Submit initially disabled before any replacement is selected
        var submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNull);

        // Select replacement ONLY for RMOH certificate
        await tester.tap(find.textContaining('blurry_rmoh.pdf (Tap to replace)'));
        await tester.pumpAndSettle();

        expect(find.text('replacement_rmoh.pdf (Tap to replace)'), findsOneWidget);

        // Submit button is now enabled (only 1 file replaced, license on file is kept)
        submitBtn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, _en('submit_review')),
        );
        expect(submitBtn.onPressed, isNotNull);

        // Submit the replacement
        await tester.tap(find.text(_en('submit_review')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        // Navigates to pending review
        expect(find.byKey(const Key('pending')), findsOneWidget);

        // Verify datasource: RMOH was replaced, license was preserved, reviewer fields protected
        final persisted = await mockDataSource.getPharmacy('pharm-test-resub');
        expect(persisted?.rmohCertUrl, contains('replacement_rmoh.pdf'));
        expect(persisted?.licenseUrl, contains('valid_license.pdf'));
        expect(persisted?.status, 'rejected'); // Not modified by client
        expect(persisted?.rejectionReason, 'RMOH certificate blurry');
        expect(persisted?.submittedAt, isNotNull);
        expect(persisted?.submittedAt!.isAfter(persisted.reviewedAt!), isTrue);
      },
    );

    testWidgets('allows retry after upload failure without losing selected file', (
      tester,
    ) async {
      final mockDataSource = MockPharmacyDataSource(seedInitialData: false);
      await mockDataSource.createPharmacy(
        PharmacyModel(
          id: 'pharm-test-retry',
          name: 'Retry Pharmacy',
          area: 'Remera',
          district: 'Gasabo',
          phone: '+250788111222',
          email: 'test@pharm.rw',
          hours: '8:00 AM - 10:00 PM',
          latitude: -1.94,
          longitude: 30.06,
          ownerId: 'owner-retry',
          status: 'rejected',
          licenseUrl: 'https://res.cloudinary.com/test/raw/upload/license.pdf',
          licensePublicId: 'partner-verification/license.pdf',
          rmohCertUrl: 'https://res.cloudinary.com/test/raw/upload/rmoh.pdf',
          rmohCertPublicId: 'partner-verification/rmoh.pdf',
          submittedAt: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
        ),
      );

      final mockCloudinary = MockCloudinaryDataSource()
        ..shouldThrow = true
        ..errorMessage = 'Network connection failed';
      final cubit = _buildTestPharmacyCubit(mockDataSource, mockCloudinary);
      await cubit.loadPharmacy('owner-retry');

      mockPicker.onPickFile = () => _TestPlatformFile(
            name: 'replacement.pdf',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

      await pumpLicenseScreen(tester, pharmacyCubit: cubit);

      // Select replacement RMOH
      await tester.tap(find.textContaining('rmoh.pdf (Tap to replace)'));
      await tester.pumpAndSettle();

      // Submit fails
      await tester.tap(find.text(_en('submit_review')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.textContaining('Network connection failed'), findsOneWidget);
      // Selected file is STILL retained on screen!
      expect(find.text('replacement.pdf (Tap to replace)'), findsOneWidget);

      // Now fix network and retry without re-picking
      mockCloudinary.shouldThrow = false;
      await tester.tap(find.text(_en('submit_review')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('pending')), findsOneWidget);
    });
  });
}
