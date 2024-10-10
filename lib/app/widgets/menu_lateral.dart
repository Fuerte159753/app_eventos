import 'package:flutter/material.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/perfil');
            },
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF90cfc4),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 40), 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF58bcb0),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      'Nombre del usuario',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
              height: 40),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading: Icon(Icons.event, color: Color(0xFF008080), size: 40),
            title: Text('Eventos',
                style: TextStyle(fontSize: 16, color: Color(0xFF008080))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/inicio');
            },
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 40,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading:
                Icon(Icons.calendar_today, color: Color(0xFF008080), size: 40),
            title: Text('Calendario',
                style: TextStyle(fontSize: 16, color: Color(0xFF008080))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/calendario');
            },
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 40,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 30.0),
            leading:
                Icon(Icons.notifications, color: Color(0xFF008080), size: 40),
            title: Text('Notificaciones',
                style: TextStyle(fontSize: 16, color: Color(0xFF008080))),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notificaciones');
            },
          ),
        ],
      ),
    );
  }
}
