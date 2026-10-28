import 'package:flutter/material.dart';

class AuthNavigation {
  AuthNavigation._();

  static void toLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  static void toRegister(BuildContext context) {
    Navigator.of(context).pushNamed('/register');
  }

  static void toHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  static void toPartnerSignup(BuildContext context) {
    Navigator.of(context).pushNamed('/partner-signup');
  }

  static void skipToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  static void backToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
