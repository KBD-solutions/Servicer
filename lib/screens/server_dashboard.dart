import 'package:flutter/material.dart';

/*
  Server Dashboard (very simple)
  - Server can only "Start" and "Done"
  - I put two fake items just so we can click things
  - Later, Manager will have extra controls
*/

class ServerDashboardPage extends StatefulWidget {
  const ServerDashboardPage({super.key});

  @override
  State<ServerDashboardPage> createState() => _ServerDashboardPageState();
}

class _ServerDashboardPageState extends State<ServerDashboardPage> {
  // tiny data just to show the list
  final List<Map<String, String>> _items = [
    {'table': '5', 'type': 'Refills', 'detail': 'Coke', 'time': '2m'},
    {'table': '3', 'type': 'Desserts', 'detail': 'Brownie', 'time': '5m'},
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _items.isEmpty
            ? const Center(child: Text('No requests yet'))
            : ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final r = _items[i];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(child: Text('T${r['table']}')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${r['type']} • ${r['detail']}',
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('${r['time']} ago',
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _toast('Table ${r['table']}: started'),
                            child: const Text('Start'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: () {
                              _toast('Table ${r['table']}: done');
                              setState(() => _items.removeAt(i));
                            },
                            child: const Text('Done'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
