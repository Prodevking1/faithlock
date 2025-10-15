import 'package:flutter/material.dart';

class SignInFormState {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  bool validate() => formKey.currentState?.validate() ?? false;
}
