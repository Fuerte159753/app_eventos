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
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        height: 300, // Ajusta la altura según sea necesario
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eventos de $formattedDate',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (isUserBirthday) ...[ // Usa la nueva variable
              const Text(
                '🎉 ¡Feliz cumpleaños!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
            if (events.isNotEmpty) ...[
              for (var event in events) ...[
                Text(
                  event['title'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  event['description'],
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Desde: ${DateFormat('HH:mm').format(event['startTime'])} Hasta: ${DateFormat('HH:mm').format(event['endTime'])}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
              ],
            ] else ...[
              const Text('No hay eventos para este día.'),
            ]
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
      SnackBar(
        content: Text('Evento agregado exitosamente'),
        duration: Duration(seconds: 3), // Duración del Snackbar
      ),
    );
  } catch (e) {
    // Mostrar un mensaje de error si ocurre algún problema
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al agregar el evento: ${e.toString()}'),
        duration: Duration(seconds: 3),
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
