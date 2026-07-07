enum ProductStatus { initial, loading, success, error }

class StoreProductState {
  final ProductStatus status;
  final String? errorMessage;
  final bool isSuccess;
  final String? productId;

  const StoreProductState({
    this.status = ProductStatus.initial,
    this.errorMessage,
    this.isSuccess = false,
    this.productId,
  });

  bool get isLoading => status == ProductStatus.loading;

  StoreProductState copyWith({
    ProductStatus? status,
    String? errorMessage,
    bool? isSuccess,
    String? productId,
  }) {
    return StoreProductState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      productId: productId ?? this.productId,
    );
  }
}