import 'package:app_eventos/app/calendario/calendario.dart';
import 'package:app_eventos/app/inicio.dart';
import 'package:app_eventos/app/new/new.dart';
import 'package:app_eventos/app/perfil/perfil.dart';
import 'package:app_eventos/pantalla%20de%20carga/carga.dart';
import 'package:flutter/material.dart';
import 'package:app_eventos/login/login.dart';
import 'package:app_eventos/registro/registro.dart';
import 'package:app_eventos/auth/auth_service.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final authService = AuthService();
    switch (settings.name) {
      case '/carga':
        return MaterialPageRoute(builder: (_) => const PantallaDeCarga());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/registro':
        return MaterialPageRoute(builder: (_) => const RegistroScreen());
      case '/inicio':
        if (authService.isAuthenticated()) {
          return MaterialPageRoute(builder: (_) => const InicioPage());
        } else {
          return _redirectToLogin();
        }
      case '/perfil':
        if (authService.isAuthenticated()) {
          return MaterialPageRoute(builder: (_) => const PerfilPage());
        } else {
          return _redirectToLogin();
        }

      case '/addevento':
        if (authService.isAuthenticated()) {
          return MaterialPageRoute(builder: (_) => const NewPage());
        } else {
          return _redirectToLogin();
        }
      case '/calendario':
        if (authService.isAuthenticated()) {
          return MaterialPageRoute(builder: (_) => const CalendarPage());
        } else {
          return _redirectToLogin();
        }
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
  static MaterialPageRoute _redirectToLogin() {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }
}
