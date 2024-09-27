import 'package:app_eventos/app/inicio.dart';
import 'package:app_eventos/app/new/new.dart';
import 'package:app_eventos/app/perfil/perfil.dart';
import 'package:flutter/material.dart';
import 'package:app_eventos/login/login.dart';
import 'package:app_eventos/registro/registro.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/registro':
        return MaterialPageRoute(builder: (_) => const RegistroScreen());
      case '/inicio':
        return MaterialPageRoute(builder: (_) => const InicioPage());
      case '/perfil':
        return MaterialPageRoute(builder: (_) => const PerfilPage());
      case '/addevento':
        return MaterialPageRoute(builder: (_) => const NewPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}