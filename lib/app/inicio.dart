import 'package:flutter/material.dart';
import 'package:app_eventos/app/widgets/menu_lateral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          DateTime startDate =
              DateTime(startTime.year, startTime.month, startTime.day);
          DateTime endDate = DateTime(endTime.year, endTime.month, endTime.day);
          DateTime selectedDate =
              DateTime(today.year, today.month, today.day);
          if (selectedDate.isAtSameMomentAs(startDate) ||
              selectedDate.isAtSameMomentAs(endDate) ||
              (selectedDate.isAfter(startDate) &&
                  selectedDate.isBefore(endDate))) {
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BFA6), Color(0xFF008080)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Text(
                  "Planifica tu día",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Centra el contenido verticalmente
            children: [
              if (eventTitle != null && eventDescription != null)
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Evento del día:',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          eventTitle!,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          eventDescription!,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Text(
                  'No tienes eventos para hoy.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}