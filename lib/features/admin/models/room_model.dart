import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String description;
  final String? parentId;
  final List<String> caretakerIds;
  final bool isActive;
  final String? customAlarmSound;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Room({
    required this.id,
    required this.name,
    this.description = '',
    this.parentId,
    this.caretakerIds = const [],
    this.isActive = true,
    this.customAlarmSound,
    required this.createdAt,
    this.updatedAt,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      parentId: data['parentId'],
      caretakerIds: List<String>.from(data['caretakerIds'] ?? []),
      isActive: data['isActive'] ?? true,
      customAlarmSound: data['customAlarmSound'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'parentId': parentId,
      'caretakerIds': caretakerIds,
      'isActive': isActive,
      'customAlarmSound': customAlarmSound,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Room copyWith({
    String? id,
    String? name,
    String? description,
    String? parentId,
    List<String>? caretakerIds,
    bool? isActive,
    String? customAlarmSound,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      caretakerIds: caretakerIds ?? this.caretakerIds,
      isActive: isActive ?? this.isActive,
      customAlarmSound: customAlarmSound ?? this.customAlarmSound,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Room(id: $id, name: $name, parentId: $parentId, caretakers: ${caretakerIds.length})';
  }
}
