import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/app/routes/app_pages.dart';
import '../constants/api_constants.dart';
import 'retry_interceptor.dart';
import 'cache_interceptor.dart';

/// Dio client singleton for making HTTP requests
class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  late final CacheInterceptor _cacheInterceptor;
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

    // In-memory response cache (GET only, 5-min TTL)
    _cacheInterceptor = CacheInterceptor(
      ttl: const Duration(minutes: 5),
      maxEntries: 50,
    );
    _dio.interceptors.add(_cacheInterceptor);

    // Retry with exponential back-off for transient failures
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        maxRetries: 3,
        baseDelay: const Duration(milliseconds: 500),
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

  /// Clear all cached API responses.
  void clearCache() => _cacheInterceptor.clear();

  /// Invalidate a specific cached entry by its cache key.
  void invalidateCache(String key) => _cacheInterceptor.invalidate(key);

  /// Number of cached entries (useful for debugging).
  int get cacheSize => _cacheInterceptor.cacheSize;

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

