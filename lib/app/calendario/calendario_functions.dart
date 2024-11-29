import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime?> getUserBirthdate() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String birthdateString = userDoc['fecha_nacimiento'];
        DateFormat format = DateFormat('dd/MM/yyyy'); 
        DateTime birthdate = format.parse(birthdateString);
        return birthdate;
      }
    }
  } catch (e) {
    print('Error al obtener la fecha de nacimiento: $e');
  }
  return null;
}

bool isBirthday(DateTime date, DateTime? birthdate) {
  if (birthdate == null) return false;
  return date.month == birthdate.month && date.day == birthdate.day;
}

void showEventsModal(BuildContext context, DateTime selectedDay) async {
  String formattedDate = DateFormat('EEEE, d MMMM', 'es_ES').format(selectedDay);
  DateTime? birthdate = await getUserBirthdate(); // Obtener la fecha de nacimiento
  bool isUserBirthday = isBirthday(selectedDay, birthdate); // Renombrar a isUserBirthday
  List<Map<String, dynamic>> events = await getUserEvents(selectedDay); // Obtener eventos para la fecha seleccionada

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        height: 400, // Ajusta la altura según sea necesario
        decoration: const BoxDecoration(
          color: Color(0xFF90CFC4), // Fondo verde personalizado
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Eventos de $formattedDate',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (isUserBirthday) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Icon(
                      Icons.cake,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '🎉 ¡Feliz cumpleaños!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            if (events.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            event['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event['description'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Desde: ${DateFormat('HH:mm').format(event['startTime'])} Hasta: ${DateFormat('HH:mm').format(event['endTime'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.event_busy,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay eventos para este día.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    },
  );
}

class Event {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });
}
Future<void> addEventToFirestore(Event event, BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    throw Exception("Usuario no autenticado");
  }

  try {
    await FirebaseFirestore.instance.collection('fechas_almacenadas').doc(uid).set({
      'title': event.title,
      'description': event.description,
      'startTime': event.startTime.toIso8601String(),
      'endTime': event.endTime.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evento agregado exitosamente'),
        duration: Duration(seconds: 3), // Duración del Snackbar
      ),
    );
  } catch (e) {
    // Mostrar un mensaje de error si ocurre algún problema
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al agregar el evento: ${e.toString()}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
Future<List<Map<String, dynamic>>> getUserEvents(DateTime selectedDay) async {
  List<Map<String, dynamic>> events = [];
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Acceder a la colección 'fechas_almacenadas'
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('fechas_almacenadas')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // Obtener el campo startTime y endTime del documento
        String startTimeString = userDoc['startTime'];
        String endTimeString = userDoc['endTime'];

        // Convertir las cadenas a DateTime
        DateTime startTime = DateTime.parse(startTimeString);
        DateTime endTime = DateTime.parse(endTimeString);

        // Comparar solo las fechas (día, mes y año)
        DateTime startDate = DateTime(startTime.year, startTime.month, startTime.day);
        DateTime endDate = DateTime(endTime.year, endTime.month, endTime.day);
        DateTime selectedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

        // Verificar si el evento está en la fecha seleccionada
        if (selectedDate.isAtSameMomentAs(startDate) || selectedDate.isAtSameMomentAs(endDate) ||
            (selectedDate.isAfter(startDate) && selectedDate.isBefore(endDate))) {
          events.add({
            'title': userDoc['title'],
            'description': userDoc['description'],
            'startTime': startTime,
            'endTime': endTime,
          });
        }
      }
    }
  } catch (e) {
    print('Error al obtener eventos: $e');
  }
  return events;
}
