import 'package:flutter/material.dart';

import '../../core/constants/auth_routes.dart';

/// Centralised navigation helpers for the authentication flow.
///
/// Every screen uses these instead of hard-coding route strings, so renaming
/// a route only requires a change here.
class AuthNavigation {
  AuthNavigation._();

  static void toLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AuthRoutes.login);
  }

  static void toRegister(BuildContext context) {
    Navigator.of(context).pushNamed(AuthRoutes.register);
  }

  static void toForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed(AuthRoutes.forgotPassword);
  }

  static void toHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(AuthRoutes.home, (_) => false);
  }

  static void toLanguage(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AuthRoutes.language);
  }
}
