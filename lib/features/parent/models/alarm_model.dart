import 'package:cloud_firestore/cloud_firestore.dart';

enum AlarmStatus { inactive, active, acknowledged }

class Alarm {
  final String id;
  final String roomId;
  final String parentId;
  final AlarmStatus status;
  final DateTime triggeredAt;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final String? notes;

  const Alarm({
    required this.id,
    required this.roomId,
    required this.parentId,
    required this.status,
    required this.triggeredAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.notes,
  });

  factory Alarm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Alarm(
      id: doc.id,
      roomId: data['roomId'] ?? '',
      parentId: data['parentId'] ?? '',
      status: AlarmStatus.values.firstWhere(
        (e) => e.toString() == 'AlarmStatus.${data['status']}',
        orElse: () => AlarmStatus.inactive,
      ),
      triggeredAt: (data['triggeredAt'] as Timestamp).toDate(),
      acknowledgedAt: data['acknowledgedAt'] != null
          ? (data['acknowledgedAt'] as Timestamp).toDate()
          : null,
      acknowledgedBy: data['acknowledgedBy'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'parentId': parentId,
      'status': status.name,
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      'acknowledgedAt':
          acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
      'acknowledgedBy': acknowledgedBy,
      'notes': notes,
    };
  }

  Alarm copyWith({
    String? id,
    String? roomId,
    String? parentId,
    AlarmStatus? status,
    DateTime? triggeredAt,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    String? notes,
  }) {
    return Alarm(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      parentId: parentId ?? this.parentId,
      status: status ?? this.status,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      notes: notes ?? this.notes,
    );
  }

  bool get isActive => status == AlarmStatus.active;
  bool get isAcknowledged => status == AlarmStatus.acknowledged;
  bool get isInactive => status == AlarmStatus.inactive;

  String get statusDisplayName {
    switch (status) {
      case AlarmStatus.inactive:
        return 'Tidak Aktif';
      case AlarmStatus.active:
        return 'Alarm Aktif';
      case AlarmStatus.acknowledged:
        return 'Diterima';
    }
  }

  @override
  String toString() {
    return 'Alarm(id: $id, roomId: $roomId, status: $status)';
  }
}
