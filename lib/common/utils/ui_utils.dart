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
    if (value.trim().length != 8) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'OTP must contain only numbers';
    }
    return null;
  }

  /// Converts date from MM/dd/yyyy format to yyyy-MM-dd format (for API)
  static String convertDateToApiFormat(String date) {
    try {
      final parsed = DateFormat('MM/dd/yyyy').parse(date);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (e) {
      // If parsing fails, try to return as-is or handle error
      return date;
    }
  }

  /// Converts date from yyyy-MM-dd format to MM/dd/yyyy format (for display)
  static String convertDateToDisplayFormat(String date) {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('MM/dd/yyyy').format(parsed);
    } catch (e) {
      // If parsing fails, return as-is
      return date;
    }
  }

  /// Formats a DateTime to yyyy-MM-dd format
  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Formats a DateTime to MM/dd/yyyy format
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Converts gender from lowercase to proper case (for API)
  static String convertGenderToApiFormat(String? gender) {
    if (gender == null) return 'Male';
    if (gender.toLowerCase() == 'male') return 'Male';
    if (gender.toLowerCase() == 'female') return 'Female';
    return 'Male'; // Default
  }

  /// Converts gender from proper case to lowercase (for display)
  static String convertGenderToDisplayFormat(String? gender) {
    if (gender == null) return 'male';
    if (gender.toLowerCase() == 'male') return 'male';
    if (gender.toLowerCase() == 'female') return 'female';
    return 'male'; // Default
  }

  /// Formats phone number with +63 prefix
  static String formatPhoneWithPrefix(String phone) {
    final cleaned = phone.trim().replaceAll(' ', '');
    if (cleaned.startsWith('+63')) {
      return cleaned;
    } else if (cleaned.startsWith('09')) {
      return '+63${cleaned.substring(1)}';
    } else if (cleaned.startsWith('9')) {
      return '+63$cleaned';
    }
    return '+63$cleaned';
  }

  /// Removes +63 prefix from phone number
  static String formatPhoneWithoutPrefix(String phone) {
    final cleaned = phone.trim().replaceAll(' ', '');
    if (cleaned.startsWith('+63')) {
      return '0${cleaned.substring(3)}';
    } else if (cleaned.startsWith('63')) {
      return '0${cleaned.substring(2)}';
    }
    return cleaned;
  }

  static const List<String> idTypes = [
    "National ID",
    "Driver's License",
    "Passport",
    "Voter's ID",
    "PhilHealth ID",
    "SSS ID",
    "UMID",
    "Postal ID",
    "E-Card/UMID",
    "Employee ID",
    "PRC ID",
    "Senior Citizen ID",
    "COMELEC/Voter ID",
    "PhilID/ePhilID",
    "NBI Clearance",
    "IBP ID",
    "Firearms License",
    "AFPSLAI ID",
    "PVAO ID",
    "AFP Beneficiary ID",
    "BIR TIN",
    "Pag-IBIG ID",
    "PWD ID",
    "Solo Parent ID",
    "Pantawid 4Ps ID",
    "Barangay ID",
    "School ID",
    "Other",
  ];
  
  static String convertIdTypeToApiFormat(String? displayIdType) {
    if (displayIdType == null || displayIdType.isEmpty) return 'OTHER';

    // Map display names to backend enum values
    final idTypeMap = {
      "Driver's License": 'DRIVERS_LICENSE',
      'Drivers License': 'DRIVERS_LICENSE',
      'E-Card/UMID': 'E_CARD_UMID',
      'Employee ID': 'EMPLOYEE_ID',
      'PRC ID': 'PRC_ID',
      'Passport': 'PASSPORT',
      'Senior Citizen ID': 'SENIOR_CITIZEN_ID',
      'SSS ID': 'SSS_ID',
      'COMELEC/Voter ID': 'COMELEC_VOTER_ID',
      'PhilID/ePhilID': 'PHILID_EPHILID',
      'NBI Clearance': 'NBI_CLEARANCE',
      'IBP ID': 'IBP_ID',
      'Firearms License': 'FIREARMS_LICENSE',
      'AFPSLAI ID': 'AFPSLAI_ID',
      'PVAO ID': 'PVAO_ID',
      'AFP Beneficiary ID': 'AFP_BENEFICIARY_ID',
      'BIR TIN': 'BIR_TIN',
      'Pag-IBIG ID': 'PAGIBIG_ID',
      'PWD ID': 'PWD_ID',
      'Solo Parent ID': 'SOLO_PARENT_ID',
      'Pantawid 4Ps ID': 'PANTAWID_4PS_ID',
      'Barangay ID': 'BARANGAY_ID',
      'Postal ID': 'POSTAL_ID',
      'PhilHealth ID': 'PHILHEALTH_ID',
      'School ID': 'SCHOOL_ID',
      'Other': 'OTHER',
    };

    return idTypeMap[displayIdType] ?? 'OTHER';
  }
}
