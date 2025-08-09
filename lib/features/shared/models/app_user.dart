import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum UserRole { parent, caretaker, admin }

class AppUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final List<String> assignedRooms;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.assignedRooms = const [],
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Handle case where document data is null
    if (data == null) {
      throw Exception('Document data is null for user ${doc.id}');
    }

    return AppUser(
      id: doc.id,
      email: data['email']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      role: UserRole.values.firstWhere(
        (e) =>
            e.toString() == 'UserRole.${data['role']?.toString() ?? 'parent'}',
        orElse: () => UserRole.parent,
      ),
      assignedRooms: data['assignedRooms'] != null
          ? List<String>.from(data['assignedRooms'])
          : [],
      isActive: data['isActive'] == true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.name,
      'assignedRooms': assignedRooms,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    List<String>? assignedRooms,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      assignedRooms: assignedRooms ?? this.assignedRooms,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.parent:
        return 'Orangtua';
      case UserRole.caretaker:
        return 'Pengasuh';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color get roleColor {
    switch (role) {
      case UserRole.parent:
        return const Color(0xFF2196F3);
      case UserRole.caretaker:
        return const Color(0xFF4CAF50);
      case UserRole.admin:
        return const Color(0xFF9C27B0);
    }
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ role.hashCode;
  }
}
