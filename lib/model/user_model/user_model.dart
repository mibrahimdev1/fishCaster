class UserModel {
  final String id;
  final String name;
  final String email;
  final String country;
  final String state;
  final String city;
  final String zipCode;
  final String role;
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.country,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.role,
    required this.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;

    return UserModel(
      id: userData['id'] ?? '',
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      country: userData['country'] ?? '',
      state: userData['state'] ?? '',
      city: userData['city'] ?? '',
      zipCode: userData['zipCode'] ?? '',
      role: userData['role'] ?? '',
      isEmailVerified: userData['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'country': country,
      'state': state,
      'city': city,
      'zipCode': zipCode,
      'role': role,
      'isEmailVerified': isEmailVerified,
    };
  }
}
