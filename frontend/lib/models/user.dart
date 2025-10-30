
class User {
  final int userId;
  final String username;
  final String email;
  final String age;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.age,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'age': age,
    };
  }
}
