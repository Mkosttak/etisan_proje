class MealModel {
  final String id;
  final String name;
  final String description;
  final String mealType; // 'normal', 'vegetarian', 'vegan', 'glutenFree'
  final String mealPeriod; // 'breakfast', 'lunch', 'dinner'
  final DateTime mealDate;
  final String cafeteriaId; // Yemekhane ID
  final String cafeteriaName; // Yemekhane adı
  final double reservationPrice;
  final double walkInPrice;
  final int totalSpots;
  final int availableSpots;
  final List<String> allergens;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFromSwap; // Takas üzerinden mi alındı

  MealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.mealType,
    required this.mealPeriod,
    required this.mealDate,
    this.cafeteriaId = 'cafeteria-1',
    this.cafeteriaName = 'Merkez Yemekhane',
    required this.reservationPrice,
    required this.walkInPrice,
    required this.totalSpots,
    required this.availableSpots,
    required this.allergens,
    this.imageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isFromSwap = false,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      mealType: json['meal_type'] as String,
      mealPeriod: json['meal_period'] as String,
      mealDate: DateTime.parse(json['meal_date'] as String),
      cafeteriaId: json['cafeteria_id'] as String? ?? 'cafeteria-1',
      cafeteriaName: json['cafeteria_name'] as String? ?? 'Merkez Yemekhane',
      reservationPrice: (json['reservation_price'] as num).toDouble(),
      walkInPrice: (json['walk_in_price'] as num).toDouble(),
      totalSpots: json['total_spots'] as int,
      availableSpots: json['available_spots'] as int,
      allergens: List<String>.from(json['allergens'] as List),
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      isFromSwap: json['is_from_swap'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'meal_type': mealType,
      'meal_period': mealPeriod,
      'meal_date': mealDate.toIso8601String(),
      'cafeteria_id': cafeteriaId,
      'cafeteria_name': cafeteriaName,
      'reservation_price': reservationPrice,
      'walk_in_price': walkInPrice,
      'total_spots': totalSpots,
      'available_spots': availableSpots,
      'allergens': allergens,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_from_swap': isFromSwap,
    };
  }

  MealModel copyWith({
    String? id,
    String? name,
    String? description,
    String? mealType,
    String? mealPeriod,
    DateTime? mealDate,
    String? cafeteriaId,
    String? cafeteriaName,
    double? reservationPrice,
    double? walkInPrice,
    int? totalSpots,
    int? availableSpots,
    List<String>? allergens,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFromSwap,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mealType: mealType ?? this.mealType,
      mealPeriod: mealPeriod ?? this.mealPeriod,
      mealDate: mealDate ?? this.mealDate,
      cafeteriaId: cafeteriaId ?? this.cafeteriaId,
      cafeteriaName: cafeteriaName ?? this.cafeteriaName,
      reservationPrice: reservationPrice ?? this.reservationPrice,
      walkInPrice: walkInPrice ?? this.walkInPrice,
      totalSpots: totalSpots ?? this.totalSpots,
      availableSpots: availableSpots ?? this.availableSpots,
      allergens: allergens ?? this.allergens,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFromSwap: isFromSwap ?? this.isFromSwap,
    );
  }

  bool get isAvailable => availableSpots > 0;
  double get savingsAmount => walkInPrice - reservationPrice;
}

