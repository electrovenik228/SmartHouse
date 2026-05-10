enum DeviceType {
  light,
  ac,
  outlet,
  camera,
  temp_sensor,
  motion_sensor;

  static DeviceType fromString(String s) =>
      DeviceType.values.firstWhere((e) => e.name == s, orElse: () => DeviceType.light);

  String get label => switch (this) {
        DeviceType.light => 'Лампа',
        DeviceType.ac => 'Кондиционер',
        DeviceType.outlet => 'Розетка',
        DeviceType.camera => 'Камера',
        DeviceType.temp_sensor => 'Температура',
        DeviceType.motion_sensor => 'Датчик движения',
      };
}

class Device {
  final int id;
  final String name;
  final DeviceType type;
  final bool isOn;
  final double? value;
  final int roomId;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    required this.value,
    required this.roomId,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as int,
        name: json['name'] as String,
        type: DeviceType.fromString(json['type'] as String),
        isOn: json['is_on'] as bool,
        value: (json['value'] as num?)?.toDouble(),
        roomId: json['room_id'] as int,
      );

  Device copyWith({bool? isOn, double? value}) => Device(
        id: id,
        name: name,
        type: type,
        isOn: isOn ?? this.isOn,
        value: value ?? this.value,
        roomId: roomId,
      );
}
