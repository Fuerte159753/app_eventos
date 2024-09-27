import 'package:flutter/material.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Agregar el Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: const Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('Opción 1'),
              onTap: () {
                // Acciones para Opción 1
                Navigator.pop(context); // Cierra el menú
              },
            ),
            ListTile(
              title: const Text('Opción 2'),
              onTap: () {
                // Acciones para Opción 2
                Navigator.pop(context); // Cierra el menú
              },
            ),
            // Agrega más opciones aquí según sea necesario
          ],
        ),
      ),
      body: Stack(
        children: [
          // Aquí puedes agregar un fondo o cualquier otra cosa que desees
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Gestiona tus eventos',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Abre el menú lateral
                      Scaffold.of(context).openDrawer();
                    },
                    child: const Text('Abrir Menú'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Scaffold.of(context).openDrawer(); // Abre el menú lateral
        },
        child: const Icon(Icons.menu),
      ),
    );
  }
}