// lib/providers/store_product/store_product_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
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
      await _repository.storeProduct(
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
      state = state.copyWith(
        status: ProductStatus.success,
        isSuccess: true,
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
}

final storeProductProvider =
StateNotifierProvider<StoreProductNotifier, StoreProductState>((ref) {
  final repository = ref.watch(repositoryProvider);
  return StoreProductNotifier(repository);
});