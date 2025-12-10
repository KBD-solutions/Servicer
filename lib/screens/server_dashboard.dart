import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/*
  This page serves as the Server dashboard.
  It displays real-time requests from the database, split into two tabs: Live and History.
*/

enum RequestStatus {
  pending('Pending'),
  inProgress('In-Progress'),
  done('Done');

  final String firestoreValue;
  const RequestStatus(this.firestoreValue);
}

// Function to update the status of a request in Firebase
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

class ServerDashboardPage extends StatefulWidget {
  // CHANGED: Added customization parameters
  final String? pageTitle;
  final Color? appBarColor;
  final List<Widget>? extraActions;

  const ServerDashboardPage({
    super.key, 
    this.pageTitle,
    this.appBarColor,
    this.extraActions,
  });

  @override
  State<ServerDashboardPage> createState() => _ServerDashboardPageState();
}

class _ServerDashboardPageState extends State<ServerDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _filter = 'All'; 

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this); 
  }

  @override
  void dispose() {
    _tab.dispose(); 
    super.dispose();
  }

  // Live Requests Query
  Stream<QuerySnapshot> liveRequestsStream() {
    Query query = FirebaseFirestore.instance
        .collection('requests')
        .where('status', whereIn: [
          RequestStatus.pending.firestoreValue,
          RequestStatus.inProgress.firestoreValue
        ])
        .orderBy('status')
        .orderBy('timestamp', descending: true); 

    return query.snapshots();
  }

  // History Requests Query
  Stream<QuerySnapshot> historyRequestsStream() {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: RequestStatus.done.firestoreValue)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Function to calculate counts for the top cards
  Widget _buildMetricCards(ColorScheme scheme) {
    return StreamBuilder<QuerySnapshot>(
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
    final scheme = Theme.of(context).colorScheme; 

    return Scaffold(
      appBar: AppBar(
        // CHANGED: Use customized title or default
        title: Text(widget.pageTitle ?? 'Server Station'),
        // CHANGED: Use customized color or default
        backgroundColor: widget.appBarColor ?? Colors.orangeAccent, 
        
        // CHANGED: Merge extraActions (from Manager) with default icons
        actions: [
          if (widget.extraActions != null) ...widget.extraActions!,
          
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.notifications_none),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
        
        bottom: TabBar(
          controller: _tab,
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
                _buildMetricCards(scheme),
                const SizedBox(height: 12),

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

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: liveRequestsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
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
                      
                      var allLiveDocs = snapshot.data?.docs ?? [];
                      
                      var filteredDocs = allLiveDocs.where((doc) {
                        final docType = doc['type'] as String?;
                        if (_filter == 'All') return true;
                        return docType == _filter;
                      }).toList();
                      
                      if (filteredDocs.isEmpty) {
                         return Center(
                          child: Text(
                            _filter == 'All' ? 'No live requests.' : 'No live $_filter requests.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filteredDocs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final req = filteredDocs[index];
                          final docId = req.id;
                          final type = req['type'] as String? ?? 'N/A';
                          final detail = req['detail'] as String? ?? 'No details provided'; 
                          final table = req['table'] as String? ?? 'N/A';
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
                        onPressed: hasHistory ? () async {
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

  String _timeSince(Timestamp timestamp) {
    final duration = DateTime.now().difference(timestamp.toDate());
    if (duration.inMinutes < 1) return 'just now';
    if (duration.inHours < 1) return '${duration.inMinutes}m ago';
    if (duration.inDays < 1) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }

  Widget _buildRequestCard({
    required String docId,
    required String type,
    required String detail,
    required String table,
    required RequestStatus status,
    required ColorScheme scheme,
  }) {
    return Card(
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
              // FIX: Wrap text in Expanded to prevent RenderFlex overflow
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
      child: Text(table, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _statusChip(RequestStatus status, ColorScheme scheme) {
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