import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// Factory that creates a lightweight [Dio] instance **without** the
/// auth-error interceptor.
///
/// Used for guest flows (OTP request / verify) where a 401/403 must not
/// redirect the user to the login page.
class GuestDioFactory {
  GuestDioFactory._();

  static Dio create() {
    return Dio(
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
  }
}
