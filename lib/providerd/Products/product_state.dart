// lib/providerd/Products/ProductState.dart

import 'package:flutter/material.dart';
import 'package:lootbazarweb/providerd/Products/product_model.dart';

@immutable
class ProductState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool isSuccess;
  final List<ProductModel> products;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;
  final String searchQuery;

  const ProductState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.isSuccess = false,
    this.products = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.errorMessage,
    this.searchQuery = '',
  });

  // Sentinel object to distinguish "pass null intentionally" vs "don't change"
  static const _keepValue = Object();

  ProductState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? isSuccess,
    List<ProductModel>? products,
    int? currentPage,
    bool? hasMore,
    Object? errorMessage = _keepValue, // ← sentinel default
    String? searchQuery,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSuccess: isSuccess ?? this.isSuccess,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      // If caller passed errorMessage (even null), use it. Else keep old.
      errorMessage: identical(errorMessage, _keepValue)
          ? this.errorMessage
          : errorMessage as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}