class LoginRequest {
  final String email;

  LoginRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

class SignupRequest {
  final String email;
  final String fullName;
  final String sex;
  final String address;
  final String? phoneNumber;

  SignupRequest({
    required this.email,
    required this.fullName,
    required this.sex,
    required this.address,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'sex': sex,
      'address': address,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

class OtpResponse {
  final bool sent;

  OtpResponse({required this.sent});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns { success: true, data: { sent: true } }
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      return OtpResponse(
        sent: json['data']['sent'] ?? false,
      );
    }
    return OtpResponse(
      sent: json['sent'] ?? false,
    );
  }
}

class AuthSessionState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? accessToken;

  AuthSessionState({
    required this.isAuthenticated,
    this.userId,
    this.email,
    this.accessToken,
  });

  // A helper for the initial unauthenticated state
  factory AuthSessionState.empty() => AuthSessionState(isAuthenticated: false);
}