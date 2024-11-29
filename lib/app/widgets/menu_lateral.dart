import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_eventos/app/widgets/menu_fuctions.dart';

class MenuLateral extends StatefulWidget {
  const MenuLateral({super.key});

  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  Future<Map<String, String?>> _getUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        String? nombre = userDoc['nombre'];

        return {'nombre': nombre};
      }
    } catch (e) {
      print("Error al obtener los datos del usuario: $e");
    }
    return {'nombre': 'Nombre'};
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/perfil');
            },
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF90cfc4),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF58bcb0),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    FutureBuilder<Map<String, String?>>(
                      future: _getUserInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text(
                            'Error al cargar usuario',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          String nombre = snapshot.data?['nombre'] ?? 'Nombre';
                          return Text(
                            nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading: const Icon(Icons.event, color: Color(0xFF008080), size: 40),
            title: const Text('Eventos',
                style: TextStyle(fontSize: 16, color: Color(0xFF008080))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/inicio');
            },
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 40,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading:
                const Icon(Icons.calendar_today, color: Color(0xFF008080), size: 40),
            title: const Text('Calendario',
                style: TextStyle(fontSize: 16, color: Color(0xFF008080))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/calendario');
            },
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 40,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading: const Icon(Icons.sync, color: Color(0xFF008080), size: 40),
            title: const Text('Sincronizar',
                style: TextStyle(fontSize: 16, color: Color(0xFF008080))),
            onTap: () async {
              await sincronizarEventosConGoogleCalendar();
            },
          ),
        ],
      ),
    );
  }
}