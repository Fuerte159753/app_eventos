import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:app_eventos/app/widgets/menu_lateral.dart';
import 'package:app_eventos/app/calendario/calendario_functions.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _birthdate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _loadBirthdate();
  }

  Future<void> _loadBirthdate() async {
    DateTime? birthdate = await getUserBirthdate();
    setState(() {
      _birthdate = birthdate;
    });
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Evento'),
          content: AddEventForm(onEventAdded: (event) {
            Navigator.of(context).pop();
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
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
                height: 200,
                color: const Color(0xFF008080),
              ),
            ),
          ],
        ),
      ),
      drawer: const MenuLateral(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          locale: 'es_ES',
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            showEventsModal(context, selectedDay);
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
            markersMaxCount: 1,
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (_birthdate != null && isBirthday(day, _birthdate)) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    width: 6,
                    height: 6,
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEventForm extends StatefulWidget {
  final Function(Event) onEventAdded;

  const AddEventForm({super.key, required this.onEventAdded});

  @override
  _AddEventFormState createState() => _AddEventFormState();
}

class _AddEventFormState extends State<AddEventForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Título',
              labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black87, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese un título';
              }
              return null;
            },
            onSaved: (value) {
              _title = value!;
            },
          ),
          const SizedBox(height: 16),

          // Descripción
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Descripción',
              labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black87, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor agregue una descripción';
              }
              return null;
            },
            onSaved: (value) {
              _description = value ?? '';
            },
          ),
          const SizedBox(height: 16),

          // Selección de Fecha
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 3,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  child: const Text(
                    'Seleccionar Fecha',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hora de Inicio
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 3,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  child: const Text(
                    'Hora de Inicio',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _startTime.format(context),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hora de Término
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 3,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  child: const Text(
                    'Hora de Término',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _endTime.format(context),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botón de agregar evento
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // Crear evento
                Event event = Event(
                  title: _title,
                  description: _description,
                  startTime: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _startTime.hour,
                    _startTime.minute,
                  ),
                  endTime: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _endTime.hour,
                    _endTime.minute,
                  ),
                );
                await addEventToFirestore(event, context);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              elevation: 5,
              backgroundColor: Colors.black87,
            ),
            child: const Text(
              'Agregar Evento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}

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
