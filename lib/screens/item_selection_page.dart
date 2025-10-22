import 'package:flutter/material.dart';
import '../Utils/item_counter.dart';

class ItemsSelectionPage extends StatefulWidget {
  final String title;
  final List<String> items;
  final Map<String, int>? initialQuantities; // optional (for editing an order)

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
    // start with zeros for all items, then apply any provided initial quantities
    _order = {for (final name in widget.items) name: 0};
    if (widget.initialQuantities != null) {
      for (final entry in widget.initialQuantities!.entries) {
        if (_order.containsKey(entry.key)) _order[entry.key] = entry.value;
      }
    }
  }

  void _confirm() {
    // return the map to the previous screen (or show a summary)
    Navigator.pop(context, _order);
    // If you want a toast/snackbar here instead of pop:
    // final summary = _order.entries.where((e)=>e.value>0).map((e) => '${e.key}: ${e.value}').join(' • ');
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(summary.isEmpty ? 'No items selected' : 'Order: $summary')));
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
              key: ValueKey('counter_$name'),
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
        label: const Text('Confirm'),
      ),
    );
  }
}
