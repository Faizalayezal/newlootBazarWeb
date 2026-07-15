import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'injection_container.dart';

class DioHelper {
  static final DioHelper _instance = DioHelper._internal();

  factory DioHelper() => _instance;

  DioHelper._internal();

  final Dio dio = DioClient().dio;

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }
    if (data is String && data.isNotEmpty) return data;
    return e.message ?? "Something went wrong";
  }

  Future<Map<String, dynamic>> get({required String url, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(url, queryParameters: queryParameters,);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint("--------29: ${e.response?.statusCode}");
      debugPrint("--------30:  ${e.response?.data}");
      throw Exception(_extractError(e));
    }
  }

  Future<dynamic> getSearch({   // ← Map<String,dynamic> se dynamic karo
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(url, queryParameters: queryParameters);
      return response.data; // ← cast mat karo, as-is return karo
    } on DioException catch (e) {
      debugPrint("--------43: ${e.response?.statusCode}");
      debugPrint("--------44: ${e.response?.data}");
      throw Exception(_extractError(e));
    }
  }

  Future<List<dynamic>> getList({required String url}) async {
    try {
      final response = await dio.get(url);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint("--------54: ${e.response?.statusCode}");
      debugPrint("--------55: ${e.response?.data}");
      throw Exception(_extractError(e));
    }
  }

  Future<Map<String, dynamic>> post({
    required String url,
    Object? requestBody,
  }) async {
    try {
      final response = await dio.post(url, data: requestBody);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint("--------68: ${e.response?.statusCode}");
      debugPrint("--------69: ${e.response?.data}");
      throw Exception(_extractError(e));
    }
  }

  Future<dynamic> putFormData({
    required String url,
    Object? formData,
  }) async {
    try {
      final response = await dio.put(url, data: formData);
      return response.data;
    } on DioException catch (e) {
      debugPrint("--------82: ${e.response?.statusCode}");
      debugPrint("--------83: ${e.response?.data}");
      throw Exception(_extractError(e));
    }
  }
  Future<dynamic> delete({
    required String url,
    Object? requestBody,
  }) async {
    try {
      final response = await dio.delete(
        url,
        data: requestBody,
      );
      return response.data;
    } on DioException catch (e) {
      debugPrint("--------98: ${e.response?.statusCode}");
      debugPrint("--------99: ${e.response?.data}");
      throw Exception(_extractError(e));
    }
  }
}
