import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/repository.dart';
import 'package:lootbazarweb/providerd/Products/ProductState.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
import 'package:rxdart/rxdart.dart';

class SearchProductNotifier extends StateNotifier<ProductState> {
  final Repository _repository;

  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  StreamSubscription<String>? _searchSubscription;

  static const int _limit = 15;

  SearchProductNotifier(this._repository) : super(const ProductState()) {
    _initSearchDebounce();
  }

  void _initSearchDebounce() {
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 800))
        .distinct()
        .listen((query) {
      if (query.isNotEmpty) {
        _fetchWithSearch(query);
      }
    });
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    if (query.trim().isEmpty) {
      // Query clear hone par products bhi clear karo
      state = state.copyWith(
        products: [],
        searchQuery: '',
        isLoading: false,
        errorMessage: null,
        hasMore: false,
      );
      return;
    }
    _searchSubject.add(query.trim());
  }

  Future<void> _fetchWithSearch(String query) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      currentPage: 1,
      hasMore: true,
      errorMessage: null,
      products: [],
      searchQuery: query,
    );
    try {
      final response = await _repository.getProducts(
        page: 1,
        limit: _limit,
        search: query,
      );
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        products: response.products,
        currentPage: 1,
        hasMore: response.products.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMoreProducts() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;
    if (state.searchQuery.isEmpty) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getProducts(
        page: nextPage,
        limit: _limit,
        search: state.searchQuery,
      );
      state = state.copyWith(
        isLoadingMore: false,
        currentPage: nextPage,
        products: [...state.products, ...response.products],
        hasMore: response.products.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchNow(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        products: [],
        searchQuery: '',
        isLoading: false,
      );
      return;
    }
    await _fetchWithSearch(query);
  }

  Future<void> retry() async {
    if (state.searchQuery.isNotEmpty) {
      await _fetchWithSearch(state.searchQuery);
    }
  }

  void clearSearch() {
    state = const ProductState(); // full reset
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    super.dispose();
  }
}

// ← autoDispose — screen close hote hi destroy ho jaayega
final searchProductProvider =
StateNotifierProvider.autoDispose<SearchProductNotifier, ProductState>(
      (ref) {
    final repository = ref.watch(repositoryProvider);
    return SearchProductNotifier(repository);
  },
);