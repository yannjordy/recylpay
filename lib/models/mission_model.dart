class MissionModel {
  final String id;
  final String type;
  final String? collectionId;
  final String? collectorId;
  final String? collectorName;
  final String? delivererId;
  final String? delivererName;
  final String? sorterId;
  final String? sorterName;
  final String status;
  final double? commission;
  final double? distance;
  final List<String> imageUrls;
  final String description;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropLatitude;
  final double? dropLongitude;
  final String? pickupAddress;
  final String? dropAddress;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  MissionModel({
    required this.id,
    required this.type,
    this.collectionId,
    this.collectorId,
    this.collectorName,
    this.delivererId,
    this.delivererName,
    this.sorterId,
    this.sorterName,
    this.status = 'available',
    this.commission,
    this.distance,
    this.imageUrls = const [],
    this.description = '',
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
    this.pickupAddress,
    this.dropAddress,
    DateTime? createdAt,
    this.acceptedAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'collection_id': collectionId,
        'collector_id': collectorId,
        'collector_name': collectorName,
        'deliverer_id': delivererId,
        'deliverer_name': delivererName,
        'sorter_id': sorterId,
        'sorter_name': sorterName,
        'status': status,
        'commission': commission,
        'distance': distance,
        'image_urls': imageUrls,
        'description': description,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'drop_latitude': dropLatitude,
        'drop_longitude': dropLongitude,
        'pickup_address': pickupAddress,
        'drop_address': dropAddress,
        'created_at': createdAt.toIso8601String(),
        'accepted_at': acceptedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  factory MissionModel.fromJson(Map<String, dynamic> json) => MissionModel(
        id: json['id'] as String,
        type: json['type'] as String,
        collectionId: json['collection_id'] as String?,
        collectorId: json['collector_id'] as String?,
        collectorName: json['collector_name'] as String?,
        delivererId: json['deliverer_id'] as String?,
        delivererName: json['deliverer_name'] as String?,
        sorterId: json['sorter_id'] as String?,
        sorterName: json['sorter_name'] as String?,
        status: json['status'] as String? ?? 'available',
        commission: (json['commission'] as num?)?.toDouble(),
        distance: (json['distance'] as num?)?.toDouble(),
        imageUrls: json['image_urls'] != null ? List<String>.from(json['image_urls']) : [],
        description: json['description'] as String? ?? '',
        pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble(),
        pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble(),
        dropLatitude: (json['drop_latitude'] as num?)?.toDouble(),
        dropLongitude: (json['drop_longitude'] as num?)?.toDouble(),
        pickupAddress: json['pickup_address'] as String?,
        dropAddress: json['drop_address'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        acceptedAt: json['accepted_at'] != null
            ? DateTime.parse(json['accepted_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  String get statusLabel {
    switch (status) {
      case 'available':
        return 'Disponible';
      case 'accepted':
        return 'Acceptée';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'collecte':
        return 'Collecte';
      case 'livraison':
        return 'Livraison';
      case 'tri':
        return 'Tri';
      default:
        return type;
    }
  }

  MissionModel copyWith({
    String? id,
    String? type,
    String? collectionId,
    String? collectorId,
    String? collectorName,
    String? delivererId,
    String? delivererName,
    String? sorterId,
    String? sorterName,
    String? status,
    double? commission,
    double? distance,
    List<String>? imageUrls,
    String? description,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropLatitude,
    double? dropLongitude,
    String? pickupAddress,
    String? dropAddress,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) =>
      MissionModel(
        id: id ?? this.id,
        type: type ?? this.type,
        collectionId: collectionId ?? this.collectionId,
        collectorId: collectorId ?? this.collectorId,
        collectorName: collectorName ?? this.collectorName,
        delivererId: delivererId ?? this.delivererId,
        delivererName: delivererName ?? this.delivererName,
        sorterId: sorterId ?? this.sorterId,
        sorterName: sorterName ?? this.sorterName,
        status: status ?? this.status,
        commission: commission ?? this.commission,
        distance: distance ?? this.distance,
        imageUrls: imageUrls ?? this.imageUrls,
        description: description ?? this.description,
        pickupLatitude: pickupLatitude ?? this.pickupLatitude,
        pickupLongitude: pickupLongitude ?? this.pickupLongitude,
        dropLatitude: dropLatitude ?? this.dropLatitude,
        dropLongitude: dropLongitude ?? this.dropLongitude,
        pickupAddress: pickupAddress ?? this.pickupAddress,
        dropAddress: dropAddress ?? this.dropAddress,
        createdAt: createdAt ?? this.createdAt,
        acceptedAt: acceptedAt ?? this.acceptedAt,
        completedAt: completedAt ?? this.completedAt,
      );
}
