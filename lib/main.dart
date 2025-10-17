import 'package:flutter/material.dart';
import 'screens/employer_dashboard.dart';
import 'screens/Selection_screen.dart';

//for testing 


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SelectScreen(), // <-- use SelectScreen
    );
  }
}