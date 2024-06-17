class User {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String country;
  final String username;
  final String id;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.country,
    required this.username,
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      password: json['password'] as String, // Note: It's unusual to include passwords in API responses.
      country: json['country'] as String,
      username: json['userName'] as String, // Make sure the key matches what's returned by the API.
      id: json['id'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
      'Password': password,
      'Country': country,
      'username': username,
      'id': id,
    };
  }

}
