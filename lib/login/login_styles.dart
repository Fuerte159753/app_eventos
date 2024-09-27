import 'package:flutter/material.dart';

// Estilo para el campo de texto (correo)
const InputDecoration kInputDecorationEmail = InputDecoration(
  labelText: 'Correo electrónico',
  border: OutlineInputBorder(),
  hintText: 'Introduce tu correo',
);

// Estilo para el campo de texto (contraseña)
const InputDecoration kInputDecorationPassword = InputDecoration(
  labelText: 'Contraseña',
  border: OutlineInputBorder(),
  hintText: 'Introduce tu contraseña',
);

// Estilo para el texto de error
const TextStyle kErrorTextStyle = TextStyle(
  color: Colors.red,
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

// Estilo para el enlace de registro
const TextStyle kLinkTextStyle = TextStyle(
  color: Colors.blue,
  decoration: TextDecoration.underline,
  fontSize: 16,
);

// Tamaños y márgenes
const double kSpacing = 20.0;
const double kLoadingSize = 50.0;

// Estilo del botón
ButtonStyle kButtonStyle = ElevatedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  textStyle: const TextStyle(fontSize: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
);

// Colores de la animación de carga
const Color kLoadingColor = Colors.blue;