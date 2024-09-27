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
      appBar: AppBar(
        title: const Text('perfil Page'),
      ),
      body: const Center(
        child: Text('Revisa tu informacion'),
      ),
    );
  }
}