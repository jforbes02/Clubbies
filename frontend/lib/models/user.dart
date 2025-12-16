
class User {
  final int userId;
  final String username;
  final String email;
  final int age;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'age': age,
    };
  }
}
