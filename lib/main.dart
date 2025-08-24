import 'package:celestia/dashboard.dart';
import 'package:celestia/firebase_options.dart';
import 'package:celestia/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://vovnhuqeaehjqawbiakr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZvdm5odXFlYWVoanFhd2JpYWtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMzQxNzUsImV4cCI6MjA3MTYxMDE3NX0.R9CP26TCCwWLWCQGMHO_iXrQeuypisMBFM8swi4dgeE',
  );
  runApp(const CelestiaApp());
}

class CelestiaApp extends StatelessWidget {
  const CelestiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Celestia',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, asyncSnapshot) {
          if(asyncSnapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }else if(asyncSnapshot.data != null){
            return DashboardPage();
          }
          return const LandingPage();
        }
      ),
    );
  }
}