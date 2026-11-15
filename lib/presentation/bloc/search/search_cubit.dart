import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/stock_item_entity.dart';
import '../../../domain/usecases/pharmacy/search_medicine_usecase.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMedicineUseCase searchMedicineUseCase;

  SearchCubit({required this.searchMedicineUseCase})
    : super(const SearchState());

  Future<void> searchMedicine(String query) async {
    if (query.trim().isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading, query: query.trim()));

    try {
      final results = await searchMedicineUseCase(query);
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

  void selectResult(StockItemEntity item) {
    emit(state.copyWith(selectedItem: item));
  }
}
