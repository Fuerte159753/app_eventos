import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  bool isAuthenticated() {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }
}