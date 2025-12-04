import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerTableLayoutPage extends StatefulWidget {
  const ManagerTableLayoutPage({super.key});

  @override
  State<ManagerTableLayoutPage> createState() => _ManagerTableLayoutPageState();
}

class _ManagerTableLayoutPageState extends State<ManagerTableLayoutPage> {
  // 15 tables numbered 1–15
  final int tableCount = 15;

  // Convert "Table 5" → 5
  int _parseTableNumber(String tableString) {
    try {
      return int.parse(tableString.replaceAll("Table ", "").trim());
    } catch (_) {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Table Layout"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .snapshots(),  // real-time
        builder: (context, snapshot) {
          // If loading or errors
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Start all tables as "no request"
          Map<int, bool> tableHasRequest = {
            for (int i = 1; i <= tableCount; i++) i: false
          };

          // Read all active requests
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data['table'] == null) continue;
            if (data['status'] == "Done") continue; // done = no need to mark red

            int tableNum = _parseTableNumber(data['table']);
            if (tableNum >= 1 && tableNum <= tableCount) {
              tableHasRequest[tableNum] = true; // mark table red
            }
          }

          // Build the grid
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: tableCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final tableNum = index + 1;
                final isRed = tableHasRequest[tableNum] ?? false;

                return Container(
                  decoration: BoxDecoration(
                    color: isRed ? Colors.red[400] : Colors.green[400],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Table $tableNum",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
