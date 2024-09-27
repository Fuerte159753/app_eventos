import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Asegúrate de importar esta librería
import 'registro_styles.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  DateTime? _selectedDate;
  String? _errorMessage;
  bool _isLoading = false; // Agregar esta variable

  Future<void> registrarUsuario() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true; // Activar el loading
      _errorMessage = null; // Reiniciar el mensaje de error
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      String? fechaNacimiento = _selectedDate != null
          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
          : null;

      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user?.uid).set({
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'fecha_nacimiento': fechaNacimiento,
        'email': _emailController.text,
        'edad': _calcularEdad(_selectedDate),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Registro exitoso!')),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'La contraseña es demasiado débil.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'El correo electrónico ya está en uso.';
        } else {
          _errorMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al registrar el usuario: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Desactivar el loading
      });
    }
  }

  // Función para calcular la edad a partir de la fecha de nacimiento
  int? _calcularEdad(DateTime? fechaNacimiento) {
    if (fechaNacimiento == null) return null;
    final today = DateTime.now();
    int age = today.year - fechaNacimiento.year;
    if (today.month < fechaNacimiento.month || (today.month == fechaNacimiento.month && today.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: RegistroStyles.padding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: RegistroStyles.inputDecoration('Nombre'),
                style: RegistroStyles.labelStyle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tu nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _apellidoController,
                decoration: RegistroStyles.inputDecoration('Apellido'),
                style: RegistroStyles.labelStyle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce tu apellido';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'Fecha de nacimiento'
                          : 'Fecha de nacimiento: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              TextFormField(
                controller: _emailController,
                decoration: RegistroStyles.inputDecoration('Correo electrónico'),
                style: RegistroStyles.labelStyle,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor, introduce un correo electrónico válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: RegistroStyles.inputDecoration('Contraseña'),
                style: RegistroStyles.labelStyle,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: RegistroStyles.inputDecoration('Confirmar contraseña'),
                style: RegistroStyles.labelStyle,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading) // Mostrar el loading cuando está en carga
                LoadingAnimationWidget.hexagonDots(
                  color: Colors.blue, // Cambia el color según tu diseño
                  size: 40, // Cambia el tamaño según tu diseño
                )
              else 
                ElevatedButton(
                  onPressed: registrarUsuario,
                  child: const Text('Registrarse'),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage!,
                    style: RegistroStyles.errorTextStyle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}