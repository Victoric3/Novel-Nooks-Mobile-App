import 'dart:convert';

class UserModel {
  final String id;
  final String firstname;
  final String lastname;
  final String username;
  final String email;
  final String photo;
  final String role;
  final List<String> interests;
  final bool isPremium;
  final int coins;
  final List<dynamic> purchased;
  final bool emailVerified;

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    required this.photo,
    required this.role,
    this.interests = const [],
    this.isPremium = false,
    this.coins = 0,
    this.purchased = const [],
    this.emailVerified = false,
  });

  // Create a copy of the model with updated fields
  UserModel copyWith({
    String? id,
    String? firstname,
    String? lastname,
    String? username,
    String? email,
    String? photo,
    String? role,
    List<String>? interests,
    bool? isPremium,
    int? coins,
    List<dynamic>? purchased,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      username: username ?? this.username,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      interests: interests ?? this.interests,
      isPremium: isPremium ?? this.isPremium,
      coins: coins ?? this.coins,
      purchased: purchased ?? this.purchased,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserModel(
        id: '',
        firstname: '',
        lastname: '',
        username: 'Guest',
        email: '',
        photo: '',
        role: 'user',
        interests: [],
        isPremium: false,
        coins: 0,
        purchased: [],
        emailVerified: false,
      );
    }
    
    return UserModel(
      id: json['_id'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'] ?? '',
      role: json['role'] ?? 'user',
      interests: List<String>.from(json['interests'] ?? []),
      isPremium: json['isPremium'] ?? false,
      coins: json['coins'] ?? 0,
      purchased: json['purchased'] ?? [],
      emailVerified: json['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstname': firstname,
      'lastname': lastname,
      'username': username,
      'email': email,
      'photo': photo,
      'role': role,
      'interests': interests,
      'isPremium': isPremium,
      'coins': coins,
      'purchased': purchased,
      'emailVerified': emailVerified,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
  
  factory UserModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserModel.fromJson(json);
  }
}