import 'package:flutter/material.dart';

class AuthNavigation {
  AuthNavigation._();

  static void toLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  static void toRegister(BuildContext context) {
    Navigator.of(context).pushNamed('/register');
  }

  static void toForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed('/forgot-password');
  }

  // Clears the auth screens so the back button can't return to them.
  static void toHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }
}
