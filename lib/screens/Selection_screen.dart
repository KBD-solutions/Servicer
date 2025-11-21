import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'item_selection_page.dart';
import '../Utils/selection_tools.dart';
import 'role_login_page.dart'; // go to role login (server / manager)

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key});

  static const List<String> drinks = ['Water', 'CocaCola', 'Fanta', 'Sprite'];
  static const List<String> desserts = ['Brownie', 'Cheesecake', 'Ice Cream'];
  static const List<String> extras = ['Fries', 'Onion Rings', 'Breadsticks'];

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  // --- helper to send request to Firestore (same idea as in main.dart) ---
  Future<void> _sendRequest(String type, {String? detail}) async {
    // for now we just hard-code a table; later this can come from QR code etc.
    const table = 'Table 5';
    final finalType = type;
    final finalDetail = detail ?? 'General';

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'type': finalType,
        'detail': finalDetail,
        'status': 'Pending', // must match EmployerDashboard enum strings
        'timestamp': FieldValue.serverTimestamp(),
        'table': table,
      });
      
      print('Request $finalType sent: $finalDetail');
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  //  helper: open item selection screen, then send request when user comes back ---
  Future<void> _navigateToItemSelection(
      String title, List<String> items) async {
    // go to the selection page and wait for user to pick stuff
    final Map<String, int>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsSelectionPage(
          title: title,
          items: items,
        ),
      ),
    );

    // if user pressed back with data
    if (result != null && result.isNotEmpty) {
      // build a string like "Coke x2, Sprite x1"
      final selectedItems = result.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key} x${e.value}')
          .join(', ');

      if (selectedItems.isNotEmpty) {
        await _sendRequest(title, detail: selectedItems);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title request sent: $selectedItems')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No items selected')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF), // soft clean background

      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade400,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "👋 Hey Waiter!",
          style: TextStyle(
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

                    // ------------ Refills ------------
                    buildMainButton(
                      label: "Refills",
                      icon: Icons.local_drink_outlined,
                      keyValue: "Refills-button",
                      onTap: () {
                        _navigateToItemSelection(
                          'Refills',
                          SelectScreen.drinks,
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ------------ Desserts ------------
                    buildMainButton(
                      label: "Desserts",
                      icon: Icons.cake_outlined,
                      keyValue: "Desserts-button",
                      onTap: () {
                        _navigateToItemSelection(
                          'Desserts',
                          SelectScreen.desserts,
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ------------ Extras ------------
                    buildMainButton(
                      label: "Extras",
                      icon: Icons.fastfood_outlined,
                      keyValue: "Extras-button",
                      onTap: () {
                        _navigateToItemSelection(
                          'Extras',
                          SelectScreen.extras,
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // ------------ Call Server ------------
                    buildMainButton(
                      label: "Call Server",
                      icon: Icons.notifications_active_outlined,
                      keyValue: "Call-server",
                      onTap: () async {
                        // show the little popup first
                        await PopupUtils.showServerOnTheWay(context);
                        // then send a simple request to Firestore
                        await _sendRequest("Call Server",
                            detail: "General call");
                      },
                    ),

                    SizedBox(height: 24 + bottomInset),
                  ],
                ),
              ),
            ),
          ),

          // ------------- Employer / Staff login -------------
          Positioned(
            bottom: 10 + bottomInset,
            right: 10,
            child: FloatingActionButton.extended(
              onPressed: () {
                // now goes to the role login page (Server / Manager)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RoleLoginPage(),
                  ),
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

  // --------- Reusable Button Builder ---------
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
