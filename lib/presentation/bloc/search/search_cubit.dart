import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/stock_item_model.dart';
import '../../../data/repositories/pharmacy_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final PharmacyRepository _pharmacyRepository;

  SearchCubit({required this._pharmacyRepository})
    : super(const SearchState());

  Future<void> searchMedicine(String query) async {
    if (query.trim().isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading, query: query.trim()));

    try {
      final results = await _pharmacyRepository.searchMedicine(query);
      emit(state.copyWith(status: SearchStatus.loaded, results: results));
    } catch (e) {
      emit(
        state.copyWith(status: SearchStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void clearSearch() {
    emit(const SearchState());
  }

  void selectResult(StockItemModel item) {
    emit(state.copyWith(selectedItem: item));
  }
}
