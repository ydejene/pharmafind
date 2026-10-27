import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/pharmacy_model.dart';
import '../../../data/models/stock_item_model.dart';
import '../../../data/repositories/pharmacy_repository.dart';

part 'pharmacy_state.dart';

class PharmacyCubit extends Cubit<PharmacyState> {
  final PharmacyRepository _pharmacyRepository;

  PharmacyCubit({required this._pharmacyRepository})
    : super(const PharmacyState());

  Future<void> loadPharmacy(String ownerId) async {
    emit(state.copyWith(status: PharmacyStatus.loading));
    try {
      final pharmacy = await _pharmacyRepository.getPharmacyByOwner(ownerId);
      if (pharmacy != null) {
        final stock = await _pharmacyRepository.getPharmacyStock(pharmacy.id);
        emit(
          state.copyWith(
            status: PharmacyStatus.loaded,
            pharmacy: pharmacy,
            stockItems: stock,
          ),
        );
      } else {
        emit(state.copyWith(status: PharmacyStatus.noPharmacy));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> createPharmacy(PharmacyModel pharmacy) async {
    emit(state.copyWith(status: PharmacyStatus.loading));
    try {
      final id = await _pharmacyRepository.createPharmacy(pharmacy);
      final created = PharmacyModel(
        id: id,
        name: pharmacy.name,
        area: pharmacy.area,
        district: pharmacy.district,
        phone: pharmacy.phone,
        email: pharmacy.email,
        hours: pharmacy.hours,
        latitude: pharmacy.latitude,
        longitude: pharmacy.longitude,
        ownerId: pharmacy.ownerId,
        status: pharmacy.status,
        createdAt: pharmacy.createdAt,
      );
      emit(state.copyWith(status: PharmacyStatus.loaded, pharmacy: created));
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updatePharmacy(PharmacyModel pharmacy) async {
    try {
      await _pharmacyRepository.updatePharmacy(pharmacy);
      emit(state.copyWith(pharmacy: pharmacy));
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> addStockItem(StockItemModel item) async {
    try {
      final id = await _pharmacyRepository.addStockItem(item);
      final newItem = StockItemModel(
        id: id,
        pharmacyId: item.pharmacyId,
        pharmacyName: item.pharmacyName,
        pharmacyArea: item.pharmacyArea,
        pharmacyPhone: item.pharmacyPhone,
        pharmacyHours: item.pharmacyHours,
        pharmacyLat: item.pharmacyLat,
        pharmacyLng: item.pharmacyLng,
        medicineName: item.medicineName,
        status: item.status,
        quantity: item.quantity,
        price: item.price,
        updatedAt: item.updatedAt,
      );
      final updatedStock = [...state.stockItems, newItem];
      emit(state.copyWith(stockItems: updatedStock));
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateStockItem(StockItemModel item) async {
    try {
      await _pharmacyRepository.updateStockItem(item);
      final updatedStock = state.stockItems
          .map((s) => s.id == item.id ? item : s)
          .toList();
      emit(state.copyWith(stockItems: updatedStock));
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> deleteStockItem(String stockId) async {
    try {
      await _pharmacyRepository.deleteStockItem(stockId);
      final updatedStock = state.stockItems
          .where((s) => s.id != stockId)
          .toList();
      emit(state.copyWith(stockItems: updatedStock));
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refreshStock() async {
    final pharmacy = state.pharmacy;
    if (pharmacy == null) return;
    try {
      final stock = await _pharmacyRepository.getPharmacyStock(pharmacy.id);
      emit(state.copyWith(stockItems: stock));
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
