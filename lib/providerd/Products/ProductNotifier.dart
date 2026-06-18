// lib/providerd/product/product_provider.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lootbazarweb/network_manager/repository.dart';
import 'package:lootbazarweb/providerd/Products/ProductState.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
import 'package:rxdart/rxdart.dart';

class ProductNotifier extends StateNotifier<ProductState> {
  final Repository _repository;

  // ── RxDart search subject ──────────────────────────────────────────────────
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  StreamSubscription<String>? _searchSubscription;
  // ──────────────────────────────────────────────────────────────────────────

  static const int _limit = 15;

  ProductNotifier(this._repository) : super(const ProductState()) {
    _initSearchDebounce();
  }

  // ── Setup 500ms debounce on search stream ──────────────────────────────────
  void _initSearchDebounce() {
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 1000))
        .distinct() // skip if same query fired again
        .listen((query) {
      _fetchWithSearch(query);
    });
  }

  /// Called from UI on every keystroke — feeds the debounce stream
  void onSearchChanged(String query) {
    // Update query in state immediately so UI TextField stays in sync
    state = state.copyWith(searchQuery: query);
    // Push into subject — debounce will fire after 500ms idle
    _searchSubject.add(query.trim());
  }

  /// Internal — called by debounce after idle period
  Future<void> _fetchWithSearch(String query) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      currentPage: 1,
      hasMore: true,
      errorMessage: null,
      products: [],       // clear stale results immediately
      searchQuery: query,
    );
    try {
      final response = await _repository.getProducts(
        page: 1,
        limit: _limit,
        search: query.isEmpty ? null : query, // pass null if empty
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

  // ── Initial load (no search) ───────────────────────────────────────────────
  Future<void> getProducts() async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      currentPage: 1,
      hasMore: true,
      errorMessage: null,
      searchQuery: '',
    );
    try {

      final response = await _repository.getProducts(
        page: 1,
        limit: _limit,
        search: null,
      );
      debugPrint('✅ Products loaded: ${response.products.length}');
      debugPrint('✅ First product: ${response.products.isNotEmpty ? response.products.first.title : "none"}');

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

  // ── Load next page (respects current search query) ─────────────────────────
  Future<void> loadMoreProducts() async {
    if (state.isLoadingMore) return;
    if (state.isLoading) return;
    if (!state.hasMore) return;

    state = state.copyWith(
      isLoadingMore: true,
      errorMessage: null,
    );
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getProducts(
        page: nextPage,
        limit: _limit,
        search: state.searchQuery.isEmpty ? null : state.searchQuery, // ← carry search
      );
      state = state.copyWith(
        isLoadingMore: false,
        currentPage: nextPage,
        products: [
          ...state.products,
          ...response.products,
        ],
        hasMore: response.products.length == _limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Pull to refresh (respects current search query) ────────────────────────
  Future<void> refreshProducts() async {
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
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Retry ──────────────────────────────────────────────────────────────────
  Future<void> retry() async {
    if (state.searchQuery.isNotEmpty) {
      await _fetchWithSearch(state.searchQuery); // retry with same query
    } else {
      await getProducts();
    }
  }
  Future<void> resetSearch() async {
    state = state.copyWith(
      searchQuery: '',
      currentPage: 1,
      hasMore: true,
    );

    await getProducts();
  }
  Future<void> searchNow(String query) => _fetchWithSearch(query);
  Future<void> clearSearchAndReload() async {
    _searchSubject.add('');

    state = state.copyWith(
      searchQuery: '',
    );

    await getProducts();
  }


  // ── Dispose: cancel subscription & close subject ──────────────────────────
  @override
  void dispose() {
    _searchSubscription?.cancel();
    _searchSubject.close();
    super.dispose();
  }
}

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final repository = ref.watch(repositoryProvider);
  return ProductNotifier(repository);
});
