import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/pharmacy_entity.dart';
import '../../../domain/entities/stock_item_entity.dart';
import '../../../domain/usecases/pharmacy/add_stock_item_usecase.dart';
import '../../../domain/usecases/pharmacy/create_pharmacy_usecase.dart';
import '../../../domain/usecases/pharmacy/delete_stock_item_usecase.dart';
import '../../../domain/usecases/pharmacy/get_pharmacy_by_owner_usecase.dart';
import '../../../domain/usecases/pharmacy/get_pharmacy_stock_usecase.dart';
import '../../../domain/usecases/pharmacy/update_pharmacy_usecase.dart';
import '../../../domain/usecases/pharmacy/update_stock_item_usecase.dart';
import '../../../domain/usecases/pharmacy/watch_pharmacy_stock_usecase.dart';

part 'pharmacy_state.dart';

class PharmacyCubit extends Cubit<PharmacyState> {
  final GetPharmacyByOwnerUseCase getPharmacyByOwnerUseCase;
  final GetPharmacyStockUseCase getPharmacyStockUseCase;
  final CreatePharmacyUseCase createPharmacyUseCase;
  final UpdatePharmacyUseCase updatePharmacyUseCase;
  final AddStockItemUseCase addStockItemUseCase;
  final UpdateStockItemUseCase updateStockItemUseCase;
  final DeleteStockItemUseCase deleteStockItemUseCase;
  final WatchPharmacyStockUseCase watchPharmacyStockUseCase;

  StreamSubscription<List<StockItemEntity>>? _stockSubscription;

  PharmacyCubit({
    required this.getPharmacyByOwnerUseCase,
    required this.getPharmacyStockUseCase,
    required this.createPharmacyUseCase,
    required this.updatePharmacyUseCase,
    required this.addStockItemUseCase,
    required this.updateStockItemUseCase,
    required this.deleteStockItemUseCase,
    required this.watchPharmacyStockUseCase,
  }) : super(const PharmacyState());

  Future<void> loadPharmacy(String ownerId) async {
    emit(state.copyWith(status: PharmacyStatus.loading, clearError: true));
    try {
      final pharmacy = await getPharmacyByOwnerUseCase(ownerId);
      if (pharmacy != null) {
        final stock = await getPharmacyStockUseCase(pharmacy.id);
        emit(
          state.copyWith(
            status: PharmacyStatus.loaded,
            pharmacy: pharmacy,
            stockItems: stock,
            clearError: true,
          ),
        );
        await subscribeToStock(pharmacy.id);
      } else {
        await cancelStockSubscription();
        emit(
          state.copyWith(
            status: PharmacyStatus.noPharmacy,
            clearPharmacy: true,
            stockItems: const [],
            clearError: true,
          ),
        );
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

  Future<void> createPharmacy(PharmacyEntity pharmacy) async {
    emit(state.copyWith(status: PharmacyStatus.loading, clearError: true));
    try {
      final id = await createPharmacyUseCase(pharmacy);
      final created = pharmacy.id.isNotEmpty
          ? pharmacy
          : PharmacyEntity(
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
              acceptsInsurance: pharmacy.acceptsInsurance,
              createdAt: pharmacy.createdAt,
            );
      emit(
        state.copyWith(
          status: PharmacyStatus.loaded,
          pharmacy: created,
          stockItems: const [],
          clearError: true,
        ),
      );
      await subscribeToStock(created.id);
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updatePharmacy(PharmacyEntity pharmacy) async {
    try {
      await updatePharmacyUseCase(pharmacy);
      emit(
        state.copyWith(
          status: PharmacyStatus.loaded,
          pharmacy: pharmacy,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadStock(String pharmacyId) async {
    try {
      final stock = await getPharmacyStockUseCase(pharmacyId);
      emit(
        state.copyWith(
          status: PharmacyStatus.loaded,
          stockItems: stock,
          clearError: true,
        ),
      );
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
    await loadStock(pharmacy.id);
  }

  Future<void> addStockItem(StockItemEntity item) async {
    try {
      final id = await addStockItemUseCase(item);
      final newItem = item.id.isNotEmpty
          ? item
          : StockItemEntity(
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
      final exists = state.stockItems.any((s) => s.id == newItem.id);
      final updatedStock = exists
          ? state.stockItems
                .map((s) => s.id == newItem.id ? newItem : s)
                .toList()
          : [...state.stockItems, newItem];
      emit(
        state.copyWith(
          status: PharmacyStatus.loaded,
          stockItems: updatedStock,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateStockItem(StockItemEntity item) async {
    try {
      await updateStockItemUseCase(item);
      final updatedStock = state.stockItems
          .map((s) => s.id == item.id ? item : s)
          .toList();
      emit(
        state.copyWith(
          status: PharmacyStatus.loaded,
          stockItems: updatedStock,
          clearError: true,
        ),
      );
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
      await deleteStockItemUseCase(stockId);
      final updatedStock = state.stockItems
          .where((s) => s.id != stockId)
          .toList();
      emit(
        state.copyWith(
          status: PharmacyStatus.loaded,
          stockItems: updatedStock,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PharmacyStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> subscribeToStock(String pharmacyId) async {
    await _stockSubscription?.cancel();
    _stockSubscription = null;
    if (isClosed) return;

    _stockSubscription = watchPharmacyStockUseCase(pharmacyId).listen(
      (items) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: PharmacyStatus.loaded,
              stockItems: items,
              clearError: true,
            ),
          );
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: PharmacyStatus.error,
              errorMessage: error.toString(),
            ),
          );
        }
      },
    );
  }

  Future<void> cancelStockSubscription() async {
    await _stockSubscription?.cancel();
    _stockSubscription = null;
  }

  @override
  Future<void> close() async {
    await _stockSubscription?.cancel();
    _stockSubscription = null;
    return super.close();
  }
}
