import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sincronizarEventosConGoogleCalendar() async {
  const List<String> scopes = [calendar.CalendarApi.calendarScope];

  try {
    // Inicializar GoogleSignIn
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print('El usuario no ha iniciado sesión en Google.');
      return;
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? accessToken = googleAuth.accessToken;
    if (accessToken == null) {
      print('Error al obtener el access token.');
      return;
    }

    var client = http.Client();

    // Crear el cliente autenticado
    final authenticatedHttpClient = authenticatedClient(
      client,
      AccessCredentials(
        AccessToken('Bearer', accessToken, DateTime.now().add(const Duration(hours: 1))),
        '',
        scopes,
      ),
    );

    // Instancia de la API de Google Calendar
    var calendarApi = calendar.CalendarApi(authenticatedHttpClient);

    // Obtener eventos del calendario principal
    var events = await calendarApi.events.list("primary");

    // Obtener UID del usuario autenticado
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print('Error: No se pudo obtener el UID del usuario.');
      return;
    }

    // Conexión a Firestore
    final CollectionReference userEventsCollection = FirebaseFirestore.instance
        .collection('fechas_almacenadas')
        .doc(uid)
        .collection('eventos');

    // Guardar cada evento en Firestore
    if (events.items != null) {
      for (var event in events.items!) {
        if (event.start?.dateTime != null) {
          await userEventsCollection.add({
            'summary': event.summary ?? 'Sin título',
            'start': event.start!.dateTime!.toIso8601String(),
            'end': event.end?.dateTime?.toIso8601String(),
          });
          print('Evento guardado: ${event.summary}');
        }
      }
      print('Sincronización completada con éxito.');
    } else {
      print('No se encontraron eventos.');
    }
  } catch (e) {
    print('Error al obtener eventos: $e');
  }
}
