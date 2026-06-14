class PollutionReportModel {
  final String id;
  final String userId;
  final String? userName;
  final String description;
  final String? photoUrl;
  final double latitude;
  final double longitude;
  final String? address;
  final String severity;
  final int reportCount;
  final bool isCritical;
  final DateTime createdAt;

  PollutionReportModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.description,
    this.photoUrl,
    required this.latitude,
    required this.longitude,
    this.address,
    this.severity = 'low',
    this.reportCount = 1,
    this.isCritical = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'description': description,
        'photo_url': photoUrl,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'severity': severity,
        'report_count': reportCount,
        'is_critical': isCritical,
        'created_at': createdAt.toIso8601String(),
      };

  factory PollutionReportModel.fromJson(Map<String, dynamic> json) =>
      PollutionReportModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String?,
        description: json['description'] as String,
        photoUrl: json['photo_url'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        severity: json['severity'] as String? ?? 'low',
        reportCount: json['report_count'] as int? ?? 1,
        isCritical: json['is_critical'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  String get severityLabel {
    switch (severity) {
      case 'low':
        return 'Faible';
      case 'medium':
        return 'Moyenne';
      case 'high':
        return 'Élevée';
      case 'critical':
        return 'Critique';
      default:
        return severity;
    }
  }
}
