import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String convertToIdr(dynamic number, {int decimalDigit = 0}) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );

    if (number == null) return 'Rp 0';

    if (number is int || number is double) {
      return currencyFormatter.format(number);
    } else if (number is BigInt) {
      return currencyFormatter.format(number.toDouble());
    } else if (number is String) {
      final parsed = double.tryParse(number);
      return parsed != null ? currencyFormatter.format(parsed) : 'Rp 0';
    }

    return 'Rp 0';
  }

  static String compact(dynamic number) {
    if (number == null) return '0';

    num valueToFormat = 0;

    if (number is int || number is double) {
      valueToFormat = number;
    } else if (number is BigInt) {
      valueToFormat = number.toDouble();
    } else if (number is String) {
      valueToFormat = double.tryParse(number) ?? 0;
    }

    final formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(valueToFormat);
  }
}
