import 'package:flutter/material.dart';
import '../backend_service.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.service});

  final BackendService service;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Entry> _entries = [];
  String _filter = '';
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.service.fetchEntries();
    setState(() => _entries = data);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _entries
        .where((e) => e.content.toLowerCase().contains(_filter.toLowerCase()))
        .toList();
    final pageSize = 10;
    final start = _page * pageSize;
    final end = (start + pageSize).clamp(0, filtered.length);
    final pageItems = filtered.sublist(start, end);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Filter',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: pageItems.length,
                itemBuilder: (context, index) {
                  final entry = pageItems[index];
                  return Card(
                    child: ListTile(
                      title: Text(entry.content),
                      subtitle: entry.summary != null
                          ? Text(entry.summary!)
                          : null,
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _page > 0
                      ? () => setState(() => _page--)
                      : null,
                ),
                Text('${_page + 1} / ${(filtered.length / pageSize).ceil().clamp(1, 999)}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: end < filtered.length
                      ? () => setState(() => _page++)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
