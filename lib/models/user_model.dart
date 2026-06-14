class UserModel {
  final String id;
  final String phone;
  final String name;
  final String uniqueId;
  final String? email;
  final String role;
  final double balance;
  final double rating;
  final int completedMissions;
  final bool isOnline;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final List<String> collectedTypes;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    String? uniqueId,
    this.email,
    this.role = 'collecteur',
    this.balance = 0,
    this.rating = 0,
    this.completedMissions = 0,
    this.isOnline = false,
    this.latitude,
    this.longitude,
    this.photoUrl,
    this.collectedTypes = const [],
    DateTime? createdAt,
  })  : uniqueId = uniqueId ?? _generateUniqueId(name),
        createdAt = createdAt ?? DateTime.now();

  static String _generateUniqueId(String name) {
    final clean = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return '@$clean$suffix';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'unique_id': uniqueId,
        'email': email,
        'role': role,
        'balance': balance,
        'rating': rating,
        'completed_missions': completedMissions,
        'is_online': isOnline,
        'latitude': latitude,
        'longitude': longitude,
        'photo_url': photoUrl,
        'collected_types': collectedTypes,
        'created_at': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String,
        uniqueId: json['unique_id'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String? ?? 'collecteur',
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        completedMissions: json['completed_missions'] as int? ?? 0,
        isOnline: json['is_online'] as bool? ?? false,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        photoUrl: json['photo_url'] as String?,
        collectedTypes: json['collected_types'] != null
            ? List<String>.from(json['collected_types'] as List)
            : [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? uniqueId,
    String? email,
    String? role,
    double? balance,
    double? rating,
    int? completedMissions,
    bool? isOnline,
    double? latitude,
    double? longitude,
    String? photoUrl,
    List<String>? collectedTypes,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        uniqueId: uniqueId ?? this.uniqueId,
        email: email ?? this.email,
        role: role ?? this.role,
        balance: balance ?? this.balance,
        rating: rating ?? this.rating,
        completedMissions: completedMissions ?? this.completedMissions,
        isOnline: isOnline ?? this.isOnline,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        photoUrl: photoUrl ?? this.photoUrl,
        collectedTypes: collectedTypes ?? this.collectedTypes,
        createdAt: createdAt ?? this.createdAt,
      );

  String get roleLabel {
    switch (role) {
      case 'collecteur':
        return 'Collecteur';
      case 'trieur':
        return 'Trieur';
      case 'livreur':
        return 'Livreur';
      default:
        return role;
    }
  }
}
