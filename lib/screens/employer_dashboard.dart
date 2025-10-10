import 'package:flutter/material.dart';

class EmployerDashboardPage extends StatefulWidget {
  const EmployerDashboardPage({super.key});

  @override
  State<EmployerDashboardPage> createState() => _EmployerDashboardPageState();
}

class _EmployerDashboardPageState extends State<EmployerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab; // this is like a controller that helps switch between tabs
  String _filter = 'All';  // here we keep track of which filter is selected

  @override
  void initState() {
    super.initState();
    // I didn’t know this part at first, so I had to search it.
    // This makes the two tabs at the top (Live and History) work.
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose(); // this closes the controller when we leave the page
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme; // this gives us app colors

    return Scaffold(
      // the top bar with name of page and icons
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.notifications_none),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Live'),
            Tab(text: 'History'),
          ],
        ),
      ),

      // here is where the page actually shows
      body: TabBarView(
        controller: _tab,
        children: [
          //  TAB 1: LIVEE
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // top 3 boxes (Pending, In Progress, Done)
                // they don’t do anything yet, just look nice
                Row(
                  children: [
                    _metricCard(
                      color: scheme.primaryContainer,
                      label: 'Pending',
                      value: '0', // for now just 0
                      icon: Icons.hourglass_bottom,
                    ),
                    _metricCard(
                      color: scheme.tertiaryContainer,
                      label: 'In-Progress',
                      value: '0',
                      icon: Icons.run_circle_outlined,
                    ),
                    _metricCard(
                      color: scheme.secondaryContainer,
                      label: 'Done',
                      value: '0',
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // here are filter chips (like small buttons)
                // they don't filter anything yet, just let me click one at a time
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in const ['All', 'Refills', 'Desserts', 'Extras', 'Call Server'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // here I just added a simple box to show that the design works
                // I will add the real list of requests later
                Expanded(
                  child: Center(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: const SizedBox(
                        width: 420,
                        height: 180,
                        child: Center(
                          child: Text(
                            'No requests yet.\nI will add items later.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          //  TAB 2: HISTORY 
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'History will be added later.\nFor now just the design.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // helper box of cards
  Widget _metricCard({
    required Color color,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12)),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
