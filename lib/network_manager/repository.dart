import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/constant/api_constants.dart';
import 'package:lootbazarweb/network_manager/dio_helper.dart';
import 'package:lootbazarweb/providerd/Products/product_model.dart';
import 'package:lootbazarweb/providerd/currantUserListning/current_product_model.dart';
import 'package:lootbazarweb/providerd/notification/notification_product.dart';
import 'package:lootbazarweb/providerd/productDetail/product_detail_model.dart';
import 'package:lootbazarweb/providerd/video/video_list_response.dart';
import 'package:lootbazarweb/response/requestion_response/UpdateProfileRequest.dart';
import 'package:lootbazarweb/providerd/productDetail/upload_video_response.dart';
import 'package:lootbazarweb/response/category_model.dart';
import 'package:lootbazarweb/response/register_response.dart';
import 'package:lootbazarweb/response/user_model.dart';

class Repository {
  final DioHelper _dioHelper = DioHelper();

  Future<MultipartFile> createMultipartFile(XFile file) async {
    if (kIsWeb) {
      final bytes = await file.readAsBytes();

      return MultipartFile.fromBytes(bytes, filename: file.name);
    } else {
      return MultipartFile.fromFile(file.path, filename: file.name);
    }
  }

  Future<RegisterResponse> register({required String mobileNo}) async {
    try {
      final response = await _dioHelper.post(
        url: ApiConstants.register,
        requestBody: {'mobileno': mobileNo},
      );
      return RegisterResponse.fromJson(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<VerifyOtpResponse> verifyOtp({
    required String mobileNo,
    required String otp,
  }) async {
    try {
      final response = await _dioHelper.post(
        url: ApiConstants.verifyOtp,
        requestBody: {'mobileno': mobileNo, 'otp': otp},
      );
      return VerifyOtpResponse.fromJson(response);
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  Future<List<CategoryModel>> getCategory() async {
    try {
      final response = await _dioHelper.getList(url: ApiConstants.getCategory);

      return response.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Get category failed: $e');
    }
  }

  Future<Map<String, dynamic>> getProfile({required String userId}) async {
    try {
      final response = await _dioHelper.get(
        url: '${ApiConstants.updateProfile}/$userId',
      );
      return response;
    } catch (e) {
      throw Exception('Get profile failed: $e');
    }
  }

  Future<RegisterUser> updateProfile({
    required String userId,
    required UpdateProfileRequest request,
  }) async {
    try {
      // FormData banao kyunki image file hai
      MultipartFile? profileImage;

      if (request.profileImage != null) {
        if (kIsWeb) {
          // Flutter Web
          final bytes = await request.profileImage!.readAsBytes();

          profileImage = MultipartFile.fromBytes(
            bytes,
            filename: request.profileImage!.name,
          );
        } else {
          // Android / iOS
          profileImage = await MultipartFile.fromFile(
            request.profileImage!.path,
            filename: request.profileImage!.name,
          );
        }
      }
      final formData = FormData.fromMap({
        'name': request.name,
        'address': request.address,
        'pincode': request.pincode,
        'interests': request.interests,
        if (profileImage != null) 'profileImage': profileImage,
      });

      final response = await _dioHelper.putFormData(
        url: '${ApiConstants.updateProfile}/$userId/update',
        formData: formData,
      );

      return RegisterUser.fromJson(response);
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  Future<ProductListResponse> getProducts({
    int page = 1,
    int limit = 15,
    String? categoryId,
    String? search,
  }) async {
    try {
      String url;

      if (categoryId != null) {
        url = '${ApiConstants.getProducts}/category/$categoryId';
      } else if (search != null && search.trim().isNotEmpty) {
        url = '${ApiConstants.getProducts}/search';
      } else {
        url = ApiConstants.getProducts;
      }

      final response = await _dioHelper.getSearch(
        url: url,
        queryParameters: {
          "page": page,
          "limit": limit,
          if (search != null && search.trim().isNotEmpty) "search": search,
        },
      );

      // ─── Search endpoint returns raw List, wrap it manually ───────────────
      if (search != null && search.trim().isNotEmpty) {
        List<dynamic> list;

        if (response is List) {
          list = response;
        } else if (response is Map<String, dynamic>) {
          list = response['products'] ?? [];
        } else {
          list = [];
        }

        return ProductListResponse.fromJson({
          "products": list,
          "currentPage": page,
          "totalPages": 1,
          "totalProducts": list.length,
        });
      }

      return ProductListResponse.fromJson(response);
    } catch (e, s) {
      debugPrint('🔍 BUILD: 121=${e.toString()}');
      debugPrint('🔍 BUILD: 122=${s.toString()}');

      throw Exception('Get products failed: $e');
    }
  }

  Future<CurrentProductResponse> getCurrentUserProducts({
    required String userId,
  }) async {
    try {
      final response = await _dioHelper.getList(
        url: '${ApiConstants.getCurrentUserProducts}/$userId',
      );
      // API list return karta hai, isliye List cast karo
      return CurrentProductResponse.fromJson(response);
    } catch (e) {
      throw Exception('Get current user products failed: $e');
    }
  }

  Future<Map<String, dynamic>> storeProduct({
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
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('price', price.toString()),
        MapEntry('stock', stock.toString()),
        MapEntry('moq', moq.toString()),
        MapEntry('userId', userId),
        MapEntry('phoneNumber', phoneNumber),
        MapEntry('location', location),
      ]);

      // category array
      for (final id in categoryIds) {
        formData.fields.add(MapEntry('category', id));
      }

      // images array
      for (final path in imagePaths) {
        // final fileName = path.split('/').last;
        formData.files.add(MapEntry('images', await createMultipartFile(path)));
      }

      final response = await _dioHelper.post(
        url: ApiConstants.storeProduct,
        requestBody: formData,
      );
      return response;
    } catch (e) {
      throw Exception('Store product failed: $e');
    }
  }

  Future<void> updatePaymentStatus({
    required String productId,
    required String userId,
    required String paymentStatus,
  }) async {
    try {
      await _dioHelper.putFormData(
        url: ApiConstants.paymentStatus,
        formData: {
          'productId': productId,
          'userId': userId,
          'paymentStatus': paymentStatus,
        },
      );
    } catch (e) {
      throw Exception('Update payment status failed: $e');
    }
  }

  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final response = await _dioHelper.post(
        url: ApiConstants.validateCoupon,
        requestBody: {
          'code': code,
          'orderAmount': orderAmount,
        },
      );
      return response;
    } catch (e) {
      throw Exception('Coupon validation failed: $e');
    }
  }

  Future<ProductDetailResponse> getProductDetail({
    required String productId,
    required String userId,
  }) async {
    try {
      final response = await _dioHelper.get(
        url: '${ApiConstants.productDetail}/$productId',
        queryParameters: {'userId': userId},
      );
      return ProductDetailResponse.fromJson(response);
    } catch (e) {
      throw Exception('Get product detail failed: $e');
    }
  }

  // repository.dart me add karo

  Future<UploadVideoResponse> uploadVideo({
    required String productId,
    required String userId,
    required XFile videoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'userId': userId,
        'productId': productId,
        'video': await createMultipartFile(videoFile),
      });
      final response = await _dioHelper.post(
        url: ApiConstants.uploadVideo,
        requestBody: formData,
      );
      return UploadVideoResponse.fromJson(response);
    } catch (e) {
      throw Exception('Upload video failed: $e');
    }
  }

  Future<VideoListResponse> getVideos() async {
    try {
      final response = await _dioHelper.getList(url: ApiConstants.videosApi);
      // Response List hai directly
      return VideoListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Get videos failed: $e');
    }
  }

  Future<void> trackProductView({
    required String productId,
    required String viewerUserId,
    required String type, // 'call' or 'view'
  }) async {
    try {
      await _dioHelper.post(
        url: '${ApiConstants.getProducts}/$productId/view',
        requestBody: {'viewerUserId': viewerUserId, 'type': type},
      );
    } catch (e) {
      throw Exception('Track product view failed: $e');
    }
  }

  Future<void> deleteProductImage({
    required String productId,
    required String imageId,
  }) async {
    try {
      await _dioHelper.delete(
        url: '${ApiConstants.getProducts}/$productId/delete-image',
        requestBody: {'imageId': imageId},
      );
    } catch (e) {
      throw Exception('Delete image failed: $e');
    }
  }

  Future<void> deleteProductVideo({required String videoId}) async {
    try {
      await _dioHelper.delete(url: '${ApiConstants.deleteStatus}/$videoId');
    } catch (e) {
      throw Exception('Delete video failed: $e');
    }
  }

  // lib/network_manager/repository.dart

  Future<ProductModel> uploadImage({
    required String userId,
    required String productId,
    required XFile imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'userId': userId,
        'productId': productId,
        'image': await createMultipartFile(imageFile),
      });

      final response = await _dioHelper.post(
        url: ApiConstants.uploadImage,
        requestBody: formData,
      );

      // Response mein 'product' key hai
      return ProductModel.fromJson(response['product'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Upload image failed: $e');
    }
  }

  // lib/network_manager/repository.dart mein add karo

  Future<List<NotificationModel>> getNotifications({
    required String userId,
  }) async {
    try {
      final response = await _dioHelper.getSearch(
        url: ApiConstants.getNotification,
        queryParameters: {'userId': userId},
      );

      final List<dynamic> list = response is List ? response : [];
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Get notifications failed: $e');
    }
  }
}
