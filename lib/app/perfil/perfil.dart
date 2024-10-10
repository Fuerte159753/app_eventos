import 'dart:io'; // Importa solo para móviles
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_eventos/app/widgets/menu_lateral.dart';
import 'package:app_eventos/app/perfil/perfil_functions.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
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
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        await _uploadImageWeb(pickedFile);
      } else {
        final file = File(pickedFile.path);
        await _uploadImageMobile(file);
      }
    }
  }
  Future<void> _uploadImageWeb(XFile file) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance.ref().child('fotos/${user.uid}.jpg');
        await storageRef.putData(await file.readAsBytes());
        final downloadUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          'photo_url': downloadUrl,
        });

        setState(() {
          _photoUrl = downloadUrl;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al subir la imagen: ${e.toString()}';
      });
    }
  }
  Future<void> _uploadImageMobile(File file) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance.ref().child('fotos/${user.uid}.jpg');
        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          'photo_url': downloadUrl,
        });

        setState(() {
          _photoUrl = downloadUrl;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al subir la imagen: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _photoUrl != null
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: _photoUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                        backgroundColor: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImage, // Subir nueva foto
                        child: const Text('Cambiar foto de perfil'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Información del usuario',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildUserInfo('Nombre', _nombre),
                      _buildUserInfo('Apellido', _apellido),
                      _buildUserInfo('Email', _email),
                      _buildUserInfo('Fecha de nacimiento', _fechaNacimiento),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value ?? 'Desconocido',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
