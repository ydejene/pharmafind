import 'package:flutter/material.dart';

/// Centralised navigation helpers for the authentication flow.
///
/// Every screen uses these instead of hard-coding route strings, so renaming
/// a route only requires a change here.
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

  static void toHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
  }
}
