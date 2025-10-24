import 'package:flutter/material.dart';
import 'manager_dashboard.dart';       // new name for manager view (we'll alias to your existing file)
import 'server_dashboard.dart';        // simple server view (add/mark done only)

/*
  This page lets the employee pick a role (Server or Manager)
  and log in with email + a simple PIN.
  I kept it super basic on purpose for class demo.
  PINs (for now):
    - Server: 1234
    - Manager: 2468
*/

class RoleLoginPage extends StatefulWidget {
  const RoleLoginPage({super.key});

  @override
  State<RoleLoginPage> createState() => _RoleLoginPageState();
}

class _RoleLoginPageState extends State<RoleLoginPage> {
  String _role = 'Server';               // default choice
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
    // very simple checks just for now
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Please enter an email');
      return;
    }

    // I split pins so roles feel different
    final pin = _pin.text.trim();
    if (_role == 'Server' && pin != '1234') {
      setState(() => _error = 'Wrong PIN for Server (use 1234)');
      return;
    }
    if (_role == 'Manager' && pin != '2468') {
      setState(() => _error = 'Wrong PIN for Manager (use 2468)');
      return;
    }

    // send to the correct dashboard
    if (_role == 'Server') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ServerDashboardPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ManagerDashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pick your role and sign in', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),

                  // role buttons – I used two simple ChoiceChips to keep it easy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Server'),
                        selected: _role == 'Server',
                        onSelected: (_) => setState(() => _role = 'Server'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Manager'),
                        selected: _role == 'Manager',
                        onSelected: (_) => setState(() => _role = 'Manager'),
                      ),
                    ],
                  ),

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
                    decoration: InputDecoration(
                      labelText: _role == 'Server'
                          ? 'PIN for Server (1234)'
                          : 'PIN for Manager (2468)',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
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
                    height: 44,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _tryLogin,
                      child: const Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
