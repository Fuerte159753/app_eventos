import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> sincronizarEventosConGoogleCalendar() async {
  const List<String> _scopes = [calendar.CalendarApi.calendarScope];
  final GoogleSignIn googleSignIn = GoogleSignIn();
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

  // Declara authenticatedClient antes de usarlo
  /*final authenticatedClient = authenticatedClient(
    client,
    AccessCredentials(
      AccessToken('Bearer', accessToken, DateTime.now().add(Duration(hours: 1))),
      '',
      _scopes, // Asegúrate de pasar la lista de scopes
    ),
  );
  var calendarApi = calendar.CalendarApi(authenticatedClient);*/
  // Obtén la lista de eventos desde Google Calendar
  try {
    //var events = await calendarApi.events.list("primary");
    // Aquí puedes manejar la sincronización con tus eventos locales
    /*for (var event in events.items!) {
      // Procesa cada evento, por ejemplo, guardándolo en tu Firestore
      print('Evento: ${event.summary}');
    }*/
  } catch (e) {
    print('Error al obtener eventos: $e');
  } finally {
    client.close();
  }
}