import 'package:flutter/material.dart';
import 'server_dashboard.dart'; // Assuming this exists from teammate
import 'manager_table_layout.dart'; // We will create this next

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Dashboard"),
        backgroundColor: Colors.blueGrey,
        actions: [
          // The button to manage table layout
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: "Edit Table Layout",
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
      // This displays the general employer stats/orders
      body: const ServerDashboardPage(),
    );
  }
}