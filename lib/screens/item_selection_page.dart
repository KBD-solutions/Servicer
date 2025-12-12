import 'package:flutter/material.dart';
import '../Utils/item_counter.dart';

class ItemsSelectionPage extends StatefulWidget {
  final String title;
  final List<String> items;
  final Map<String, int>? initialQuantities;

  const ItemsSelectionPage({
    super.key,
    required this.title,
    required this.items,
    this.initialQuantities,
  });

  @override
  State<ItemsSelectionPage> createState() => _ItemsSelectionPageState();
}

class _ItemsSelectionPageState extends State<ItemsSelectionPage> {
  late Map<String, int> _order;

  @override
  void initState() {
    super.initState();
    _order = {for (final name in widget.items) name: 0};
    if (widget.initialQuantities != null) {
      for (final entry in widget.initialQuantities!.entries) {
        if (_order.containsKey(entry.key)) _order[entry.key] = entry.value;
      }
    }
  }

  void _confirm() {
    Navigator.pop(context, _order);
  }

  // Helper to check if user picked anything
  bool get _hasItems => _order.values.any((qty) => qty > 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
          itemCount: widget.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final name = widget.items[index];
            final initial = _order[name] ?? 0;
            return ItemCounter(
              itemName: name,
              initialQuantity: initial,
              onQuantityChanged: (qty) {
                setState(() {
                  _order[name] = qty;
                });
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              key: const Key("confirm-button"),
              onPressed: _confirm,
              icon: const Icon(Icons.check),
              label: const Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}