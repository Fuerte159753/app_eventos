import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  bool _isLoading = false;

  Future<void> registrarUsuario() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String? fechaNacimiento = _selectedDate != null
          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
          : null;

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userCredential.user?.uid)
          .set({
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'fecha_nacimiento': fechaNacimiento,
        'email': _emailController.text,
        'edad': _calcularEdad(_selectedDate),
        'photo_url': '',
        'sincronizacion': '0',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso!')),
      );

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int? _calcularEdad(DateTime? fechaNacimiento) {
    if (fechaNacimiento == null) return null;
    final today = DateTime.now();
    int age = today.year - fechaNacimiento.year;
    if (today.month < fechaNacimiento.month ||
        (today.month == fechaNacimiento.month &&
            today.day < fechaNacimiento.day)) {
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
      backgroundColor: const Color(0xFF90cfc4), // Color de fondo
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header con título centrado "Regístrate"
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: TopHalfCircleClipper(),
                    child: Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Color(0xFF008080), // Color del header
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'REGÍSTRATE',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Formulario más alto y con desplazamiento si es necesario
            Container(
              height: MediaQuery.of(context).size.height *
                  0.95, // Más espacio vertical
              width: MediaQuery.of(context).size.width *
                  0.95, // Más espacio horizontal
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                // Desplazamiento activado
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Nombre',
                          style: TextStyle(
                            color: Color(0xFF377F7E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF2ECEC).withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce tu nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Apellidos',
                          style: TextStyle(
                            color: Color(0xFF377F7E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _apellidoController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF2ECEC).withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, introduce tu apellido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Fecha de nacimiento',
                          style: TextStyle(
                            color: Color(0xFF377F7E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Row(
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Fecha de nacimiento'
                                    : 'Fecha: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Correo eléctronico',
                          style: TextStyle(
                            color: Color(0xFF377F7E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF2ECEC).withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Por favor, introduce un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Contraseña',
                          style: TextStyle(
                            color: Color(0xFF377F7E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF2ECEC).withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Confirmar contraseña',
                          style: TextStyle(
                            color: Color(0xFF377F7E),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF2ECEC).withOpacity(0.7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 18),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: _isLoading
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.teal,
                                  size: 50,
                                )
                              : ElevatedButton(
                                  onPressed: registrarUsuario,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF90cfc4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 50,
                                    ),
                                  ),
                                  child: const Text(
                                    'Registrarse',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Center(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recorte decorativo para el header
class TopHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
