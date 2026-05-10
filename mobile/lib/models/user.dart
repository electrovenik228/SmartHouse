class User {
  final int id;
  final String username;
  final String email;
  final bool isAdmin;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.isAdmin,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        isAdmin: json['is_admin'] as bool,
      );
}
