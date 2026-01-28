import 'package:intl/intl.dart';

class UIUtils {
  static String numberFormat(double amount, {String symbol = '₱'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '$symbol ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    if (!isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Please enter a complete address';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    final phoneRegex = RegExp(r'^(09|\+639)\d{9}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Please enter a valid Philippine mobile number';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }
    if (value.trim().length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'OTP must contain only numbers';
    }
    return null;
  }
}