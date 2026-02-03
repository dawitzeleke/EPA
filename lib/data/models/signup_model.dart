import '../../domain/entities/signup_entity.dart';

/// Data model for signup request
class SignupModel extends SignupEntity {
  SignupModel({
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    required super.password,
    required super.confirmPassword,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }

  /// Create from JSON
  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      confirmPassword: json['confirm_password'] ?? json['confirmPassword'] ?? '',
    );
  }
}

/// Data model for signup response
class SignupResponseModel extends SignupResponseEntity {
  SignupResponseModel({
    required super.success,
    super.message,
    super.userId,
    super.email,
  });

  /// Create from JSON
  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    // Check if success field exists, otherwise check if message indicates success
    bool isSuccess = json['success'] ?? false;
    final message = json['message'] ?? json['data']?['message'] ?? '';
    
    // If success field is not explicitly true, check if message indicates success
    if (!isSuccess && message.toString().toLowerCase().contains('success')) {
      isSuccess = true;
    }
    
    return SignupResponseModel(
      success: isSuccess,
      message: message.toString().isEmpty ? null : message.toString(),
      userId: json['user_id'] ?? json['userId'] ?? json['data']?['user_id'] ?? json['data']?['userId'],
      email: json['email'] ?? json['data']?['email'],
    );
  }

  /// Convert to entity
  SignupResponseEntity toEntity() {
    return SignupResponseEntity(
      success: success,
      message: message,
      userId: userId,
      email: email,
    );
  }
}

/// Data model for OTP verification request
class OtpVerificationModel extends OtpVerificationEntity {
  OtpVerificationModel({
    required super.email,
    required super.otp,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}

/// Data model for OTP verification response
class OtpVerificationResponseModel extends OtpVerificationResponseEntity {
  OtpVerificationResponseModel({
    required super.success,
    super.token,
    super.userId,
    super.username,
    super.email,
    super.message,
  });

  /// Create from JSON
  factory OtpVerificationResponseModel.fromJson(Map<String, dynamic> json) {
    // Check if success field exists, otherwise check if message indicates success
    bool isSuccess = json['success'] ?? false;
    final message = json['message'] ?? json['error'] ?? json['data']?['message'] ?? '';
    
    // If success field is not explicitly true, check if message indicates success
    if (!isSuccess && message.toString().toLowerCase().contains('success')) {
      isSuccess = true;
    }
    
    return OtpVerificationResponseModel(
      success: isSuccess,
      token: json['token'] ?? json['data']?['token'],
      userId: json['user_id'] ?? json['userId'] ?? json['data']?['user_id'] ?? json['data']?['userId'],
      username: json['username'] ?? json['full_name'] ?? json['fullName'] ?? json['data']?['username'] ?? json['data']?['full_name'],
      email: json['email'] ?? json['data']?['email'],
      message: message.toString().isEmpty ? null : message.toString(),
    );
  }

  /// Convert to entity
  OtpVerificationResponseEntity toEntity() {
    return OtpVerificationResponseEntity(
      success: success,
      token: token,
      userId: userId,
      username: username,
      email: email,
      message: message,
    );
  }
}

