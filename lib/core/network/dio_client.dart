import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/app/routes/app_pages.dart';
import '../constants/api_constants.dart';

/// Dio client singleton for making HTTP requests
class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  bool _isHandlingAuthError = false;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            await _handleAuthExpired();
          }
          return handler.next(error);
        },
      ),
    );

    // Add interceptors for logging (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  /// Set authorization token for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<void> _handleAuthExpired() async {
    if (_isHandlingAuthError) return;
    _isHandlingAuthError = true;

    try {
      final storage = GetStorage();
      await storage.remove('auth_token');
      await storage.remove('user_id');
      await storage.remove('userId');
      await storage.remove('username');
      await storage.remove('full_name');
      await storage.remove('phone');
      await storage.remove('phone_number');
      await storage.remove('email');
      clearAuthToken();

      if (Get.currentRoute != Routes.LOGIN && Get.currentRoute != Routes.SPLASH) {
        Get.offAllNamed(Routes.LOGIN);
      }
    } finally {
      _isHandlingAuthError = false;
    }
  }
}

