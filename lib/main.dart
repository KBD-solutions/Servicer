import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; 
import 'screens/employee_login.dart'; 
import 'screens/employer_dashboard.dart'; 
import 'screens/item_selection_page.dart';
import 'screens/menu_pdf_viewer.dart';
// Import the utility file for the Call Server dialog
import 'Utils/selection_tools.dart'; 

void main() async {
  // Always call this first when using plugins like Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Firebase initialized");

  // Configure Firestore settings here (enables offline persistence)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(const MyApp());
}

// Global function to send item requests to Firestore
void _sendRequest(String type, {String? detail}) async {
  // Table is hardcoded for now, but should be dynamic later
  String table = 'Table 5'; 
  String finalType = type;
  String finalDetail = detail ?? 'General';
  
  try {
    await FirebaseFirestore.instance.collection('requests').add({
      'type': finalType,
      'detail': finalDetail, // Stores the specific items selected (e.g., "Coke x2, Water x1")
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
      'table': table,
    });
    print('Request $finalType sent successfully. Detail: $finalDetail');
  } catch (e) {
    print('Error sending request: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use SelectScreen as the initial home screen for the customer view.
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectScreen(),
    );
  }
}

// Customer interface screen for selecting services
class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});
  
  // This URL is publicly accessible after the CORS and IAM fixes.
  // It is used by the MenuPdfViewerPage to fetch the file data.
  final String menuUrl = 'https://storage.googleapis.com/servicer-c8b1e.firebasestorage.app/Chick-Po%20Menu.pdf';
  
  // Function to navigate to the in-app PDF viewer screen
  void _showMenuPdf(BuildContext context) {
    // Navigate using Navigator.push to display the menu without opening a new browser tab.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuPdfViewerPage(menuUrl: menuUrl),
      ),
    );
  }

  // Helper function to handle navigation and submission for selectable items (Refills, Desserts, Extras)
  Future<void> _navigateToItemSelection(BuildContext context, String title, List<String> items) async {
    final Map<String, int>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsSelectionPage(
          title: title,
          items: items,
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Format the selected items into a single detail string
      final selectedItems = result.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key} x${e.value}')
          .join(', ');
      
      if (selectedItems.isNotEmpty) {
         _sendRequest(title, detail: selectedItems);
         // Show a confirmation snackbar
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('$title request sent: $selectedItems')),
         );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('No items selected')),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Menu Button: opens the in-app PDF viewer
            _buildSelectButton(
              context,
              'View Menu',
              () => _showMenuPdf(context), 
            ),
            
            // Refills button: opens selection screen
            _buildSelectButton(
              context,
              'Refills',
              () => _navigateToItemSelection(context, 'Refills', const ['Coke', 'Sprite', 'Iced Tea', 'Water']),
            ),
            _buildSelectButton(
              context,
              'Desserts',
              () => _navigateToItemSelection(context, 'Desserts', const ['Brownie', 'Ice Cream', 'Cheesecake']),
            ),
            _buildSelectButton(
              context,
              'Extras',
              () => _navigateToItemSelection(context, 'Extras', const ['Ketchup', 'Mustard', 'Ranch', 'Napkins']),
            ),
            
            // UPDATED: Call Server button uses the popup utility
            _buildSelectButton(
              context,
              'Call Server',
              () async {
                // 1. Show the friendly popup notification
                await PopupUtils.showServerOnTheWay(context);

                // 2. Send the request to Firebase
                _sendRequest("Call Server", detail: "General call");
              },
            ),
          ],
        ),
      ),
      
      // Floating button for Employee Login
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to the hardcoded EmployeeLoginPage
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmployeeLoginPage()),
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

  // Helper widget for a consistent button style
  Widget _buildSelectButton(BuildContext context, String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 250,
        height: 60,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(text),
        ),
      ),
    );
  }
}