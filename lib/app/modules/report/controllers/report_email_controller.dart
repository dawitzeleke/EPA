import 'package:dio/dio.dart' as dio;
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/core/network/dio_client.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportEmailController extends GetxController {
  final phoneController = TextEditingController();
  final isSubmitting = false.obs;

  String? reportId;
  DateTime? dateTime;
  String? region;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      reportId = args['reportId']?.toString();
      dateTime = args['dateTime'] as DateTime?;
      region = args['region']?.toString();
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || !GetUtils.isPhoneNumber(phone)) {
      Get.snackbar(
        'Invalid phone number',
        'Please enter a valid phone number to receive the code.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    try {
      // Ensure guest OTP request is sent without any existing auth header
      final headers = Map<String, dynamic>.from(
        DioClient.instance.dio.options.headers,
      )..remove('Authorization');

      final response = await DioClient.instance.dio.post(
        ApiConstants.requestReportOtpEndpoint,
        data: {
          'phone_number': phone,
          'isGuest': true,
        },
        options: dio.Options(
          followRedirects: true,
          headers: headers,
        ),
      );
      final status = response.statusCode ?? 0;
      final success = status >= 200 && status < 300;
      if (!success) {
        throw Exception(_extractMessage(response.data) ?? 'Failed to send OTP');
      }

      final message = _extractMessage(response.data) ?? 'OTP sent to $phone';
      Get.snackbar(
        'OTP sent',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
      );

      final idToPass = (reportId != null && reportId!.isNotEmpty)
          ? reportId!
          : 'REP-${DateTime.now().millisecondsSinceEpoch}';
      final dt = dateTime ?? DateTime.now();

      Get.toNamed(
        Routes.Report_Otp,
        arguments: {
          'phone': phone,
          'reportId': idToPass,
          'dateTime': dt,
          'region': region,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Failed to send OTP',
        _cleanErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
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
