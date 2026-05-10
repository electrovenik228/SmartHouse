import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/models/device.dart';
import 'package:smarthome/providers/devices_provider.dart';
import 'package:smarthome/widgets/device_icon.dart';

class RoomScreen extends ConsumerWidget {
  final int roomId;
  final String roomName;

  const RoomScreen({super.key, required this.roomId, required this.roomName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(roomDevicesProvider(roomId));

    return Scaffold(
      appBar: AppBar(title: Text(roomName)),
      body: devicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (devices) => devices.isEmpty
            ? const Center(child: Text('Нет устройств'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: devices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _DeviceTile(
                  device: devices[i],
                  onToggle: () => ref.read(roomDevicesProvider(roomId).notifier).toggle(devices[i].id),
                ),
              ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final Device device;
  final VoidCallback onToggle;

  const _DeviceTile({required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isSensor =
        device.type == DeviceType.temp_sensor || device.type == DeviceType.motion_sensor;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: device.isOn ? Colors.indigo.shade50 : Colors.grey.shade100,
          child: DeviceIcon(type: device.type, isOn: device.isOn),
        ),
        title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: _buildSubtitle(device),
        trailing: isSensor
            ? _SensorBadge(device: device)
            : Switch(
                value: device.isOn,
                onChanged: (_) => onToggle(),
              ),
      ),
    );
  }

  Widget? _buildSubtitle(Device device) {
    return Text(
      device.type.label,
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    );
  }
}

class _SensorBadge extends StatelessWidget {
  final Device device;
  const _SensorBadge({required this.device});

  @override
  Widget build(BuildContext context) {
    if (device.type == DeviceType.temp_sensor) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          '${device.value?.toStringAsFixed(1) ?? '--'}°C',
          style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold),
        ),
      );
    }
    // Motion sensor
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: device.isOn ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: device.isOn ? Colors.red.shade200 : Colors.green.shade200),
      ),
      child: Text(
        device.isOn ? 'Движение!' : 'Тихо',
        style: TextStyle(
          color: device.isOn ? Colors.red.shade800 : Colors.green.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
