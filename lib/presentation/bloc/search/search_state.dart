part of 'search_cubit.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final String query;
  final List<StockItemEntity> results;
  final StockItemEntity? selectedItem;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.query = '',
    this.results = const [],
    this.selectedItem,
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? query,
    List<StockItemEntity>? results,
    StockItemEntity? selectedItem,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      selectedItem: selectedItem ?? this.selectedItem,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    query,
    results,
    selectedItem,
    errorMessage,
  ];
}
