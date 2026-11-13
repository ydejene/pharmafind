part of 'pharmacy_cubit.dart';

enum PharmacyStatus { initial, loading, loaded, noPharmacy, error }

class PharmacyState extends Equatable {
  final PharmacyStatus status;
  final PharmacyEntity? pharmacy;
  final List<StockItemEntity> stockItems;
  final String? errorMessage;

  const PharmacyState({
    this.status = PharmacyStatus.initial,
    this.pharmacy,
    this.stockItems = const [],
    this.errorMessage,
  });

  PharmacyState copyWith({
    PharmacyStatus? status,
    PharmacyEntity? pharmacy,
    bool clearPharmacy = false,
    List<StockItemEntity>? stockItems,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PharmacyState(
      status: status ?? this.status,
      pharmacy: clearPharmacy ? null : (pharmacy ?? this.pharmacy),
      stockItems: stockItems ?? this.stockItems,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, pharmacy, stockItems, errorMessage];
}

