import 'package:craft/appwriter_initializer.dart';
import 'package:craft/pages/onboarding_screen.dart';
import 'package:craft/supabase_initializer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize appwrite before running the app
  await AppwriterInitializer.initialize();
  await Firebase.initializeApp();
  await AppwriteInitializer.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Craft App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardinScreen(),
    );
  }
}
