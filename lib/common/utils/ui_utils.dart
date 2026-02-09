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
    final nameRegex = RegExp(r"^[a-zA-Z\s\-'.]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Full name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 5) {
      return 'Please enter a complete address (minimum 5 characters)';
    }
    if (value.trim().length > 200) {
      return 'Address is too long (maximum 200 characters)';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    
    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final phoneRegex = RegExp(r'^(09|\+639)\d{9}$');
    
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid Philippine mobile number (09XXXXXXXXX)';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP code is required';
    }
    
    final cleaned = value.trim().replaceAll(RegExp(r'\s'), '');
    
    if (cleaned.length != 6) {
      return 'OTP must be exactly 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(cleaned)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }

  static String convertDateToApiFormat(String date) {
    try {
      final parsed = DateFormat('MM/dd/yyyy').parse(date);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (e) {
      return date;
    }
  }

  static String convertDateToDisplayFormat(String date) {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(date);
      return DateFormat('MM/dd/yyyy').format(parsed);
    } catch (e) {
      return date;
    }
  }

  static String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateForDisplay(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  static String convertGenderToApiFormat(String? gender) {
    if (gender == null) return 'Male';
    if (gender.toLowerCase() == 'male') return 'Male';
    if (gender.toLowerCase() == 'female') return 'Female';
    return 'Male';
  }

  static String convertGenderToDisplayFormat(String? gender) {
    if (gender == null) return 'male';
    if (gender.toLowerCase() == 'male') return 'male';
    if (gender.toLowerCase() == 'female') return 'female';
    return 'male';
  }

  static String formatPhoneWithPrefix(String phone) {
    final cleaned = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+63')) {
      return cleaned;
    } else if (cleaned.startsWith('09')) {
      return '+63${cleaned.substring(1)}';
    } else if (cleaned.startsWith('9')) {
      return '+63$cleaned';
    }
    return '+63$cleaned';
  }

  static String formatPhoneWithoutPrefix(String phone) {
    final cleaned = phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
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