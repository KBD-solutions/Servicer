import 'package:flutter/material.dart';

class ItemCounter extends StatefulWidget {
  final String itemName;
  final int initialQuantity;
  final ValueChanged<int> onQuantityChanged;

  const ItemCounter({
    super.key,
    required this.itemName,
    required this.initialQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<ItemCounter> createState() => _ItemCounterState();
}

class _ItemCounterState extends State<ItemCounter> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _updateQuantity(int newQty) {
    if (newQty >= 0) {
      setState(() {
        _quantity = newQty;
      });
      widget.onQuantityChanged(newQty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.itemName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: _quantity > 0 ? () => _updateQuantity(_quantity - 1) : null,
          ),
          Text(
            '$_quantity',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _updateQuantity(_quantity + 1),
          ),
        ],
      ),
    );
  }
}