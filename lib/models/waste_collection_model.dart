class WasteCollectionModel {
  final String id;
  final String userId;
  final String? userName;
  final String category;
  final double estimatedWeight;
  final double? actualWeight;
  final double pricePerKg;
  final double? totalAmount;
  final String status;
  final String? photoUrl;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? companyId;
  final String? companyName;
  final DateTime createdAt;
  final DateTime? completedAt;

  WasteCollectionModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.category,
    required this.estimatedWeight,
    this.actualWeight,
    required this.pricePerKg,
    this.totalAmount,
    this.status = 'pending',
    this.photoUrl,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    this.companyId,
    this.companyName,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get calculatedAmount {
    final weight = actualWeight ?? estimatedWeight;
    return weight * pricePerKg;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'category': category,
        'estimated_weight': estimatedWeight,
        'actual_weight': actualWeight,
        'price_per_kg': pricePerKg,
        'total_amount': totalAmount ?? calculatedAmount,
        'status': status,
        'photo_url': photoUrl,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'company_id': companyId,
        'company_name': companyName,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  factory WasteCollectionModel.fromJson(Map<String, dynamic> json) =>
      WasteCollectionModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String?,
        category: json['category'] as String,
        estimatedWeight: (json['estimated_weight'] as num).toDouble(),
        actualWeight: (json['actual_weight'] as num?)?.toDouble(),
        pricePerKg: (json['price_per_kg'] as num).toDouble(),
        totalAmount: (json['total_amount'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'pending',
        photoUrl: json['photo_url'] as String?,
        description: json['description'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        companyId: json['company_id'] as String?,
        companyName: json['company_name'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  WasteCollectionModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? category,
    double? estimatedWeight,
    double? actualWeight,
    double? pricePerKg,
    double? totalAmount,
    String? status,
    String? photoUrl,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? companyId,
    String? companyName,
    DateTime? createdAt,
    DateTime? completedAt,
  }) =>
      WasteCollectionModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        category: category ?? this.category,
        estimatedWeight: estimatedWeight ?? this.estimatedWeight,
        actualWeight: actualWeight ?? this.actualWeight,
        pricePerKg: pricePerKg ?? this.pricePerKg,
        totalAmount: totalAmount ?? this.totalAmount,
        status: status ?? this.status,
        photoUrl: photoUrl ?? this.photoUrl,
        description: description ?? this.description,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        companyId: companyId ?? this.companyId,
        companyName: companyName ?? this.companyName,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
      );

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'accepted':
        return 'Acceptée';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'paid':
        return 'Payée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
