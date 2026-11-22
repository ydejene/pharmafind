import 'dart:typed_data';

import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/entities/stock_item_entity.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/cloudinary_datasource.dart';
import '../datasources/mock_cloudinary_datasource.dart';
import '../datasources/pharmacy_datasource.dart';
import '../models/pharmacy_model.dart';
import '../models/stock_item_model.dart';

class PharmacyRepositoryImpl implements IPharmacyRepository {
  final IPharmacyDataSource datasource;
  final ICloudinaryDataSource cloudinaryDatasource;

  PharmacyRepositoryImpl({
    required this.datasource,
    ICloudinaryDataSource? cloudinaryDatasource,
  }) : cloudinaryDatasource =
           cloudinaryDatasource ?? MockCloudinaryDataSource();

  @override
  Future<String> createPharmacy(PharmacyEntity pharmacy) {
    return datasource.createPharmacy(PharmacyModel.fromEntity(pharmacy));
  }

  @override
  Future<void> updatePharmacy(PharmacyEntity pharmacy) {
    return datasource.updatePharmacy(PharmacyModel.fromEntity(pharmacy));
  }

  @override
  Future<void> deletePharmacy(String pharmacyId) {
    return datasource.deletePharmacy(pharmacyId);
  }

  @override
  Future<PharmacyEntity?> getPharmacy(String pharmacyId) async {
    final model = await datasource.getPharmacy(pharmacyId);
    return model?.toEntity();
  }

  @override
  Future<List<PharmacyEntity>> getApprovedPharmacies() async {
    final models = await datasource.getApprovedPharmacies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PharmacyEntity?> getPharmacyByOwner(String ownerId) async {
    final model = await datasource.getPharmacyByOwner(ownerId);
    return model?.toEntity();
  }

  @override
  Future<List<StockItemEntity>> searchMedicine(String query) async {
    final models = await datasource.searchMedicine(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<String> addStockItem(StockItemEntity item) {
    return datasource.addStockItem(StockItemModel.fromEntity(item));
  }

  @override
  Future<void> updateStockItem(StockItemEntity item) {
    return datasource.updateStockItem(StockItemModel.fromEntity(item));
  }

  @override
  Future<void> deleteStockItem(String stockId) {
    return datasource.deleteStockItem(stockId);
  }

  @override
  Future<List<StockItemEntity>> getPharmacyStock(String pharmacyId) async {
    final models = await datasource.getPharmacyStock(pharmacyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<StockItemEntity>> watchPharmacyStock(String pharmacyId) {
    return datasource
        .watchPharmacyStock(pharmacyId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<PharmacyEntity> submitVerificationDocuments({
    required String pharmacyId,
    required Uint8List licenseBytes,
    required String licenseFilename,
    required Uint8List rmohBytes,
    required String rmohFilename,
  }) async {
    final licenseResult = await cloudinaryDatasource.uploadDocument(
      licenseBytes,
      licenseFilename,
    );
    final rmohResult = await cloudinaryDatasource.uploadDocument(
      rmohBytes,
      rmohFilename,
    );

    final existing = await datasource.getPharmacy(pharmacyId);
    if (existing == null) {
      throw Exception('Pharmacy with id $pharmacyId not found');
    }

    final updated = existing.copyWith(
      licenseUrl: licenseResult.secureUrl,
      licensePublicId: licenseResult.publicId,
      rmohCertUrl: rmohResult.secureUrl,
      rmohCertPublicId: rmohResult.publicId,
      submittedAt: DateTime.now(),
    );

    await datasource.updatePharmacy(updated);
    return updated.toEntity();
  }
}
