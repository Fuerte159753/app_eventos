import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Método para verificar si el usuario está autenticado
  bool isAuthenticated() {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}