import 'package:flutter/material.dart';

class PopupUtils {
  /// Shows a temporary dialog letting the customer know a server is on the way.
  /// This dialog automatically closes after 2 seconds.
  static Future<void> showServerOnTheWay(BuildContext context) async {
    showDialog(
      context: context,
      // Prevents dialog from being dismissed by tapping outside
      barrierDismissible: false, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            SizedBox(height: 12),
            Text(
              'Server notified',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'A server is on the way. Thanks for your patience!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // Wait for 2 seconds, close dialog, show snackbar
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if the widget is still mounted before trying to pop
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Show the small confirmation message at the bottom
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Server is on the way!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}