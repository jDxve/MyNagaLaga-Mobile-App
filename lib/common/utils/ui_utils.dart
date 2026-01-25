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
}