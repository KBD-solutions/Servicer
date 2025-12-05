import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Import screens
import 'screens/role_login_page.dart';
import 'screens/server_dashboard.dart';
import 'screens/item_selection_page.dart';
import 'screens/menu_pdf_viewer.dart';
import 'screens/customer_session.dart';
import 'Utils/selection_tools.dart';

// GLOBAL STATE: Stores the table ID set by the CustomerSessionPage.
String currentTableId = 'Table 99';

// Firebase + App Initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  print("Firebase initialized");

  runApp(const MyApp());
}

// Global function to send item requests to Firestore
void _sendRequest(String type, {String? detail}) async {
  String table = currentTableId;
  String finalType = type;
  String finalDetail = detail ?? 'General';

  try {
    await FirebaseFirestore.instance.collection('requests').add({
      'type': finalType,
      'detail': finalDetail,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
      'table': 'Table 5',
    });
    debugPrint('Request $finalType sent successfully for $table. Detail: $finalDetail');
  } catch (e) {
    debugPrint('Error sending request: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CustomerSessionPage(),
      routes: {
        '/menu': (context) => const SelectScreen(),
      },
    );
  }
}

// --- UPDATED SELECT SCREEN WITH NEW DESIGN ---
class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});

  // Data lists
  static const List<String> drinks = ['Water', 'CocaCola', 'Fanta', 'Sprite'];
  static const List<String> desserts = ['Brownie', 'Cheesecake', 'Ice Cream'];
  static const List<String> extras = ['Fries', 'Onion Rings', 'Breadsticks'];
  
  final String menuUrl = 'https://storage.googleapis.com/servicer-c8b1e.firebasestorage.app/Chick-Po%20Menu.pdf';

  // Function to navigate to the in-app PDF viewer
  void _showMenuPdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuPdfViewerPage(menuUrl: menuUrl),
      ),
    );
  }

  // Helper function to handle navigation and submission
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
      final selectedItems = result.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key} x${e.value}')
          .join(', ');

      if (selectedItems.isNotEmpty) {
        _sendRequest(title, detail: selectedItems);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title request sent: $selectedItems')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No items selected')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF), // Soft clean background
      
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: false, // Don't show back button to login
        title: Text(
          "👋 Hey $currentTableId!", // Using the global table variable
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Choose an option to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- View Menu Button ---
                    buildMainButton(
                      label: "View Menu",
                      icon: Icons.menu_book, 
                      keyValue: "Menu-button",
                      onTap: () => _showMenuPdf(context),
                    ),
                    const SizedBox(height: 20),

                    // --- Refills Button ---
                    buildMainButton(
                      label: "Refills",
                      icon: Icons.local_drink_outlined,
                      keyValue: "Refills-button",
                      onTap: () => _navigateToItemSelection(context, 'Refills', drinks),
                    ),
                    const SizedBox(height: 20),

                    // --- Desserts Button ---
                    buildMainButton(
                      label: "Desserts",
                      icon: Icons.cake_outlined,
                      keyValue: "Desserts-button",
                      onTap: () => _navigateToItemSelection(context, 'Desserts', desserts),
                    ),
                    const SizedBox(height: 20),

                    // --- Extras Button ---
                    buildMainButton(
                      label: "Extras",
                      icon: Icons.fastfood_outlined,
                      keyValue: "Extras-button",
                      onTap: () => _navigateToItemSelection(context, 'Extras', extras),
                    ),
                    const SizedBox(height: 20),

                    // --- Call Server Button ---
                    buildMainButton(
                      label: "Call Server",
                      icon: Icons.notifications_active_outlined,
                      keyValue: "Call-server",
                      onTap: () async {
                        await PopupUtils.showServerOnTheWay(context);
                        _sendRequest("Call Server", detail: "General call");
                      },
                    ),

                    SizedBox(height: 24 + bottomInset),
                  ],
                ),
              ),
            ),
          ),

          // --- Employer Login Button ---
          Positioned(
            bottom: 10 + bottomInset,
            right: 10,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleLoginPage()),
                );
              },
              label: const Text(
                'Employer Login',
                style: TextStyle(fontSize: 12),
              ),
              icon: const Icon(Icons.lock),
              backgroundColor: Colors.deepPurple.shade200,
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Button Builder ---
  Widget buildMainButton({
    required String label,
    required String keyValue,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return SizedBox(
      width: 260,
      height: 58,
      child: ElevatedButton(
        key: Key(keyValue),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple.shade600,
          elevation: 3,
          shadowColor: Colors.deepPurple.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}