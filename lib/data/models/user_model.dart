class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? schoolEmail;
  final String? phone;
  final String? studentNumber;
  final String role; // 'student', 'staff', 'admin'
  final double balance;
  final String? school;
  final String? profileImageUrl;
  final String? mealPreference; // 'normal', 'vegetarian', 'vegan', 'gluten_free'
  final String? preferredCafeteriaId; // Tercih edilen yemekhane
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.schoolEmail,
    this.phone,
    this.studentNumber,
    required this.role,
    required this.balance,
    this.school,
    this.profileImageUrl,
    this.mealPreference,
    this.preferredCafeteriaId,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      schoolEmail: json['school_email'] as String?,
      phone: json['phone'] as String?,
      studentNumber: json['student_number'] as String?,
      role: json['role'] as String? ?? 'student',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      school: json['school'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      mealPreference: json['meal_preference'] as String?,
      preferredCafeteriaId: json['preferred_cafeteria_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'school_email': schoolEmail,
      'phone': phone,
      'student_number': studentNumber,
      'role': role,
      'balance': balance,
      'school': school,
      'profile_image_url': profileImageUrl,
      'meal_preference': mealPreference,
      'preferred_cafeteria_id': preferredCafeteriaId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? schoolEmail,
    String? phone,
    String? studentNumber,
    String? role,
    double? balance,
    String? school,
    String? profileImageUrl,
    String? mealPreference,
    String? preferredCafeteriaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      schoolEmail: schoolEmail ?? this.schoolEmail,
      phone: phone ?? this.phone,
      studentNumber: studentNumber ?? this.studentNumber,
      role: role ?? this.role,
      balance: balance ?? this.balance,
      school: school ?? this.school,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      mealPreference: mealPreference ?? this.mealPreference,
      preferredCafeteriaId: preferredCafeteriaId ?? this.preferredCafeteriaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';
  bool get isStaff => role == 'staff';
}

