import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberUtils {
  static void formatInput(
    TextEditingController controller,
    String value, {
    bool isDecimal = false,
    Function()? onCalculated,
  }) {
    int cursorPosition = controller.selection.baseOffset;
    int lengthBefore = controller.text.length;

    String cleanText = value.replaceAll(RegExp(r'[^0-9,]'), '');

    if (!isDecimal) {
      cleanText = cleanText.replaceAll(',', '');
    } else {
      if (cleanText.indexOf(',') != cleanText.lastIndexOf(',')) {
        cleanText = cleanText.substring(0, cleanText.length - 1);
      }
    }

    if (cleanText.isEmpty) {
      controller.text = '';
      if (onCalculated != null) onCalculated();
      return;
    }

    List<String> parts = cleanText.split(',');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? ',${parts[1]}' : '';

    if (integerPart.isNotEmpty) {
      BigInt intValue = BigInt.tryParse(integerPart) ?? BigInt.zero;
      integerPart = intValue.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }

    String formattedText = '$integerPart$decimalPart';

    if (controller.text != formattedText) {
      int lengthAfter = formattedText.length;
      cursorPosition += (lengthAfter - lengthBefore);

      if (cursorPosition < 0) cursorPosition = 0;
      if (cursorPosition > formattedText.length) {
        cursorPosition = formattedText.length;
      }

      controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: cursorPosition),
      );
    }

    if (onCalculated != null) onCalculated();
  }

  static Decimal parseToDecimal(String formattedValue) {
    String clean = formattedValue
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    if (clean.isEmpty) return Decimal.zero;
    try {
      return Decimal.parse(clean);
    } catch (e) {
      return Decimal.zero;
    }
  }

  static BigInt parseToBigInt(String formattedValue) {
    Decimal dec = parseToDecimal(formattedValue);
    return BigInt.parse(dec.toBigInt().toString());
  }

  static Decimal _toDecimal(dynamic number) {
    if (number == null) return Decimal.zero;
    if (number is Decimal) return number;
    if (number is int) return Decimal.fromInt(number);
    if (number is BigInt) return Decimal.parse(number.toString());
    if (number is double) return Decimal.parse(number.toString());
    if (number is String) return parseToDecimal(number);
    return Decimal.zero;
  }

  static String formatNumber(dynamic number, {int? decimalDigits}) {
    Decimal dec = _toDecimal(number);

    if (decimalDigits != null) {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: '',
        decimalDigits: decimalDigits,
      ).format(dec.toDouble()).trim();
    } else {
      NumberFormat formatter = NumberFormat.decimalPattern('id_ID');
      formatter.minimumFractionDigits = 0;
      formatter.maximumFractionDigits = 8;
      return formatter.format(dec.toDouble());
    }
  }

  static String toIdr(dynamic number, {int? decimalDigits}) {
    return 'Rp ${formatNumber(number, decimalDigits: decimalDigits)}';
  }

  static bool isValidAmount(String value, {bool allowZero = false}) {
    Decimal dec = parseToDecimal(value);
    if (!allowZero && dec <= Decimal.zero) return false;
    if (allowZero && dec < Decimal.zero) return false;
    return true;
  }

  static String compact(dynamic number) {
    Decimal dec = _toDecimal(number);
    final formatter = NumberFormat.compact(locale: 'en_US');
    return formatter.format(dec.toDouble());
  }

  static double calculatePercentage(dynamic amount, dynamic total) {
    Decimal decAmount = _toDecimal(amount);
    Decimal decTotal = _toDecimal(total);

    if (decTotal <= Decimal.zero || decAmount <= Decimal.zero) {
      return 0.0;
    }

    return (decAmount.toDouble() / decTotal.toDouble()) * 100;
  }

  static String calculateStrPercentage(
    dynamic amount,
    dynamic total, {
    int fractionDigits = 0,
  }) {
    double result = calculatePercentage(amount, total);

    return result.toStringAsFixed(fractionDigits);
  }
}
