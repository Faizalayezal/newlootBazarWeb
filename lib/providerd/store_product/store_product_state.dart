enum ProductStatus { initial, loading, success, error }

class StoreProductState {
  final ProductStatus status;
  final String? errorMessage;
  final bool isSuccess;

  const StoreProductState({
    this.status = ProductStatus.initial,
    this.errorMessage,
    this.isSuccess = false,
  });

  bool get isLoading => status == ProductStatus.loading;

  StoreProductState copyWith({
    ProductStatus? status,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return StoreProductState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}