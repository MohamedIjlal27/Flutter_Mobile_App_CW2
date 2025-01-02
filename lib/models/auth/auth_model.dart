import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUser {
  final String? uid;
  final String? email;
  final String? name;
  final String? profileImage;
  final DateTime? createdAt;

  AuthUser({
    this.uid,
    this.email,
    this.name,
    this.profileImage,
    this.createdAt,
  });

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      uid: map['uid'] as String?,
      email: map['email'] as String?,
      name: map['name'] as String?,
      profileImage: map['profileImage'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profileImage': profileImage,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  AuthUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
