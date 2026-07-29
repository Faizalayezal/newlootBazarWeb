// lib/providers/store_product/store_product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/providerd/di/repository_provider.dart';
import '../../network_manager/repository.dart';
import 'store_product_state.dart';

class StoreProductNotifier extends StateNotifier<StoreProductState> {
  final Repository _repository;

  StoreProductNotifier(this._repository)
      : super(const StoreProductState());

  Future<void> storeProduct({
    required String title,
    required String description,
    required double price,
    required int stock,
    required int moq,
    required List<String> categoryIds,
    required String userId,
    required String phoneNumber,
    required String location,
    required List<XFile> imagePaths,
  }) async {
    state = state.copyWith(
      status: ProductStatus.loading,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      final response = await _repository.storeProduct(
        title: title,
        description: description,
        price: price,
        stock: stock,
        moq: moq,
        categoryIds: categoryIds,
        userId: userId,
        phoneNumber: phoneNumber,
        location: location,
        imagePaths: imagePaths,
      );

      // Extract productId from response. Adjust key if necessary (e.g., '_id' or 'id')
      String? prodId;
      if (response['product'] != null) {
        prodId = response['product']['_id'] ?? response['product']['id'];
      } else {
        prodId = response['_id'] ?? response['id'];
      }

      state = state.copyWith(
        status: ProductStatus.success,
        isSuccess: true,
        productId: prodId,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductStatus.error,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const StoreProductState();
  }

  Future<void> updatePaymentStatus({
    required String productId,
    required String userId,
    required String paymentStatus,
  }) async {
    try {
      await _repository.updatePaymentStatus(
        productId: productId,
        userId: userId,
        paymentStatus: paymentStatus,
      );
    } catch (e) {
      // Handle error if needed
    }
  }
}

final storeProductProvider =
StateNotifierProvider<StoreProductNotifier, StoreProductState>((ref) {
  final repository = ref.watch(repositoryProvider);
  return StoreProductNotifier(repository);
});