import 'package:flutter/material.dart';

class ItemCounter extends StatefulWidget {
  final String itemName;
  final int initialQuantity;
  final ValueChanged<int>? onQuantityChanged;

  const ItemCounter({
    super.key,
    required this.itemName,
    this.initialQuantity = 0,
    this.onQuantityChanged,
  });

  @override
  State<ItemCounter> createState() => _ItemCounterState();
}

class _ItemCounterState extends State<ItemCounter> {
  late int _qty;

  @override
  void initState() {
    super.initState();
    _qty = widget.initialQuantity;
  }

  void _increment() {
    setState(() => _qty++);
    widget.onQuantityChanged?.call(_qty);
  }

  void _decrement() {
    if (_qty == 0) return;
    setState(() => _qty--);
    widget.onQuantityChanged?.call(_qty);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Item label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 1),
            ],
          ),
          child: Text(widget.itemName, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 12),

        IconButton(icon: const Icon(Icons.remove), onPressed: _qty > 0 ? _decrement : null),
        IconButton(icon: const Icon(Icons.add), onPressed: _increment),

        Container(
          width: 60,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$_qty', style: const TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
