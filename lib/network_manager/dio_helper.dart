import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'injection_container.dart';

class DioHelper {
  static final DioHelper _instance = DioHelper._internal();

  factory DioHelper() => _instance;

  DioHelper._internal();

  final Dio dio = DioClient().dio;

  Future<Map<String, dynamic>> get({required String url, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(url, queryParameters: queryParameters,);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint("--------17: ${e.response?.statusCode}");
      debugPrint("--------18:  ${e.response?.data}");
      throw Exception("API FAILED");
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
      debugPrint("--------17: ${e.response?.statusCode}");
      debugPrint("--------18: ${e.response?.data}");
      throw Exception("API FAILED");
    }
  }

  Future<List<dynamic>> getList({required String url}) async {
    try {
      final response = await dio.get(url);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      debugPrint("GET ERROR -> ${e.response?.statusCode}");
      debugPrint("GET DATA -> ${e.response?.data}");
      throw Exception(e.response?.data ?? "API FAILED");
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
      debugPrint("POST ERROR → ${e.response?.statusCode}");
      debugPrint("POST DATA → ${e.response?.data}");
      throw Exception(e.response?.data ?? "API FAILED");
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
      debugPrint("POST ERROR → ${e.response?.statusCode}");
      debugPrint("POST DATA → ${e.response?.data}");
      throw Exception(e.response?.data ?? "API FAILED");
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
      debugPrint("DELETE ERROR → ${e.response?.statusCode}");
      debugPrint("DELETE DATA → ${e.response?.data}");
      throw Exception(e.response?.data ?? "API FAILED");
    }
  }
}
