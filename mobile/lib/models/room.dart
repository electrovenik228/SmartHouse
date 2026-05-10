class Room {
  final int id;
  final String name;
  final String icon;

  const Room({required this.id, required this.name, required this.icon});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as int,
        name: json['name'] as String,
        icon: json['icon'] as String,
      );
}
