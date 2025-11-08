class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'load', 'reservation', 'refund', 'transfer'
  final double amount;
  final double balanceAfter;
  final String description;
  final String? reservationId;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    this.reservationId,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      description: json['description'] as String,
      reservationId: json['reservation_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'balance_after': balanceAfter,
      'description': description,
      'reservation_id': reservationId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isDebit => type == 'reservation' || type == 'transfer';
  bool get isCredit => type == 'load' || type == 'refund';
}

