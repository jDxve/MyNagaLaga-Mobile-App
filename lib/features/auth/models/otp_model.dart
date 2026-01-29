import '../../account/models/user.dart';

class OtpVerificationRequest {
  final String email;
  final String token;

  OtpVerificationRequest({
    required this.email,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
    };
  }
}

class SessionData {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  SessionData({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}

class VerifyOtpResponse {
  final SessionData? session;
  final String userId;
  final String? userEmail;
  final User mobileUser;

  VerifyOtpResponse({
    this.session,
    required this.userId,
    this.userEmail,
    required this.mobileUser,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      session: json['session'] != null 
          ? SessionData.fromJson(json['session']) 
          : null,
      userId: json['user']?['id'] ?? '',
      userEmail: json['user']?['email'],
      mobileUser: User.fromJson(json['mobile_user'] ?? {}),
    );
  }
}