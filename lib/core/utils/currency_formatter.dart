import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String convertToIdr(dynamic number, {int decimalDigit = 0}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );

    if (number is int) {
      return currencyFormatter.format(number);
    } else if (number is double) {
      return currencyFormatter.format(number);
    } else {
      return 'Rp 0';
    }
  }

  static String compact(dynamic number) {
    final formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(number);
  }
}
