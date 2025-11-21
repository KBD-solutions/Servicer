import 'package:flutter/material.dart';
import 'employer_dashboard.dart';
import 'manager_table_layout.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: "Table Layout",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManagerTableLayoutPage()),
              );
            },
          ),
        ],
      ),

      body: const EmployerDashboardPage(),
    );
  }
}
