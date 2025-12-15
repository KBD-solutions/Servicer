import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerTableLayoutPage extends StatefulWidget {
  const ManagerTableLayoutPage({super.key});

  @override
  State<ManagerTableLayoutPage> createState() => _ManagerTableLayoutPageState();
}

class _ManagerTableLayoutPageState extends State<ManagerTableLayoutPage> {
  
  // --- 1. Prevent Duplicates & Add Table ---
  Future<void> _addTable(BuildContext context) async {
    final TextEditingController numController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Table"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numController,
                decoration: const InputDecoration(labelText: "Table Number (e.g. 5)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: passController,
                decoration: const InputDecoration(labelText: "Password (e.g. 1234)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () async {
                final tableNum = numController.text.trim();
                final pass = passController.text.trim();

                if (tableNum.isNotEmpty && pass.isNotEmpty) {
                  // A. CHECK FOR DUPLICATES FIRST
                  final existing = await FirebaseFirestore.instance
                      .collection('tables')
                      .where('tableNumber', isEqualTo: tableNum)
                      .get();

                  if (existing.docs.isNotEmpty) {
                    // It exists! Show warning and do not add.
                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: Table $tableNum already exists!")),
                      );
                    }
                  } else {
                    // B. ADD NEW TABLE
                    await FirebaseFirestore.instance.collection('tables').add({
                      'tableNumber': tableNum,
                      'password': pass,
                      'isActive': false, 
                      'assignedServer': 'Unassigned', 
                    });
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // --- 2. Auto-Generate Tables 1-15 ---
  Future<void> _setupStandardTables() async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final collection = FirebaseFirestore.instance.collection('tables');

    // Loop from 1 to 15
    for (int i = 1; i <= 15; i++) {
      String numStr = i.toString();
      
      // Check if this number exists
      final snapshot = await collection.where('tableNumber', isEqualTo: numStr).get();

      // If it DOES NOT exist, create it with default password '1234'
      if (snapshot.docs.isEmpty) {
        await collection.add({
          'tableNumber': numStr,
          'password': '1234', // Default password
          'isActive': false,
          'assignedServer': 'Unassigned',
        });
      }
    }

    if (mounted) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tables 1-15 verified/created!")),
      );
    }
  }

  // --- 3. Reset (Clear) Table ---
  void _resetTable(String docId) {
    FirebaseFirestore.instance.collection('tables').doc(docId).update({
      'isActive': false,
    });
  }

  // --- 4. Delete Table ---
  void _deleteTable(String docId, String tableNum) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Table $tableNum?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('tables').doc(docId).delete();
              Navigator.pop(ctx);
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Tables"),
        actions: [
          // BUTTON TO AUTO-CREATE 1-15
          IconButton(
            icon: const Icon(Icons.playlist_add_check),
            tooltip: "Initialize Tables 1-15",
            onPressed: _setupStandardTables,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTable(context),
        child: const Icon(Icons.add),
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        // For strict 1,2,3 sorting, tableNumber needs to be saved as int in Firestore.
        stream: FirebaseFirestore.instance.collection('tables').orderBy('tableNumber').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var tables = snapshot.data!.docs;

          if (tables.isEmpty) {
            return const Center(child: Text("No tables. Tap the checkmark icon in AppBar to create 1-15."));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: tables.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8, 
              ),
              itemBuilder: (context, index) {
                var tableDoc = tables[index];
                var data = tableDoc.data() as Map<String, dynamic>;
                
                String tableNum = data['tableNumber'] ?? '?';
                String password = data['password'] ?? '---';
                bool isOccupied = data['isActive'] ?? false;

                return GestureDetector(
                  onLongPress: () => _deleteTable(tableDoc.id, tableNum),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOccupied ? Colors.red[400] : Colors.green[400],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Table $tableNum",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Pass: $password",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        
                        if (isOccupied)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, 
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onPressed: () => _resetTable(tableDoc.id),
                            child: const Text("Clear"),
                          )
                        else
                          const Text(
                            "Free",
                            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                          ),
                      ],
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