import 'package:flutter/material.dart';
import 'package:app_eventos/app/widgets/menu_lateral.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_eventos/app/widgets/menu_lateral.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});
  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  String? eventTitle;
  String? eventDescription;

  @override
  void initState() {
    super.initState();
    checkTodayEvents();
  }

  Future<void> checkTodayEvents() async {
    DateTime today = DateTime.now();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('fechas_almacenadas')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          String startTimeString = userDoc['startTime'];
          String endTimeString = userDoc['endTime'];
          DateTime startTime = DateTime.parse(startTimeString);
          DateTime endTime = DateTime.parse(endTimeString);
          DateTime startDate = DateTime(startTime.year, startTime.month, startTime.day);
          DateTime endDate = DateTime(endTime.year, endTime.month, endTime.day);
          DateTime selectedDate = DateTime(today.year, today.month, today.day);
          if (selectedDate.isAtSameMomentAs(startDate) || selectedDate.isAtSameMomentAs(endDate) ||
              (selectedDate.isAfter(startDate) && selectedDate.isBefore(endDate))) {
            setState(() {
              eventTitle = userDoc['title'];
              eventDescription = userDoc['description'];
            });
          }
        }
      }
    } catch (e) {
      print('Error al obtener eventos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(250.0),
        child: AppBar(
          title: const Text(
            'Eventos',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
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
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gestiona tus eventos',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Card encima del AppBar
          Positioned(
            top: 200, // Ajusta esta altura según lo que necesites
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Bienvenido a Planify',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Aquí puedes gestionar todos tus eventos de forma rápida y sencilla.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (eventTitle != null && eventDescription != null) ...[
                      Text(
                        'Evento de hoy:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(eventTitle!),
                      Text(eventDescription!),
                    ] else ...[
                      const Text('No tienes eventos para hoy.'),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper para crear el medio círculo en la parte superior
class TopHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Comienza en la esquina superior izquierda
    path.lineTo(0, size.height - 100); // Baja un poco en la esquina izquierda

    // Curva en el centro
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 100, // Punto de control para que la curva sea más pronunciada
      size.width,
      size.height - 100, // Baja un poco en la esquina derecha
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