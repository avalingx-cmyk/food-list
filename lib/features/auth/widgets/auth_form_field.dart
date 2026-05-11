import 'package:flutter/material.dart';

class AuthFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const AuthFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
    );
  }
}
