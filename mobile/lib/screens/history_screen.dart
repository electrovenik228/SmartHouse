import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/models/action_log.dart';
import 'package:smarthome/providers/logs_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('История действий'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(logsProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (logs) => logs.isEmpty
            ? const Center(child: Text('История пуста'))
            : ListView.separated(
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) => _LogTile(log: logs[i]),
              ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final ActionLog log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd.MM.yyyy HH:mm:ss');
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFEEF2FF),
        child: Icon(Icons.history, color: Colors.indigo, size: 20),
      ),
      title: Text(log.action, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        'Устройство #${log.deviceId}  •  ${fmt.format(log.createdAt.toLocal())}',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
    );
  }
}
