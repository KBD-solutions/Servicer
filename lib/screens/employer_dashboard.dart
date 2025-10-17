import 'package:flutter/material.dart';

/*
  I made this page to be the "Employer / Server" dashboard.
  It has two tabs: Live (things happening now) and History (things already done).
  I tried to keep the code simple and added notes so I can remember later.
*/

// I used an enum to mark the status of a request.
// I didn't know this at first so I looked it up: enums are just a small list of options.
enum RequestStatus { pending, inProgress, done }

// This is just a small "data box" to store each request on the screen.
class Request {
  final int table;        // like table number (ex: 5)
  final String type;      // "Refills", "Desserts", "Extras", "Call Server"
  final String detail;    // more info (ex: "Coke")
  final String time;      // when it came in (ex: "2m ago")
  final RequestStatus status;

  const Request({
    required this.table,
    required this.type,
    required this.detail,
    required this.time,
    required this.status,
  });

  // copyWith is just a quick way to make a new Request with one field changed.
  // I had to search this pattern because I forgot how to do it.
  Request copyWith({
    int? table,
    String? type,
    String? detail,
    String? time,
    RequestStatus? status,
  }) {
    return Request(
      table: table ?? this.table,
      type: type ?? this.type,
      detail: detail ?? this.detail,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}

class EmployerDashboardPage extends StatefulWidget {
  const EmployerDashboardPage({super.key});

  @override
  State<EmployerDashboardPage> createState() => _EmployerDashboardPageState();
}

class _EmployerDashboardPageState extends State<EmployerDashboardPage>
    with SingleTickerProviderStateMixin {

  // This controller makes the two tabs at the top work (Live / History).
  // I didn't know I needed "with SingleTickerProviderStateMixin" until I googled tabs in Flutter.
  late TabController _tab;

  // filter chip text I selected. Starts at "All".
  String _filter = 'All';

  // Just some fake data so the page doesn't look empty.
  // Later I will replace this with real data.
  List<Request> _requests = const [
    Request(table: 5, type: 'Refills',  detail: 'Coke',        time: '2m ago',  status: RequestStatus.pending),
    Request(table: 3, type: 'Desserts', detail: 'Brownie',     time: '5m ago',  status: RequestStatus.inProgress),
    Request(table: 7, type: 'Extras',   detail: 'Ranch',       time: '1m ago',  status: RequestStatus.pending),
    Request(table: 2, type: 'Call Server', detail: 'Check bill', time: '8m ago',  status: RequestStatus.done),
    Request(table: 1, type: 'Refills',  detail: 'Iced Tea',    time: '30s ago', status: RequestStatus.pending),
  ];

  bool _soundOn = true; // extra small feature: pretend we can mute/unmute alerts

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this); // two tabs only
  }

  @override
  void dispose() {
    _tab.dispose(); // close the controller when leaving page
    super.dispose();
  }

  // Small helper functions (I prefer plain functions instead of fancy getters here).
  List<Request> liveItems() {
    final onlyLive = _requests.where((r) => r.status != RequestStatus.done);
    if (_filter == 'All') return onlyLive.toList();
    return onlyLive.where((r) => r.type == _filter).toList();
  }

  List<Request> historyItems() {
    return _requests.where((r) => r.status == RequestStatus.done).toList();
  }

  int pendingCount() =>
      _requests.where((r) => r.status == RequestStatus.pending).length;

  int inProgressCount() =>
      _requests.where((r) => r.status == RequestStatus.inProgress).length;

  int doneCount() =>
      _requests.where((r) => r.status == RequestStatus.done).length;

  // When I click Start or Done, I change the status here.
  void changeStatus(Request req, RequestStatus status) {
    final i = _requests.indexOf(req);
    if (i < 0) return; // not found, just return
    setState(() {
      final copy = List<Request>.from(_requests);
      copy[i] = copy[i].copyWith(status: status);
      _requests = copy;
    });
    // This message at the bottom is just to show it worked
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Table ${req.table}: ${status.name}')),
    );
  }

  // tiny extra: remove all "done" items from the history
  void clearDone() {
    setState(() {
      _requests = _requests.where((r) => r.status != RequestStatus.done).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cleared completed items')),
    );
  }

  // tiny extra: not a real refresh, just a snackbar so it feels interactive
  void fakeRefresh() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Refreshed • sound ${_soundOn ? "ON" : "OFF"}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: [
          // a simple sound toggle (not real audio, just a boolean for now)
          Row(
            children: [
              const Text('Sound', style: TextStyle(fontSize: 12)),
              Switch(
                value: _soundOn,
                onChanged: (v) => setState(() => _soundOn = v),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: fakeRefresh,
          ),
          const Padding(
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

      body: TabBarView(
        controller: _tab,
        children: [
          // ================= LIVE TAB =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- three small KPI cards at the top ---
                Row(
                  children: [
                    metricCard(
                      color: scheme.primaryContainer,
                      label: 'Pending',
                      value: pendingCount().toString(),
                      icon: Icons.hourglass_bottom,
                    ),
                    metricCard(
                      color: scheme.tertiaryContainer,
                      label: 'In-Progress',
                      value: inProgressCount().toString(),
                      icon: Icons.run_circle_outlined,
                    ),
                    metricCard(
                      color: scheme.secondaryContainer,
                      label: 'Done',
                      value: doneCount().toString(),
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- filters (they just change which ones show) ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final f in const ['All','Refills','Desserts','Extras','Call Server'])
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

                // --- the live list ---
                Expanded(
                  child: liveItems().isEmpty
                      ? const Center(child: Text('No live requests'))
                      : ListView.separated(
                          itemCount: liveItems().length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final r = liveItems()[i];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    tableAvatar(r.table, scheme),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${r.type} • ${r.detail}',
                                              style: Theme.of(context).textTheme.titleMedium),
                                          const SizedBox(height: 4),
                                          Text(r.time,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(color: scheme.outline)),
                                          const SizedBox(height: 8),
                                          statusChip(r.status, scheme),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => changeStatus(r, RequestStatus.inProgress),
                                          child: const Text('Start'),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton(
                                          onPressed: () => changeStatus(r, RequestStatus.done),
                                          child: const Text('Done'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // ================= HISTORY TAB =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: historyItems().isEmpty ? null : clearDone,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear Done'),
                  ),
                ),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: historyItems().isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text('No completed requests yet'),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Table')),
                                DataColumn(label: Text('Type')),
                                DataColumn(label: Text('Detail')),
                                DataColumn(label: Text('When')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: historyItems()
                                  .map(
                                    (r) => DataRow(
                                      cells: [
                                        DataCell(Text('#${r.table}')),
                                        DataCell(Text(r.type)),
                                        DataCell(Text(r.detail)),
                                        DataCell(Text(r.time)),
                                        DataCell(Text(r.status.name)),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------- small UI helper widgets below -----------
  // I wrote these to not repeat the same code many times.

  Widget metricCard({
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
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableAvatar(int table, ColorScheme scheme) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: scheme.primaryContainer,
      child: Text('T$table', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
    // I picked CircleAvatar because it's quick and looks clean.
  }

  Widget statusChip(RequestStatus status, ColorScheme scheme) {
    // choose colors and text based on status
    Color bg;
    Color fg;
    String text;
    if (status == RequestStatus.pending) {
      bg = scheme.errorContainer;
      fg = scheme.onErrorContainer;
      text = 'Pending';
    } else if (status == RequestStatus.inProgress) {
      bg = scheme.tertiaryContainer;
      fg = scheme.onTertiaryContainer;
      text = 'In-Progress';
    } else {
      bg = scheme.secondaryContainer;
      fg = scheme.onSecondaryContainer;
      text = 'Done';
    }
    return Chip(
      label: Text(text),
      backgroundColor: bg,
      labelStyle: TextStyle(color: fg),
      shape: StadiumBorder(side: BorderSide(color: fg.withOpacity(.2))),
    );
  }
}
