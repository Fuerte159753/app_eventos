import 'package:flutter/material.dart';

class RegistroStyles {
  static const TextStyle labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: Colors.red,
    fontSize: 14,
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
    );
  }

  static const EdgeInsets padding = EdgeInsets.all(16.0);
}
