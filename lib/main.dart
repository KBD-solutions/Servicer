import 'package:flutter/material.dart';
import 'screens/employer_dashboard.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SelectScreen(),
    );
  }
}

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selection Page"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),      
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Refills"),
              ),
            ),
            //sized Box for button spacing 
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Desserts"),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Extras"),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Call Server"),
              ),
            ),
          ],
        ),
      ),

    
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmployerDashboardPage()),
            );
          },
          label: const Text(
            'Employer Login',
            style: TextStyle(fontSize: 12),
          ),
          icon: const Icon(Icons.lock),
          backgroundColor: const Color.fromARGB(221, 231, 230, 230),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
