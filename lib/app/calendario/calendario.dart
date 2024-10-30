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
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
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
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    width: 6,
                    height: 6,
                  ),
                );
              }
              return SizedBox();
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

  const AddEventForm({Key? key, required this.onEventAdded}) : super(key: key);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Título'),
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
          TextFormField(
            decoration: const InputDecoration(labelText: 'Descripción'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor agrege una descripcion';
              }
              return null;
            },
            onSaved: (value) {
              _description = value ?? '';
            },
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Seleccionar Fecha'),
                ),
              ),
              Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectTime(context, true),
                  child: const Text('Hora de Inicio'),
                ),
              ),
              Text(_startTime.format(context)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectTime(context, false),
                  child: const Text('Hora de Término'),
                ),
              ),
              Text(_endTime.format(context)),
            ],
          ),
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
            child: const Text('Agregar Evento'),
          ),
        ],
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
