import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PantallaDeCarga extends StatefulWidget {
  const PantallaDeCarga({super.key});

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
      backgroundColor: const Color(0xFF008080),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Planify',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            LoadingAnimationWidget.inkDrop(
              color: Colors.white,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
