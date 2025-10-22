import 'package:flutter/material.dart';


class PopupUtils {
  /// Shows a temporary dialog letting the customer know a server is on the way
  static Future<void> showServerOnTheWay(BuildContext context) async {
    showDialog(
      context: context,
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
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Server is on the way!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _Drink{
  final String name;
  int amount;
  _Drink(this.name, {this.amount = 0});
}

final List<_Drink> drinks = [
  _Drink('Sprite'),
  _Drink('Fanta'),
  _Drink('CocaCola')
];