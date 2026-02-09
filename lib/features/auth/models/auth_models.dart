class LoginRequest {
  final String email;

  LoginRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
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

  Map<String, dynamic> toJson() => {
        'email': email,
        'fullName': fullName,
        'sex': sex,
        'address': address,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
}

class OtpResponse {
  final bool sent;

  OtpResponse({required this.sent});

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      return OtpResponse(sent: json['data']['sent'] ?? false);
    }
    return OtpResponse(sent: json['sent'] ?? false);
  }
}

class AuthSessionState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? userId;
  final String? email;
  final String? fullName;
  final String? barangayId;
  final String? accessToken;

  AuthSessionState({
    required this.isAuthenticated,
    required this.isLoading,
    this.userId,
    this.email,
    this.fullName,
    this.barangayId,
    this.accessToken,
  });

  factory AuthSessionState.empty() {
    return AuthSessionState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  factory AuthSessionState.loading() {
    return AuthSessionState(
      isAuthenticated: false,
      isLoading: true,
    );
  }
}