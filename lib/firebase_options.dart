import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }  

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALziWiVzMSE0XkJTktOqWEe8ZN0XXknjo',
    appId: '1:353077948996:web:11aaf298c1176f366e4211',
    messagingSenderId: '353077948996',
    projectId: 'app-de-eventos-c1c50',
    authDomain: 'app-de-eventos-c1c50.firebaseapp.com',
    databaseURL: 'https://app-de-eventos-c1c50-default-rtdb.firebaseio.com',
    storageBucket: 'app-de-eventos-c1c50.appspot.com',
    measurementId: 'G-X2CZ7N1DVB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCxxbyxIcoHmJjs1zf6CckqMMEYWOZ3tEE',
    appId: '1:353077948996:android:408551f76c9471e66e4211',
    messagingSenderId: '353077948996',
    projectId: 'app-de-eventos-c1c50',
    databaseURL: 'https://app-de-eventos-c1c50-default-rtdb.firebaseio.com',
    storageBucket: 'app-de-eventos-c1c50.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyALziWiVzMSE0XkJTktOqWEe8ZN0XXknjo',
    appId: '1:353077948996:web:2e12093fa36a706a6e4211',
    messagingSenderId: '353077948996',
    projectId: 'app-de-eventos-c1c50',
    authDomain: 'app-de-eventos-c1c50.firebaseapp.com',
    databaseURL: 'https://app-de-eventos-c1c50-default-rtdb.firebaseio.com',
    storageBucket: 'app-de-eventos-c1c50.appspot.com',
    measurementId: 'G-FBPJ795C83',
  );
}
