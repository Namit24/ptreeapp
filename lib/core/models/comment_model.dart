class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  
  // User info (joined from profiles table)
  final String? userFullName;
  final String? userUsername;
  final String? userProfileImage;
  
  // Replies (for nested comments)
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.userFullName,
    this.userUsername,
    this.userProfileImage,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      parentCommentId: json['parent_comment_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      likesCount: json['likes_count'] ?? 0,
      userFullName: json['user_full_name'],
      userUsername: json['user_username'],
      userProfileImage: json['user_profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_comment_id': parentCommentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'likes_count': likesCount,
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentCommentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    String? userFullName,
    String? userUsername,
    String? userProfileImage,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      userFullName: userFullName ?? this.userFullName,
      userUsername: userUsername ?? this.userUsername,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      replies: replies ?? this.replies,
    );
  }
}
