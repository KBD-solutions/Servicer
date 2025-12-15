import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Import screens
import 'screens/customer_session.dart';
import 'screens/Selection_screen.dart';

// GLOBAL STATE: Stores the table ID set by the CustomerSessionPage.
String currentTableId = 'Table 99';

// Test flag: when true, skip Firestore table existence/password checks
// This allows widget tests to navigate without requiring live Firestore data.
// Tests can set this to true by importing `main.dart` and assigning it.
bool bypassFirestoreTableCheck = false;

// Firebase + App Initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  print("Firebase initialized");

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CustomerSessionPage(),
      routes: {
            '/menu': (context) => const SelectScreen(),
          },
    );
  }
}

