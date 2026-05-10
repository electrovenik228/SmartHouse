import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/models/action_log.dart';
import 'package:smarthome/providers/api_provider.dart';

final logsProvider = FutureProvider<List<ActionLog>>((ref) async {
  return ref.read(apiClientProvider).getLogs();
});
