import 'package:flutter/material.dart';
import 'package:smarthome/models/device.dart';

class DeviceIcon extends StatelessWidget {
  final DeviceType type;
  final bool isOn;
  final double size;

  const DeviceIcon({super.key, required this.type, required this.isOn, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final color = isOn ? Colors.amber : Colors.grey;
    final icon = switch (type) {
      DeviceType.light => Icons.lightbulb,
      DeviceType.ac => Icons.ac_unit,
      DeviceType.outlet => Icons.power,
      DeviceType.camera => Icons.videocam,
      DeviceType.temp_sensor => Icons.thermostat,
      DeviceType.motion_sensor => Icons.directions_run,
    };
    return Icon(icon, color: color, size: size);
  }
}
