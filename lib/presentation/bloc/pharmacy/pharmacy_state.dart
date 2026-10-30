part of 'pharmacy_cubit.dart';

enum PharmacyStatus { initial, loading, loaded, noPharmacy, error }

class PharmacyState extends Equatable {
  final PharmacyStatus status;
  final PharmacyModel? pharmacy;
  final List<StockItemModel> stockItems;
  final String? errorMessage;

  const PharmacyState({
    this.status = PharmacyStatus.initial,
    this.pharmacy,
    this.stockItems = const [],
    this.errorMessage,
  });

  PharmacyState copyWith({
    PharmacyStatus? status,
    PharmacyModel? pharmacy,
    List<StockItemModel>? stockItems,
    String? errorMessage,
  }) {
    return PharmacyState(
      status: status ?? this.status,
      pharmacy: pharmacy ?? this.pharmacy,
      stockItems: stockItems ?? this.stockItems,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, pharmacy, stockItems, errorMessage];
}
