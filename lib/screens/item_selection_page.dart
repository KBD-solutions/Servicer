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
    // Returns the map of selected items to the previous screen (SelectScreen)
    Navigator.pop(context, _order);
  }

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
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: widget.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final name = widget.items[index];
            final initial = _order[name] ?? 0;
            return ItemCounter(
              itemName: name,
              initialQuantity: initial,
              onQuantityChanged: (qty) => _order[name] = qty,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirm,
        icon: const Icon(Icons.check),
        label: const Text('confirm'),
        key: const Key("confirm-button"),
      ),
    );
  }
}
