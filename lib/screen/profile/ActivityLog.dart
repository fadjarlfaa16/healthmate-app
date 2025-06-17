import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/ActivityLog.dart';

class ActivityLogPage extends StatelessWidget {
  const ActivityLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: LogDatabase.instance.getAllLogs(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snap.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No activity recorded.'));
          }
          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final log = logs[i];
              final action = log['action'] as String;
              final ts = DateTime.parse(log['timestamp'] as String);
              final userId = log['userId'] as String;
              return ListTile(
                leading: Icon(
                  action == 'login' ? Icons.login : Icons.logout,
                  color: action == 'login' ? Colors.green : Colors.red,
                ),
                title: Text(
                  '${action[0].toUpperCase()}${action.substring(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(DateFormat('dd MMM yyyy, HH:mm:ss').format(ts)),
                trailing: Text(
                  userId,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
