import 'package:flutter/material.dart';

class NewPage extends StatefulWidget{
  const NewPage({super.key});
  @override
  _NewPageState createState() => _NewPageState();
}
class _NewPageState extends State<NewPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('add event calendar'),
      ),
      body: const Center(
        child: Text('agrega un nuevo evento'),
      ),
    );
  }
}