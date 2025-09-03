import 'package:elgasos/Screens/namepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  // Intialize Firebase For Web
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb == true) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCJdSw-YjtTTBDeYtIWz1-uXCjCpCghM0U",
        authDomain: "elgasos-f8abe.firebaseapp.com",
        projectId: "elgasos-f8abe",
        storageBucket: "elgasos-f8abe.firebasestorage.app",
        messagingSenderId: "391994482977",
        appId: "1:391994482977:web:03c13ab4eef729854a5e60",
      ),
    );
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Namepage());
  }
}
