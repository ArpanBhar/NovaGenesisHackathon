import 'package:celestia/firebase_options.dart';
import 'package:celestia/landing_page.dart';
import 'package:celestia/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CelestiaApp());
}

class CelestiaApp extends StatelessWidget {
  const CelestiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celestia',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LandingPage(),
    );
  }
}