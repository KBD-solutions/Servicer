import 'package:flutter/material.dart';
import 'employer_dashboard.dart';
import 'Confirmation_screen.dart';



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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfirmationScreen())
                  );
                },
                child: const Text("Refills"),
                key: const Key("Refills-button"),
              ),
            ),
            //sized Box for button spacing 
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfirmationScreen())
                  );
                },
                child: const Text("Desserts"),
                key: const Key("Desserts-button"),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfirmationScreen())
                  );
                },
                child: const Text("Extras"),
                key: const Key("Extras-button"),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                child: Text("Call Server"),
                key: const Key("Call-server"),
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