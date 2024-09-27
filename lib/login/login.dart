import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:app_eventos/login/login_styles.dart';

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

  String? validateInputs() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      return 'Por favor, introduce un correo electrónico válido.';
    }
    if (_passwordController.text.isEmpty) {
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
        _errorMessage = 'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
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
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: kInputDecorationEmail,
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: kInputDecorationPassword,
                      obscureText: true,
                    ),
                    const SizedBox(height: kSpacing),
                    if (_isLoading)
                      LoadingAnimationWidget.hexagonDots(
                        color: kLoadingColor,
                        size: kLoadingSize,
                      )
                    else ...[
                      ElevatedButton(
                        onPressed: _isLoading ? null : signIn,
                        style: kButtonStyle,
                        child: const Text('Entrar'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : signInWithGoogle,
                        style: kButtonStyle,
                        child: const Text('Iniciar sesión con Google'),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: kSpacing),
                      Text(
                        _errorMessage!,
                        style: kErrorTextStyle,
                      ),
                    ],
                    const SizedBox(height: kSpacing),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/registro');
                      },
                      child: const Text(
                        '¿No tienes cuenta? Regístrate aquí',
                        style: kLinkTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}