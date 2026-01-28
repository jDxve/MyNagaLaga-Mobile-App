// lib/features/auth/models/otp_models.dart

import '../../account/models.dart/user.dart';

class OtpVerificationRequest {
  final String email;
  final String token;
  final String type;

  OtpVerificationRequest({
    required this.email,
    required this.token,
    this.type = 'email',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'type': type,
    };
  }
}

class VerifyOtpResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final User user;

  VerifyOtpResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 3600,
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}