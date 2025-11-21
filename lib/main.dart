import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/Selection_screen.dart';   // <-- your home screen
import 'Utils/selection_tools.dart';

// GLOBAL STATE (unchanged)
String currentSessionToken = 'default_unverified';

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

// GLOBAL Firestore Request Function (unchanged)
void sendRequestToFirestore(String type, {String? detail}) async {
  try {
    await FirebaseFirestore.instance.collection('requests').add({
      'type': type,
      'detail': detail ?? 'General',
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
      'table': 'Table 5',
    });

    print("Request '$type' sent successfully.");
  } catch (e) {
    print("Error sending request: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SelectScreen(),   // <-- This loads your clean external file
    );
  }
}
