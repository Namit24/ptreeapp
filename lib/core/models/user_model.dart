import 'package:json_annotation/json_annotation.dart';

// Remove this line: part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String? name;
  final String? username;
  final String? bio;
  final String? profileImage;
  final String? college;
  final String? course;
  final int? year;
  final List<String> skills;
  final List<String> interests;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.username,
    this.bio,
    this.profileImage,
    this.college,
    this.course,
    this.year,
    this.skills = const [],
    this.interests = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Temporary manual JSON methods
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      profileImage: json['profileImage'] as String?,
      college: json['college'] as String?,
      course: json['course'] as String?,
      year: json['year'] as int?,
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'username': username,
      'bio': bio,
      'profileImage': profileImage,
      'college': college,
      'course': course,
      'year': year,
      'skills': skills,
      'interests': interests,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'isFollowing': isFollowing,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
