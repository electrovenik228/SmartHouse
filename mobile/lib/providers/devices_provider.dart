import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/models/device.dart';
import 'package:smarthome/providers/api_provider.dart';

class DevicesNotifier extends StateNotifier<AsyncValue<List<Device>>> {
  final Ref _ref;

  DevicesNotifier(this._ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ref.read(apiClientProvider).getDevices());
  }

  Future<void> loadForRoom(int roomId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _ref.read(apiClientProvider).getRoomDevices(roomId));
  }

  Future<void> toggle(int deviceId) async {
    final updated = await _ref.read(apiClientProvider).toggleDevice(deviceId);
    state = state.whenData(
      (list) => list.map((d) => d.id == updated.id ? updated : d).toList(),
    );
  }

  // Called by WebSocket to patch a single device
  void applyUpdate(Device updated) {
    state = state.whenData(
      (list) => list.map((d) => d.id == updated.id ? updated : d).toList(),
    );
  }
}

final devicesProvider = StateNotifierProvider<DevicesNotifier, AsyncValue<List<Device>>>(
  (ref) => DevicesNotifier(ref),
);

final roomDevicesProvider = StateNotifierProvider.family<DevicesNotifier, AsyncValue<List<Device>>, int>(
  (ref, roomId) => DevicesNotifier(ref)..loadForRoom(roomId),
);
