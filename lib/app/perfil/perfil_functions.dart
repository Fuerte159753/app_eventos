import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class PerfilService {
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      throw Exception('Error al obtener los datos: ${e.toString()}');
    }
    return null;
  }
}
