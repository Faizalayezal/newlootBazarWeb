// lib/providerd/productDetail/ProductDetailNotifier.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
import 'package:lootbazarweb/providerd/di/sharedPrefsProvider.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import '../../network_manager/repository.dart';
import 'product_detail_state.dart';

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final Repository _repository;
  final SharedPrefs _prefs;

  ProductDetailNotifier(this._repository, this._prefs)
      : super(const ProductDetailState());

  Future<void> getProductDetail({required String productId}) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );
    try {
      var currentUserId = await _prefs.getString(userId);
      final response = await _repository.getProductDetail(
        productId: productId,
        userId: currentUserId ?? '',
      );
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        response: response,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> uploadVideo({
    required String productId,
    required XFile videoFile,
  }) async {
    state = state.copyWith(
      isVideoUploading: true,
      isVideoUploadSuccess: false,
      videoUploadError: null,
    );
    try {
      var currentUserId = await _prefs.getString(userId);
      final response = await _repository.uploadVideo(
        productId: productId,
        userId: currentUserId ?? '',
        videoFile: videoFile,
      );
      state = state.copyWith(
        isVideoUploading: false,
        isVideoUploadSuccess: true,
        uploadedVideo: response.status,
      );
      await getProductDetail(productId: productId);
    } catch (e) {
      state = state.copyWith(
        isVideoUploading: false,
        isVideoUploadSuccess: false,
        videoUploadError: e.toString(),
      );
    }
  }

  Future<void> uploadImage({
    required String productId,
    required XFile imageFile,
  }) async {
    state = state.copyWith(
      isUploadingImage: true,
      isImageUploadSuccess: false,
      imageUploadError: null,
    );
    try {
      var currentUserId = await _prefs.getString(userId);

      final updatedProduct = await _repository.uploadImage(
        userId: currentUserId ?? '',
        productId: productId,
        imageFile: imageFile,
      );

      // ── response ke andar product update karo ──────────────────────────
      final updatedResponse = state.response?.copyWith(
        product: state.product?.copyWith(images: updatedProduct.images),
      );

      state = state.copyWith(
        isUploadingImage: false,
        isImageUploadSuccess: true,
        response: updatedResponse, // ← response update karo, product nahi
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingImage: false,
        isImageUploadSuccess: false,
        imageUploadError: e.toString(),
      );
    }
  }

  void reset() => state = const ProductDetailState();

  Future<void> trackView({
    required String productId,
    required String type,
  }) async {
    try {
      var currentUserId = await _prefs.getString(userId);
      if (currentUserId == null || currentUserId.isEmpty) return;
      if (state.product?.userId == currentUserId) return;
      await _repository.trackProductView(
        productId: productId,
        viewerUserId: currentUserId,
        type: type,
      );
    } catch (_) {}
  }

  Future<void> deleteImage({
    required String productId,
    required String imageId,
  }) async {
    state = state.copyWith(
      isDeletingImage: true,
      deletingImageId: imageId,
    );
    try {
      await _repository.deleteProductImage(
        productId: productId,
        imageId: imageId,
      );
      final currentImages = state.product?.images ?? [];
      final updatedImages =
      currentImages.where((img) => img.id != imageId).toList();

      final updatedResponse = state.response?.copyWith(
        product: state.product?.copyWith(images: updatedImages),
      );

      state = state.copyWith(
        isDeletingImage: false,
        deletingImageId: null,
        response: updatedResponse,
      );
    } catch (e) {
      state = state.copyWith(
        isDeletingImage: false,
        deletingImageId: null,
      );
      rethrow;
    }
  }

  Future<void> deleteVideo({
    required String videoId,
    required String productId,
  }) async {
    state = state.copyWith(
      isDeletingVideo: true,
      deletingVideoId: videoId,
    );
    try {
      await _repository.deleteProductVideo(videoId: videoId);
      final updatedVideos =
      state.videos.where((v) => v.id != videoId).toList();

      final updatedResponse = state.response?.copyWith(videos: updatedVideos);

      state = state.copyWith(
        isDeletingVideo: false,
        deletingVideoId: null,
        response: updatedResponse,
      );
    } catch (e) {
      state = state.copyWith(
        isDeletingVideo: false,
        deletingVideoId: null,
      );
      rethrow;
    }
  }
}

final productDetailProvider =
StateNotifierProvider.autoDispose<ProductDetailNotifier, ProductDetailState>(
      (ref) {
    final repository = ref.watch(repositoryProvider);
    final prefs = ref.watch(sharedPrefsProvider);
    return ProductDetailNotifier(repository, prefs);
  },
);