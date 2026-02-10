import '../entities/signup_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for OTP verification
/// This encapsulates the business logic for OTP verification
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  /// Execute OTP verification
  /// Returns OtpVerificationResponseEntity on success
  /// Throws exception on failure
  Future<OtpVerificationResponseEntity> execute({
    required String phoneNumber,
    required String otp,
  }) async {
    // Validate input
    if (phoneNumber.trim().isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    if (otp.trim().isEmpty) {
      throw Exception('OTP cannot be empty');
    }

    if (otp.length != 6) {
      throw Exception('OTP must be 6 digits');
    }

    // Create OTP verification entity
    final otpEntity = OtpVerificationEntity(
      phoneNumber: phoneNumber.trim(),
      otp: otp.trim(),
    );

    // Call repository
    return await repository.verifyOtp(otpEntity);
  }
}

