import 'package:flutter/material.dart';

mixin AuthFormMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();

  bool validateForm() => formKey.currentState?.validate() ?? false;

  void showValidationErrors() {
    formKey.currentState?.validate();
  }
}
