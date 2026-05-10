import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:smarthome/core/auth_storage.dart';
import 'package:smarthome/core/constants.dart';
import 'package:smarthome/models/device.dart';
import 'package:smarthome/providers/devices_provider.dart';

final websocketProvider = Provider<void>((ref) {
  _connectWs(ref);
  ref.onDispose(() {});
});

void _connectWs(Ref ref) async {
  final token = await AuthStorage.getToken();
  if (token == null) return;

  final channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));

  channel.stream.listen(
    (raw) {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      if (data['type'] == 'device_update') {
        final device = Device.fromJson(data['device'] as Map<String, dynamic>);
        // Update all loaded device lists
        ref.read(devicesProvider.notifier).applyUpdate(device);
      }
    },
    onDone: () => Future.delayed(const Duration(seconds: 5), () => _connectWs(ref)),
    onError: (_) => Future.delayed(const Duration(seconds: 5), () => _connectWs(ref)),
  );
}
