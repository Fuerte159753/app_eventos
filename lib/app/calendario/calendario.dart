import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para la localización
import 'package:app_eventos/app/widgets/menu_lateral.dart'; // Asegúrate de importar tu menú lateral
import 'package:intl/intl.dart'; // Para formatear la fecha

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(); // Inicializa la localización para fechas
  }

  void _showEventsModal(BuildContext context, DateTime selectedDay) {
    String formattedDate = DateFormat('EEEE, d MMMM', 'es_ES').format(selectedDay);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
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
              const Text('No hay eventos para este día.'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'calendario',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
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
                color: const Color(0xFF90cfc4), // Color claro
              ),
            ),
            ClipPath(
              clipper: TopHalfCircleClipper(),
              child: Container(
                height: 150, // Altura del medio círculo
                color: const Color(0xFF008080), // Color oscuro
              ),
            ),
          ],
        ),
      ),
      drawer: const MenuLateral(), // Aquí añadimos el menú lateral
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          locale: 'es_ES',
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            _showEventsModal(context, selectedDay);
          },
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// ClipPath para el medio círculo en la parte superior del AppBar
class TopHalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}