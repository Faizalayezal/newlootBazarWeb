import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/repository.dart';
import 'package:lootbazarweb/providerd/Products/product_state.dart';
import 'package:lootbazarweb/providerd/di/repository_provider.dart';
import 'package:rxdart/rxdart.dart';

class CategoryviseProductnotifier extends StateNotifier<ProductState> {
  final Repository _repository;

  // ── RxDart search subject ──────────────────────────────────────────────────
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  StreamSubscription<String>? _searchSubscription;
  // ──────────────────────────────────────────────────────────────────────────

  static const int _limit = 15;
  String? _selectedCategoryId;

  CategoryviseProductnotifier(this._repository) : super(const ProductState()) {
    _initSearchDebounce();
  }

  void _initSearchDebounce() {
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 1000))
        .distinct()
        .listen((query) {
      _fetchWithSearch(query, _selectedCategoryId);
    });
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query);
    _searchSubject.add(query.trim());
  }
  /// Internal — called by debounce after idle period
  Future<void> _fetchWithSearch(
      String query,
      String? categoryIds,
      ) async {
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
        categoryId: categoryIds,
        search: query.isEmpty ? null : query,
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

  Future<void> getCategoryProducts({String? categoryIds}) async {
    _selectedCategoryId = categoryIds;
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      currentPage: 1,
      hasMore: true,
      errorMessage: null,
    );
    try {
      final response = await _repository.getProducts(
        page: 1,
        limit: _limit,
        categoryId: categoryIds,
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

  /// ===========================
  /// Load Next Page
  /// ===========================
  Future<void> loadMoreCategoryProducts({String? categoryIds}) async {
    /// Already loading
    if (state.isLoadingMore) return;

    /// First page loading
    if (state.isLoading) return;

    /// No more data
    if (!state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final nextPage = state.currentPage + 1;

      final response = await _repository.getProducts(
        page: nextPage,
        limit: _limit,
        categoryId: categoryIds,
        search: state.searchQuery.isEmpty ? null : state.searchQuery, // ← carry search
      );

      state = state.copyWith(
        isLoadingMore: false,
        currentPage: nextPage,

        products: [...state.products, ...response.products],

        hasMore: response.products.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, errorMessage: e.toString());
    }
  }

  /// ===========================
  /// Pull To Refresh
  /// ===========================
  Future<void> refreshCategoryProducts({String? categoryIds}) async {
    state = state.copyWith(
      isRefreshing: true,
      errorMessage: null,
      currentPage: 1,
      hasMore: true,
    );

    try {
      final response = await _repository.getProducts(
        page: 1,
        limit: _limit,
        categoryId: categoryIds,
        search: state.searchQuery.isEmpty ? null : state.searchQuery, // ← carry search
      );

      state = state.copyWith(
        isRefreshing: false,
        isSuccess: true,
        currentPage: 1,

        products: response.products,

        hasMore: response.products.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, errorMessage: e.toString());
    }
  }

  /// ===========================
  /// Retry
  /// ===========================

  Future<void> retry({String? categoryIds}) async {
    if (state.searchQuery.isNotEmpty) {
      await _fetchWithSearch(state.searchQuery,categoryIds); // retry with same query
    } else {
      await getCategoryProducts(categoryIds: categoryIds);
    }
  }
  Future<void> resetSearch() async {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 1,
      hasMore: true,
    );

    await getCategoryProducts(categoryIds: _selectedCategoryId);
  }
  Future<void> searchNow(String query) => _fetchWithSearch(query,_selectedCategoryId);


  // ── Dispose: cancel subscription & close subject ──────────────────────────
  @override
  void dispose() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    super.dispose();
  }
}

final categoryProductProvider =
    StateNotifierProvider<CategoryviseProductnotifier, ProductState>((ref) {
      final repository = ref.watch(repositoryProvider);
      return CategoryviseProductnotifier(repository);
    });
