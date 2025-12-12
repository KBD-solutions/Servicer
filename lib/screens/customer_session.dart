import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'role_login_page.dart';

class CustomerSessionPage extends StatefulWidget {
  const CustomerSessionPage({super.key});

  @override
  State<CustomerSessionPage> createState() => _CustomerSessionPageState();
}

class _CustomerSessionPageState extends State<CustomerSessionPage> {
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _startSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String tableInput = _tableController.text.trim();
    String passInput = _passwordController.text.trim();

    if (tableInput.isEmpty || passInput.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Please enter both Table Number and a Password.";
      });
      return;
    }

    // If tests set this flag, skip Firestore checks and navigate immediately.
    if (bypassFirestoreTableCheck) {
      currentTableId = "Table $tableInput";
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/menu');
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // 1. Query Firestore for the table
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('tables')
          .where('tableNumber', isEqualTo: tableInput)
          .get();

      if (query.docs.isEmpty) {
        throw "Table $tableInput does not exist.";
      }

      var tableDoc = query.docs.first;
      var data = tableDoc.data() as Map<String, dynamic>;
      bool isActive = data['isActive'] ?? false;

      // 2. LOGIC BRANCHING
      if (!isActive) {
        // --- CASE A: NEW SESSION (First person joining) ---
        // The table is free. We set the password to whatever this user typed
        // so their friends can join using the same password.
        await FirebaseFirestore.instance
            .collection('tables')
            .doc(tableDoc.id)
            .update({
          'isActive': true,
          'password': passInput, // Overwrite DB password with User's password
        });
      } else {
        // --- CASE B: JOINING EXISTING SESSION (Friends joining) ---
        // The table is already active. We check if the input matches existing password.
        String currentSessionPassword = data['password'] ?? '';
        
        if (passInput != currentSessionPassword) {
          throw "Incorrect password. Ask the first person who joined Table $tableInput for the code.";
        }
        // If password matches, do nothing to DB, just let them in.
      }

      // 3. SUCCESS: Update Global ID and Navigate
      currentTableId = "Table $tableInput";

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/menu');
      }

    } catch (e) {
      setState(() {
        // Clean up error message to look nice
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added SingleChildScrollView so keyboard doesn't hide buttons
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text("Welcome to Chick-Po", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "First person sets the password.\nFriends use that password to join.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              TextField(
                controller: _tableController,
                decoration: const InputDecoration(
                  labelText: "Enter Table Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.table_bar),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Create or Enter Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startSession,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Start / Join Session", style: TextStyle(fontSize: 18)),
                ),
              ),
              
              // --- THE EMPLOYER ACCESS LINK ---
              const SizedBox(height: 20), 
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoleLoginPage()),
                  );
                }, 
                child: const Text("Employer Access", style: TextStyle(color: Colors.grey))
              )
            ],
          ),
        ),
      ),
    );
  }
}