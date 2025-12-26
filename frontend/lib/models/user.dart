
class User {
  final int userId;
  final String username;
  final String? email;  // Optional for search results
  final int? age;       // Optional for search results
  final String? role;   // Optional for backwards compatibility

  User({
    required this.userId,
    required this.username,
    this.email,
    this.age,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      age: json['age'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      if (email != null) 'email': email,
      if (age != null) 'age': age,
      if (role != null) 'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'mod';
}
