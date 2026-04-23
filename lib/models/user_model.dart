class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.preferredLanguage = 'EN',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    if (dateVal is String) return DateTime.parse(dateVal);
    // Handle Firestore Timestamp if present
    if (dateVal.runtimeType.toString() == 'Timestamp') {
      return dateVal.toDate();
    }
    return DateTime.now();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      preferredLanguage: json['preferredLanguage'] ?? 'EN',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImageUrl,
    String? preferredLanguage,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}