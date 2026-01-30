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
  final String tokenType;

  SessionData({
    required this.accessToken,
    required this.tokenType,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
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
    // Backend wraps response in { success: true, data: {...} }
    final data = json['data'] ?? json;
    
    return VerifyOtpResponse(
      session: data['session'] != null 
          ? SessionData.fromJson(data['session']) 
          : null,
      userId: data['user']?['id']?.toString() ?? '',
      userEmail: data['user']?['email'],
      mobileUser: User.fromJson(data['mobile_user'] ?? {}),
    );
  }
}