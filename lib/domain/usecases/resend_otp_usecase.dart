import '../repositories/auth_repository.dart';

/// Use case for resending OTP
/// This encapsulates the business logic for resending OTP
class ResendOtpUseCase {
  final AuthRepository repository;

  ResendOtpUseCase(this.repository);

  /// Execute resend OTP
  /// Returns true on success
  /// Throws exception on failure
  Future<bool> execute(String email) async {
    // Validate input
    if (email.trim().isEmpty) {
      throw Exception('Email cannot be empty');
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw Exception('Please enter a valid email address');
    }

    // Call repository
    return await repository.resendOtp(email.trim());
  }
}

