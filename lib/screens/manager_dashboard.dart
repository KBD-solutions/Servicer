import 'package:flutter/material.dart';
import 'server_dashboard.dart'; 
import 'manager_table_layout.dart'; 

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ServerDashboardPage(
      pageTitle: "Manager Dashboard",
      appBarColor: Colors.blueGrey, // Manager color
      extraActions: [
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
    );
  }
}