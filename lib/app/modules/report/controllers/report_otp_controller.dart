import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'report_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportOtpController extends GetxController {
  var code = ''.obs;
  var seconds = 60.obs;
  var showKeypad = false.obs;
  var isLoading = false.obs;
  var isResending = false.obs;
  Timer? _timer;

  late final String phone;
  String? reportId;
  DateTime? dateTime;
  String? region;
  String? authToken;

  @override
  void onInit() {
    super.onInit();
    _captureArgs();
    startTimer();
  }

  void _captureArgs() {
    final args = Get.arguments;
    final resolvedPhone = (args is Map) ? args['phone']?.toString() ?? '' : '';
    phone = resolvedPhone;
    if (args is Map) {
      reportId = args['reportId']?.toString();
      dateTime = args['dateTime'] as DateTime?;
      region = args['region']?.toString();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    _timer?.cancel();
    seconds.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds.value <= 0) {
        t.cancel();
        update();
      } else {
        seconds.value--;
      }
    });
  }

  void append(String d) {
    if (code.value.length >= 6) return;
    code.value += d;
  }

  void backspace() {
    if (code.value.isEmpty) return;
    code.value = code.value.substring(0, code.value.length - 1);
  }

  void toggleKeypad(bool visible) {
    showKeypad.value = visible;
  }

  Future<void> resendOtp() async {
    if (phone.isEmpty) {
      Get.snackbar(
        'Phone number required',
        'Please enter your phone number again to request a code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isResending.value = true;
    try {
      // Use a clean Dio instance without the auth error interceptor
      // to prevent 401/403 from redirecting the guest to login.
      final guestDio = dio.Dio(
        dio.BaseOptions(
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

      final response = await guestDio.post(
        ApiConstants.requestReportOtpEndpoint,
        data: {
          'phone_number': phone,
          'isGuest': true,
        },
      );
      final status = response.statusCode ?? 0;
      final success = status >= 200 && status < 300;
      if (!success) {
        throw Exception(_extractMessage(response.data) ?? 'Failed to resend code');
      }
      code.value = '';
      startTimer();
      Get.snackbar(
        'OTP resent',
        _extractMessage(response.data) ?? 'A new code was sent to $phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: AppColors.onPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Resend failed',
        _cleanErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: AppColors.onPrimary,
      );
    } finally {
      isResending.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (phone.isEmpty) {
      Get.snackbar(
        'Phone number required',
        'Please return to the report page and enter your phone number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.back();
      return;
    }

    if (code.value.length < 6) {
      Get.snackbar(
        'Incomplete code',
        'Please enter the full 6-digit code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      // Use a clean Dio instance without the auth error interceptor
      // to prevent 401/403 from redirecting the guest to login.
      final guestDio = dio.Dio(
        dio.BaseOptions(
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

      final response = await guestDio.post(
        ApiConstants.verifyReportOtpEndpoint,
        data: {
          'phone_number': phone,
          'otp': code.value,
        },
      );

      final status = response.statusCode ?? 0;
      final success = status >= 200 && status < 300;
      if (!success) {
        throw Exception(_extractMessage(response.data) ?? 'Invalid or expired code');
      }

      authToken = _extractToken(response);
      if (authToken != null && authToken!.isNotEmpty) {
        // Keep token only for the current guest-report submission flow.
        // Do not persist as a logged-in session token.
      }

      final message = _extractMessage(response.data) ?? 'Code verified successfully';
      Get.snackbar(
        'Verified',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );

      // If a pending guest report exists, submit it now
      if (Get.isRegistered<ReportController>()) {
        try {
          final reportController = Get.find<ReportController>();
          if (reportController.hasPendingReport) {
            await reportController.submitPendingReportAfterOtp(
              phone: phone,
              token: authToken,
            );
            return;
          }
        } catch (_) {
          // fall through to default success navigation
        }
      }

      final idToUse = (reportId != null && reportId!.isNotEmpty)
          ? reportId!
          : 'REP-${DateTime.now().millisecondsSinceEpoch}';
      final dt = dateTime ?? DateTime.now();

      Get.offNamed(
        Routes.Report_Success,
        arguments: {
          'reportId': idToUse,
          'dateTime': dt,
          'region': region,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Verification failed',
        _cleanErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      for (final key in ['message', 'msg', 'detail']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return null;
  }

  String? _extractToken(dio.Response response) {
    try {
      final data = response.data;
      if (data is Map) {
        for (final key in ['token', 'access_token', 'auth_token', 'bearer']) {
          final value = data[key];
          if (value is String && value.isNotEmpty) return value;
        }
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
    } catch (_) {}
    // Try headers
    try {
      final headerToken = response.headers.map['authorization']?.first;
      if (headerToken != null && headerToken.isNotEmpty) return headerToken;
    } catch (_) {}
    return null;
  }

  String _cleanErrorMessage(Object error) {
    if (error is dio.DioException) {
      final extracted = _extractMessage(error.response?.data);
      if (extracted != null && extracted.trim().isNotEmpty) {
        return extracted.trim();
      }
      final msg = error.message;
      if (msg != null && msg.trim().isNotEmpty) {
        return msg.trim();
      }
    }
    final text = error.toString();
    final cleaned = text
        .replaceAll('Exception: ', '')
        .replaceAll(RegExp(r'^DioException[^:]*:\s*'), '')
        .trim();
    return cleaned.isEmpty ? 'Something went wrong' : cleaned;
  }
}
