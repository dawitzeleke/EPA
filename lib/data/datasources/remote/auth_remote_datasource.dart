import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/login_model.dart';
import '../../models/signup_model.dart';
import '../../models/update_profile_model.dart';
import '../../../core/constants/api_constants.dart';

/// Remote data source for authentication
/// Handles all API calls related to authentication
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginModel loginModel);
  Future<SignupResponseModel> signup(SignupModel signupModel);
  Future<OtpVerificationResponseModel> verifyOtp(OtpVerificationModel otpModel);
  Future<bool> resendOtp(String email);
  Future<UpdateProfileResponseModel> updateProfile(
    UpdateProfileModel updateProfileModel,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final GetStorage storage;

  AuthRemoteDataSourceImpl({required this.dio, GetStorage? storage})
      : storage = storage ?? GetStorage();

  @override
  Future<LoginResponseModel> login(LoginModel loginModel) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: loginModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          response.data['message'] ?? 
          response.data['error'] ?? 
          'Login failed. Please try again.',
        );
      }
    } on DioException catch (e) {
      // Handle different types of Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data['message'] ?? 
                            e.response?.data['error'] ?? 
                            'Login failed. Please try again.';
        
        if (statusCode == 401) {
          throw Exception('Invalid phone number or password.');
        } else if (statusCode == 404) {
          throw Exception('User not found.');
        } else {
          throw Exception(errorMessage);
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else {
        throw Exception('An error occurred. Please try again.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<SignupResponseModel> signup(SignupModel signupModel) async {
    try {
      final response = await dio.post(
        ApiConstants.registerEndpoint,
        data: signupModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If status is 200/201, it means signup was successful
        // Ensure the response data has success: true
        final responseData = response.data is Map<String, dynamic>
            ? Map<String, dynamic>.from(response.data as Map)
            : {'message': response.data.toString()};
        
        // Set success to true if not already set
        if (!responseData.containsKey('success')) {
          responseData['success'] = true;
        }
        
        return SignupResponseModel.fromJson(responseData);
      } else {
        throw Exception(
          response.data['message'] ?? 
          response.data['error'] ?? 
          'Signup failed. Please try again.',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data['message'] ?? 
                            e.response?.data['error'] ?? 
                            'Signup failed. Please try again.';
        
        if (statusCode == 400) {
          throw Exception(errorMessage);
        } else if (statusCode == 409) {
          throw Exception('Email already exists. Please use a different email.');
        } else {
          throw Exception(errorMessage);
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else {
        throw Exception('An error occurred. Please try again.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<OtpVerificationResponseModel> verifyOtp(OtpVerificationModel otpModel) async {
    try {
      final response = await dio.post(
        ApiConstants.verifyOtpEndpoint,
        data: otpModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If status is 200/201, it means OTP verification was successful
        // Ensure the response data has success: true
        final responseData = response.data is Map<String, dynamic>
            ? Map<String, dynamic>.from(response.data as Map)
            : {'message': response.data.toString()};
        
        // Set success to true if not already set
        if (!responseData.containsKey('success')) {
          responseData['success'] = true;
        }
        
        return OtpVerificationResponseModel.fromJson(responseData);
      } else {
        throw Exception(
          response.data['message'] ?? 
          response.data['error'] ?? 
          'OTP verification failed. Please try again.',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data['message'] ?? 
                            e.response?.data['error'] ?? 
                            'OTP verification failed. Please try again.';
        
        if (statusCode == 400) {
          throw Exception('Invalid OTP. Please check and try again.');
        } else if (statusCode == 401) {
          throw Exception('OTP expired. Please request a new one.');
        } else {
          throw Exception(errorMessage);
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else {
        throw Exception('An error occurred. Please try again.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<bool> resendOtp(String email) async {
    try {
      final response = await dio.post(
        ApiConstants.resendOtpEndpoint,
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          response.data['message'] ?? 
          response.data['error'] ?? 
          'Failed to resend OTP. Please try again.',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        final errorMessage = e.response?.data['message'] ?? 
                            e.response?.data['error'] ?? 
                            'Failed to resend OTP. Please try again.';
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else {
        throw Exception('An error occurred. Please try again.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UpdateProfileResponseModel> updateProfile(
    UpdateProfileModel updateProfileModel,
  ) async {
    try {
      final token = storage.read('auth_token');
      final response = await dio.put(
        ApiConstants.updateProfileEndpoint(updateProfileModel.id),
        data: updateProfileModel.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.toString().isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data is Map<String, dynamic>
            ? Map<String, dynamic>.from(response.data as Map)
            : {'message': response.data.toString(), 'success': true};

        // Ensure success flag is set when status is 200/201
        responseData['success'] = responseData['success'] ?? true;
        return UpdateProfileResponseModel.fromJson(responseData);
      } else {
        throw Exception(
          response.data['message'] ??
              response.data['error'] ??
              'Failed to update profile. Please try again.',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data['message'] ??
            e.response?.data['error'] ??
            'Failed to update profile. Please try again.';

        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 404) {
          throw Exception('User not found.');
        } else {
          throw Exception(errorMessage);
        }
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      } else {
        throw Exception('An error occurred. Please try again.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

