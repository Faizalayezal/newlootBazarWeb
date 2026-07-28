import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constant/api_constants.dart';


class DioClient {

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;



  late Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
      ),
    );

    _initializeInterceptors();
  }

  void _initializeInterceptors() {

    /// Retry Interceptor
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    /// Request Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {

          options.headers.addAll({
            'accept': '*/*',
            'Api-version': 'v1',
            'Content-Type': 'application/json',
            'x-api-key':"lootbaazarV5kAYC7SJhFGWEnWynVjHW0UU7kA8N9x",
           // 'Authorization':'Bearer ${SharedPrefs().getString(authToken)?.trim() ?? ''}',
          });

          debugPrint("URL → ${options.uri}");

          if (options.data != null) {
            try {
              debugPrint("BODY → ${jsonEncode(options.data)}");
            } catch (_) {}
          }

          return handler.next(options);
        },

        onResponse: (response, handler) {
          debugPrint("RESPONSE → ${response.data}");
          return handler.next(response);
        },

        onError: (error, handler) async {

          /// Token Expired
         /* if (error.response?.statusCode == 401) {

            try {

              String newToken = await _refreshToken();

              error.requestOptions.headers["Authorization"] =
              "Bearer $newToken";

              final cloneReq = await dio.fetch(error.requestOptions);

              return handler.resolve(cloneReq);

            } catch (e) {
              return handler.next(error);
            }

          }*/

          debugPrint("ERROR → ${error.response?.data}");

          return handler.next(error);
        },
      ),
    );

    /// Logger
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  /*/// Refresh Token API
  Future<String> _refreshToken() async {

    final response = await dio.post(
      "/refresh-token",
      data: {
        "refreshToken": SharedPrefs().getString("refreshToken")
      },
    );

    String newToken = response.data["accessToken"];

    SharedPrefs().setString(authToken, newToken);

    return newToken;
  }*/
}