import 'package:flutter/material.dart';
import 'server_dashboard.dart'; 
import 'manager_dashboard.dart';

/*
  This unified login page handles role selection (Server or Manager)
  and routes both roles to the same Employer Dashboard.
  The role is passed as an argument to the dashboard for context.
  
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
  String _role = 'Server'; // default choice
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
    setState(() => _error = null);

    // 1. Basic Validation
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'Please enter an email');
      return;
    }

    // ---LOGIC START ---
    
    final emailInput = _email.text.trim().toLowerCase();
    final pinInput = _pin.text.trim();

    /* ---------------------------------------------------------
       Old login Logic
       ---------------------------------------------------------
    // 2. Role-Specific PIN Check
    final pin = _pin.text.trim();
    if (_role == 'Server' && pin != '1234') {
      setState(() => _error = 'Wrong PIN for Server (use 1234)');
      return;
    }
    if (_role == 'Manager' && pin != '2468') {
      setState(() => _error = 'Wrong PIN for Manager (use 2468)');
      return;
    }

    // 3. Success -> Route both roles to the EmployerDashboardPage
    Navigator.pushReplacement(
      context,
      // MaterialPageRoute(builder: (_) => EmployerDashboardPage(role: _role)),
      MaterialPageRoute(builder: (_) => const ServerDashboardPage()),
    );
    --------------------------------------------------------- */

    // --- Specific Email & PIN Checks ---

    if (_role == 'Server') {
      // 1. Check Server Credentials (server@test.com / 1234)
      if (emailInput == 'server@test.com' && pinInput == '1234') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ServerDashboardPage()),
        );
      } else {
        setState(() => _error = 'Invalid Server credentials.\n(Try: server@test.com / 1234)');
      }
    } 
    else if (_role == 'Manager') {
      // 2. Check Manager Credentials (manager@test.com / 2468)
      if (emailInput == 'manager@test.com' && pinInput == '2468') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ManagerDashboardPage()),
        );
      } else {
        setState(() => _error = 'Invalid Manager credentials.\n(Try: manager@test.com / 2468)');
      }
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

                  // Role Selection Chips
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
                    // Added specific keyboard for emails
                    keyboardType: TextInputType.emailAddress, 
                  ),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: _pin,
                    // Dynamic Label Text based on selected role
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
                    Text(
                      _error!, 
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
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