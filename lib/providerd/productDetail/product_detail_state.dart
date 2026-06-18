// lib/providers/product_detail/product_detail_state.dart

import 'package:flutter/foundation.dart';
import 'package:lootbazarweb/providerd/productDetail/product_detail_model.dart';

import 'UploadVideoResponse.dart';

@immutable
class ProductDetailState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final ProductDetailResponse? response;

  final bool isVideoUploading;
  final bool isVideoUploadSuccess;
  final String? videoUploadError;
  final VideoStatus? uploadedVideo;
  final bool isDeletingImage;
  final String? deletingImageId;
  final bool isDeletingVideo;
  final String? deletingVideoId;
  final bool isUploadingImage;
  final String? imageUploadError;
  final bool isImageUploadSuccess;

  const ProductDetailState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
    this.response,
    this.isUploadingImage = false,
    this.imageUploadError,
    this.isImageUploadSuccess = false,
    this.isVideoUploading = false,
    this.isVideoUploadSuccess = false,
    this.videoUploadError,
    this.uploadedVideo,
    this.isDeletingImage = false,
    this.deletingImageId,
    this.isDeletingVideo = false,
    this.deletingVideoId,
  });

  ProductDetailData? get product => response?.product;

  List<ProductVideo> get videos => response?.videos ?? [];

  int get viewsCount => response?.viewsCount ?? 0;

  ProductViewers? get viewers => response?.viewers;

  List<ProductDetailData> get similarProducts =>
      response?.similarProducts ?? [];

  static const Object _sentinel = Object();

  ProductDetailState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    ProductDetailResponse? response,
    bool? isVideoUploading,
    bool? isVideoUploadSuccess,
    String? videoUploadError,
    VideoStatus? uploadedVideo,
    bool? isDeletingImage,
    String? deletingImageId,
    bool? isDeletingVideo,
    String? deletingVideoId,
    bool? isUploadingImage,
    bool? isImageUploadSuccess,
    Object? imageUploadError = _sentinel,

  }) {
    return ProductDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      response: response ?? this.response,
      isVideoUploading: isVideoUploading ?? this.isVideoUploading,
      isVideoUploadSuccess: isVideoUploadSuccess ?? this.isVideoUploadSuccess,
      videoUploadError: videoUploadError ?? this.videoUploadError,
      uploadedVideo: uploadedVideo ?? this.uploadedVideo,
      isDeletingImage: isDeletingImage ?? this.isDeletingImage,
      deletingImageId: deletingImageId ?? this.deletingImageId,
      isDeletingVideo: isDeletingVideo ?? this.isDeletingVideo,
      deletingVideoId: deletingVideoId ?? this.deletingVideoId,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isImageUploadSuccess: isImageUploadSuccess ?? this.isImageUploadSuccess,
      imageUploadError: identical(imageUploadError, _sentinel)
          ? this.imageUploadError
          : imageUploadError as String?,
    );
  }

  factory ProductDetailState.initial() {
    return const ProductDetailState();
  }
}