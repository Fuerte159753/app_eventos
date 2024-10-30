import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isObscured = true;

  String? validateInputs() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Por favor, introduce un correo electrónico válido.';
    }
    if (password.isEmpty) {
      return 'Por favor, introduce tu contraseña.';
    }

    return null;
  }

  Future<void> signIn() async {
    final validationError = validateInputs();
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/inicio');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String getErrorMessage(String code) {
    switch (code) {
      default:
        return 'Verifica tus datos';
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/inicio');
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión con Google: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF90cfc4), // Color de fondo de la pantalla
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sección superior con el logo y fondo
            SizedBox(
              height: 220,
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
                  Positioned(
                    top: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png', // Reemplaza con la ruta correcta de tu logo
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Espacio entre logo y card

            Container(
              height: 500, // Mantener la altura del formulario
              decoration: const BoxDecoration(
                color: Color.fromARGB(
                    255, 255, 255, 255), // Color de fondo del formulario
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alineación a la izquierda
                  children: [
                    const Center(
                      child: Text(
                        'BIENVENIDO',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF377F7E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ingresa tu correo',
                      style: TextStyle(
                        color: Color(0xFF377F7E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF2ECEC).withOpacity(0.7),
                        hintText: 'user@gmail.com',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ingresa tu contraseña',
                      style: TextStyle(
                        color: Color(0xFF377F7E),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF2ECEC).withOpacity(0.7),
                        hintText: '*********',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Muestra el mensaje de error aquí
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Center(
                      child: _isLoading
                          ? LoadingAnimationWidget.hexagonDots(
                              color: Colors.teal,
                              size: 50,
                            )
                          : ElevatedButton(
                              onPressed: signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 144, 207, 196),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal: 40,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 253, 253, 253),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20), // Espacio entre los botones
                    Center(
                      child: ElevatedButton(
                        onPressed: signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 40,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/google_icon.png', // Ruta del ícono de Google
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Iniciar sesión con Google',
                              style: TextStyle(
                                color: Color(0xFF377F7E),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/registro');
                        },
                        child: const Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 100); // Baja un poco en la esquina izquierda

    // Curva en el centro
    path.quadraticBezierTo(
      size.width / 2,
      size.height +
          100, // Punto de control para que la curva sea más pronunciada
      size.width, size.height - 100, // Baja un poco en la esquina derecha
    );

    // Cierra el camino en la parte superior
    path.lineTo(size.width, 0); // Línea hacia la esquina superior derecha
    path.lineTo(0, 0); // Línea hacia la esquina superior izquierda
    path.close(); // Cierra el camino

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
