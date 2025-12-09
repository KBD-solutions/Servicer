import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
  This page serves as the Server dashboard (formerly EmployerDashboard).
  It displays real-time requests from the database, split into two tabs: Live and History.
*/

// I used an enum to mark the status of a request, matching your Firestore strings.
// Enums are useful for mapping internal states to database string values.
enum RequestStatus {
  pending('Pending'),
  inProgress('In-Progress'),
  done('Done');

  final String firestoreValue;
  const RequestStatus(this.firestoreValue);
}

// Function to update the status of a request in Firebase (called by 'Start' and 'Done' buttons)
void updateRequestStatus(String docId, RequestStatus status) {
  FirebaseFirestore.instance
      .collection('requests')
      .doc(docId)
      .update({'status': status.firestoreValue});
}

// Function to delete a 'Done' request from history
void deleteRequest(String docId) {
  FirebaseFirestore.instance
      .collection('requests')
      .doc(docId)
      .delete();
}

// RENAMED from EmployerDashboardPage to ServerDashboardPage to differentiate from Manager
class ServerDashboardPage extends StatefulWidget {
  const ServerDashboardPage({super.key});

  @override
  State<ServerDashboardPage> createState() => _ServerDashboardPageState();
}

class _ServerDashboardPageState extends State<ServerDashboardPage>
    with SingleTickerProviderStateMixin {
  // This TabController makes the two tabs (Live / History) work.
  // We needed "with SingleTickerProviderStateMixin" for this functionality.
  late TabController _tab;
  // Here we keep track of which filter chip is selected.
  String _filter = 'All'; 

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this); // two tabs only
  }

  @override
  void dispose() {
    _tab.dispose(); // Close the controller when leaving the page
    super.dispose();
  }

  // Live Requests Query: Fetches all Pending/In-Progress requests, ordered by status and time.
  Stream<QuerySnapshot> liveRequestsStream() {
    Query query = FirebaseFirestore.instance
        .collection('requests')
        .where('status', whereIn: [
          RequestStatus.pending.firestoreValue,
          RequestStatus.inProgress.firestoreValue
        ])
        .orderBy('status')
        .orderBy('timestamp', descending: true); // Primary sorting for new requests first

    // We filter by 'type' LOCALLY in the StreamBuilder to avoid complex Firebase indexing rules.
    return query.snapshots();
  }

  // History Requests Query: Fetches only 'Done' requests.
  Stream<QuerySnapshot> historyRequestsStream() {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: RequestStatus.done.firestoreValue)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Function to calculate counts for the top cards (Uses all requests stream for metric accuracy)
  Widget _buildMetricCards(ColorScheme scheme) {
    return StreamBuilder<QuerySnapshot>(
      // Fetches ALL requests to accurately count Pending, In-Progress, and Done.
      stream: FirebaseFirestore.instance.collection('requests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;
        
        final pendingCount = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data?['status'] == RequestStatus.pending.firestoreValue;
        }).length;
        
        final inProgressCount = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data?['status'] == RequestStatus.inProgress.firestoreValue;
        }).length;

        final doneCount = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return data?['status'] == RequestStatus.done.firestoreValue;
        }).length;

        return Row(
          children: [
            _metricCard(
              color: scheme.primaryContainer,
              label: 'Pending',
              value: pendingCount.toString(),
              icon: Icons.hourglass_bottom,
            ),
            _metricCard(
              color: scheme.tertiaryContainer,
              label: 'In-Progress',
              value: inProgressCount.toString(),
              icon: Icons.run_circle_outlined,
            ),
            _metricCard(
              color: scheme.secondaryContainer,
              label: 'Done',
              value: doneCount.toString(),
              icon: Icons.check_circle,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme; // This gives us the app colors

    return Scaffold(
      appBar: AppBar(
        // CHANGED: Title from 'Employer Dashboard' to 'Server Station'
        title: const Text('Server Station'),
        // CHANGED: Added a specific color (Orange) to distinguish from Manager (Grey/Blue)
        backgroundColor: Colors.orangeAccent, 
        
        // Top right actions (Notification and Profile Icons)
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
        // Tab bar at the bottom of the app bar
        bottom: TabBar(
          controller: _tab,
          // CHANGED: Indicator color to white for better contrast on Orange
          indicatorColor: Colors.white, 
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black54,
          tabs: const [
            Tab(text: 'Live'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // TAB 1: LIVE
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Three small KPI cards at the top
                _buildMetricCards(scheme),
                const SizedBox(height: 12),

                // Filters (change the local filter state)
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

                // Live Requests List StreamBuilder
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: liveRequestsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      // Check for errors (helps with debugging network/rule issues)
                      if (snapshot.hasError) {
                          debugPrint('Firestore Stream Error: ${snapshot.error}'); 
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                      }
                      
                      // 1. Get all live documents
                      var allLiveDocs = snapshot.data?.docs ?? [];
                      
                      // 2. Filter the documents LOCALLY based on the selected chip
                      var filteredDocs = allLiveDocs.where((doc) {
                        final docType = doc['type'] as String?;
                        
                        if (_filter == 'All') {
                          return true;
                        }
                        // Handles cases where 'type' might be null or missing
                        return docType == _filter;
                      }).toList();
                      
                      // 3. Check for empty AFTER local filter
                      if (filteredDocs.isEmpty) {
                         return Center(
                          child: Text(
                            // Provides context for the 'No requests' message
                            _filter == 'All' ? 'No live requests.' : 'No live $_filter requests.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      // 4. Build the list of request cards
                      return ListView.separated(
                        itemCount: filteredDocs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final req = filteredDocs[index];
                          final docId = req.id;
                          final type = req['type'] as String? ?? 'N/A';
                          final detail = req['detail'] as String? ?? 'No details provided'; 
                          final table = req['table'] as String? ?? 'N/A';
                          // Safely get statusValue, defaulting to 'Pending' if missing
                          final statusValue = req['status'] as String? ?? 'Pending'; 
                          final status = RequestStatus.values.firstWhere(
                            (s) => s.firestoreValue == statusValue,
                            orElse: () => RequestStatus.pending,
                          );

                          return _buildRequestCard(
                            docId: docId,
                            type: type,
                            detail: detail,
                            table: table,
                            status: status,
                            scheme: Theme.of(context).colorScheme,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // TAB 2: HISTORY
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: historyRequestsStream(),
                    builder: (context, snapshot) {
                      final hasHistory = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                      return TextButton.icon(
                        // tiny extra: remove all "done" items from the history
                        onPressed: hasHistory ? () async {
                           // Clear all 'Done' requests.
                           final batch = FirebaseFirestore.instance.batch();
                           for (final doc in snapshot.data!.docs) {
                             batch.delete(doc.reference);
                           }
                           await batch.commit();
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Cleared completed items')),
                           );
                        } : null,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Clear Done'),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: historyRequestsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No completed requests yet'),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      // Display history as a simple list (or could use DataTable later)
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final req = docs[index];
                          final type = req['type'] as String? ?? 'N/A';
                          final detail = req['detail'] as String? ?? '';
                          final table = req['table'] as String? ?? 'N/A';
                          final timestamp = req['timestamp'] as Timestamp?;
                          final timeAgo = timestamp != null
                              ? _timeSince(timestamp)
                              : 'just now';

                          return ListTile(
                            leading: _tableAvatar(table, scheme),
                            title: Text('$type - $table'),
                            subtitle: Text(detail),
                            trailing: Text(timeAgo),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper to format time (simplified)
  String _timeSince(Timestamp timestamp) {
    final duration = DateTime.now().difference(timestamp.toDate());
    if (duration.inMinutes < 1) return 'just now';
    if (duration.inHours < 1) return '${duration.inMinutes}m ago';
    if (duration.inDays < 1) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }


  // --- UI helper widgets below ---

  // Request Card with Start/Done buttons
  Widget _buildRequestCard({
    required String docId,
    required String type,
    required String detail,
    required String table,
    required RequestStatus status,
    required ColorScheme scheme,
  }) {
    return Card(
      // Uses the friend's nice card shape
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tableAvatar(table, scheme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$type • $detail',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Table: $table',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  _statusChip(status, scheme),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // The Start and Done buttons that trigger Firebase updates
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status != RequestStatus.inProgress)
                  OutlinedButton(
                    onPressed: () => updateRequestStatus(docId, RequestStatus.inProgress),
                    child: const Text('Start'),
                  ),
                const SizedBox(width: 8),
                if (status != RequestStatus.done)
                  FilledButton(
                    onPressed: () => updateRequestStatus(docId, RequestStatus.done),
                    child: const Text('Done'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Metric Card (Pending, In-Progress, Done boxes)
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
              Expanded( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12)),
                    Text(
                      value,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableAvatar(String table, ColorScheme scheme) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: scheme.primaryContainer,
      // I picked CircleAvatar because it's quick and looks clean.
      child: Text(table, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Helper to visually style the request status
  Widget _statusChip(RequestStatus status, ColorScheme scheme) {
    Color bg;
    Color fg;
    String text;
    // choose colors and text based on status
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