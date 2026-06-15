class TransactionModel {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final double? commission;
  final String status;
  final String? reference;
  final String? description;
  final String? collectionId;
  final String? missionId;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.commission,
    this.status = 'pending',
    this.reference,
    this.description,
    this.collectionId,
    this.missionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'amount': amount,
        'commission': commission,
        'status': status,
        'reference': reference,
        'description': description,
        'collection_id': collectionId,
        'mission_id': missionId,
        'created_at': createdAt.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        commission: (json['commission'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'pending',
        reference: json['reference'] as String?,
        description: json['description'] as String?,
        collectionId: json['collection_id'] as String?,
        missionId: json['mission_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  String get typeLabel {
    switch (type) {
      case 'deposit':
        return 'Dépôt';
      case 'withdrawal':
        return 'Retrait';
      case 'payment_received':
        return 'Paiement reçu';
      case 'payment_sent':
        return 'Paiement envoyé';
      case 'payment':
        return 'Paiement';
      case 'commission':
        return 'Commission';
      case 'bonus':
        return 'Bonus';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Complétée';
      case 'failed':
        return 'Échouée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
