/// Domain entity representing a user signup
class SignupEntity {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  SignupEntity({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });
}

/// Domain entity representing signup response
class SignupResponseEntity {
  final bool success;
  final String? message;
  final String? userId;
  final String? email;

  SignupResponseEntity({
    required this.success,
    this.message,
    this.userId,
    this.email,
  });
}

/// Domain entity representing OTP verification
class OtpVerificationEntity {
  final String email;
  final String otp;

  OtpVerificationEntity({
    required this.email,
    required this.otp,
  });
}

/// Domain entity representing OTP verification response
class OtpVerificationResponseEntity {
  final bool success;
  final String? token;
  final String? userId;
  final String? username;
  final String? email;
  final String? message;

  OtpVerificationResponseEntity({
    required this.success,
    this.token,
    this.userId,
    this.username,
    this.email,
    this.message,
  });
}
