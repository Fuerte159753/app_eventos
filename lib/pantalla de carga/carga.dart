import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PantallaDeCarga extends StatefulWidget {
  const PantallaDeCarga({Key? key}) : super(key: key);

  @override
  _PantallaDeCargaState createState() => _PantallaDeCargaState();
}

class _PantallaDeCargaState extends State<PantallaDeCarga> {
  @override
  void initState() {
    super.initState();
    // Retraso de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 150,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            LoadingAnimationWidget.inkDrop(
              color: Colors.blue,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}