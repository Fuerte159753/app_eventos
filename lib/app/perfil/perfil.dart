import 'dart:io'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:app_eventos/app/widgets/menu_lateral.dart';
import 'package:app_eventos/app/perfil/perfil_functions.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _nombre;
  String? _apellido;
  String? _email;
  String? _fechaNacimiento;
  String? _errorMessage;
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      PerfilService perfilService = PerfilService();
      final userData = await perfilService.getUserData();
      if (userData != null) {
        setState(() {
          _nombre = userData['nombre'];
          _apellido = userData['apellido'];
          _email = userData['email'];
          _fechaNacimiento = userData['fecha_nacimiento'];
          _photoUrl = userData['photo_url'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No se encontraron datos del usuario.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const MenuLateral(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: const Text(
                'Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Abrir el menú lateral
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              flexibleSpace: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      color: const Color(0xFF90cfc4),
                    ),
                  ),
                  ClipPath(
                    clipper: TopHalfCircleClipper(),
                    child: Container(
                      height: 150,
                      color: const Color(0xFF008080),
                    ),
                  ),
                ],
              ),
            ),
          ),

          
          Positioned(
            top: 120, 
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: screenWidth * 0.1,
                      backgroundImage:
                          _photoUrl != null ? NetworkImage(_photoUrl!) : null,
                      child: _photoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Información del usuario',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF37807e),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildUserInfo('Nombre', _nombre, screenWidth),
                    _buildUserInfo('Apellido', _apellido, screenWidth),
                    _buildUserInfo('Email', _email, screenWidth),
                    _buildUserInfo('Fecha de nacimiento', _fechaNacimiento, screenWidth),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(String label, String? value, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF37807e),
            ),
          ),
          Text(
            value ?? 'Desconocido',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class TopHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 100,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}