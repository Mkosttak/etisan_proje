class ReservationModel {
  final String id;
  final String userId;
  final String mealId;
  final String mealName;
  final String? mealDescription; // Menü içeriği
  final String mealType;
  final String mealPeriod;
  final DateTime mealDate;
  final String cafeteriaId; // Yemekhane ID
  final String cafeteriaName; // Yemekhane adı
  final double price;
  final String status; // 'reserved', 'consumed', 'cancelled', 'transferOpen', 'transferred'
  final String? qrCode;
  final bool isTransferOpen;
  final String? transferredToUserId;
  final int swapInterestedCount; // Kaç kişi takas etmek istiyor
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? consumedAt;
  final DateTime? cancelledAt;

  ReservationModel({
    required this.id,
    required this.userId,
    required this.mealId,
    required this.mealName,
    this.mealDescription,
    required this.mealType,
    required this.mealPeriod,
    required this.mealDate,
    this.cafeteriaId = 'cafeteria-1',
    this.cafeteriaName = 'Merkez Yemekhane',
    required this.price,
    required this.status,
    this.qrCode,
    required this.isTransferOpen,
    this.transferredToUserId,
    this.swapInterestedCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.consumedAt,
    this.cancelledAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      mealId: json['meal_id'] as String,
      mealName: json['meal_name'] as String,
      mealDescription: json['meal_description'] as String?,
      mealType: json['meal_type'] as String,
      mealPeriod: json['meal_period'] as String,
      mealDate: DateTime.parse(json['meal_date'] as String),
      cafeteriaId: json['cafeteria_id'] as String? ?? 'cafeteria-1',
      cafeteriaName: json['cafeteria_name'] as String? ?? 'Merkez Yemekhane',
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      qrCode: json['qr_code'] as String?,
      isTransferOpen: json['is_transfer_open'] as bool? ?? false,
      transferredToUserId: json['transferred_to_user_id'] as String?,
      swapInterestedCount: json['swap_interested_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      consumedAt: json['consumed_at'] != null 
          ? DateTime.parse(json['consumed_at'] as String) 
          : null,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meal_id': mealId,
      'meal_name': mealName,
      'meal_description': mealDescription,
      'meal_type': mealType,
      'meal_period': mealPeriod,
      'meal_date': mealDate.toIso8601String(),
      'cafeteria_id': cafeteriaId,
      'cafeteria_name': cafeteriaName,
      'price': price,
      'status': status,
      'qr_code': qrCode,
      'is_transfer_open': isTransferOpen,
      'transferred_to_user_id': transferredToUserId,
      'swap_interested_count': swapInterestedCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'consumed_at': consumedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }

  ReservationModel copyWith({
    String? id,
    String? userId,
    String? mealId,
    String? mealName,
    String? mealDescription,
    String? mealType,
    String? mealPeriod,
    DateTime? mealDate,
    String? cafeteriaId,
    String? cafeteriaName,
    double? price,
    String? status,
    String? qrCode,
    bool? isTransferOpen,
    String? transferredToUserId,
    int? swapInterestedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? consumedAt,
    DateTime? cancelledAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealId: mealId ?? this.mealId,
      mealName: mealName ?? this.mealName,
      mealDescription: mealDescription ?? this.mealDescription,
      mealType: mealType ?? this.mealType,
      mealPeriod: mealPeriod ?? this.mealPeriod,
      mealDate: mealDate ?? this.mealDate,
      cafeteriaId: cafeteriaId ?? this.cafeteriaId,
      cafeteriaName: cafeteriaName ?? this.cafeteriaName,
      price: price ?? this.price,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      isTransferOpen: isTransferOpen ?? this.isTransferOpen,
      transferredToUserId: transferredToUserId ?? this.transferredToUserId,
      swapInterestedCount: swapInterestedCount ?? this.swapInterestedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      consumedAt: consumedAt ?? this.consumedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  bool get isActive => status == 'reserved';
  bool get isConsumed => status == 'consumed';
  bool get isCancelled => status == 'cancelled';
  bool get isTransferred => status == 'transferred';
  bool get isPast => mealDate.isBefore(DateTime.now());
  bool get canCancel => isActive && !isPast && 
      mealDate.difference(DateTime.now()).inHours > 24;
  bool get canOpenForSwap => isActive && !isPast && 
      mealDate.difference(DateTime.now()).inHours > 48;
  
  // Alias methods for compatibility
  bool get canBeCancelled => canCancel;
  bool get canBeTransferred => canOpenForSwap;
}

