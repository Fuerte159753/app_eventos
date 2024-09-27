import 'package:app_eventos/app/widgets/menu_lateral.dart';
import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget{
  const PerfilPage({super.key});
  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: AppBar(
        title: const Text('perfil Page'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              }, 
            );
          },
        ),
      ),
      body: const Center(
        child: Text('Revisa tu informacion'),
      ),
    );
  }
}