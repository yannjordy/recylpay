class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userUniqueId;
  final String? userPhotoUrl;
  final String imageUrl;
  final String? description;
  final List<String> wasteTypes;
  final int likes;
  final int commentsCount;
  final DateTime createdAt;
  final bool isLiked;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userUniqueId,
    this.userPhotoUrl,
    required this.imageUrl,
    this.description,
    this.wasteTypes = const [],
    this.likes = 0,
    this.commentsCount = 0,
    DateTime? createdAt,
    this.isLiked = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_unique_id': userUniqueId,
        'user_photo_url': userPhotoUrl,
        'image_url': imageUrl,
        'description': description,
        'waste_types': wasteTypes,
        'likes': likes,
        'comments_count': commentsCount,
        'created_at': createdAt.toIso8601String(),
        'is_liked': isLiked,
      };

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userUniqueId: json['user_unique_id'] as String? ?? '',
        userPhotoUrl: json['user_photo_url'] as String?,
        imageUrl: json['image_url'] as String,
        description: json['description'] as String?,
        wasteTypes: json['waste_types'] != null
            ? List<String>.from(json['waste_types'] as List)
            : [],
        likes: json['likes'] as int? ?? 0,
        commentsCount: json['comments_count'] as int? ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        isLiked: json['is_liked'] as bool? ?? false,
      );

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userUniqueId,
    String? userPhotoUrl,
    String? imageUrl,
    String? description,
    List<String>? wasteTypes,
    int? likes,
    int? commentsCount,
    DateTime? createdAt,
    bool? isLiked,
  }) =>
      PostModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userUniqueId: userUniqueId ?? this.userUniqueId,
        userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
        wasteTypes: wasteTypes ?? this.wasteTypes,
        likes: likes ?? this.likes,
        commentsCount: commentsCount ?? this.commentsCount,
        createdAt: createdAt ?? this.createdAt,
        isLiked: isLiked ?? this.isLiked,
      );
}

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'user_id': userId,
        'user_name': userName,
        'user_photo_url': userPhotoUrl,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'] as String,
        postId: json['post_id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userPhotoUrl: json['user_photo_url'] as String?,
        content: json['content'] as String,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );
}
