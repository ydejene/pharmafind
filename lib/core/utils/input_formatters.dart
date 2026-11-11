import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9+]'), '');
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

class RwandaPhoneValidator {
  RwandaPhoneValidator._();

  static String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+250') && cleaned.length == 13) return null;
    if (cleaned.startsWith('07') && cleaned.length == 10) return null;
    return 'Enter a valid Rwandan phone number';
  }
}
