import 'package:flutter/material.dart';
import 'employer_dashboard.dart'; // Assuming this is in the same directory (screens/)

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final _email = TextEditingController();
  final _pin = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _tryLogin() {
    setState(() => _error = null); // Clear previous error

    // 1. Simple Email Check
    if (_email.text.trim().isEmpty) {
      setState(() => _error = "Please enter an email.");
      return;
    }

    // 2. Hardcoded PIN Check
    if (_pin.text.trim() != '1234') {
      setState(() => _error = "Wrong PIN. Use 1234 for now.");
      return;
    }

    // 3. Success -> Go to dashboard and replace the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const EmployerDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Sign in to continue', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pin,
                  decoration: const InputDecoration(
                    labelText: '4-digit PIN (use 1234)',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: _tryLogin,
                    child: const Text('Login'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}