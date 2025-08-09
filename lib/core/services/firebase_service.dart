import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../features/shared/models/app_user.dart';
import '../../features/admin/models/room_model.dart';
import '../../features/parent/models/alarm_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String roomsCollection = 'rooms';
  static const String alarmsCollection = 'alarms';

  // Public getter for Firestore instance
  static FirebaseFirestore get firestore => _firestore;

  // Authentication
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Management
  static Future<void> createUser(AppUser user) async {
    await _firestore
        .collection(usersCollection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  static Future<AppUser?> getUser(String userId) async {
    try {
      final doc =
          await _firestore.collection(usersCollection).doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return AppUser.fromFirestore(doc);
      }

      print('User document not found or empty for ID: $userId');
      return null;
    } catch (e) {
      print('Error getting user $userId: $e');
      return null;
    }
  }

  static Future<void> updateUser(AppUser user) async {
    await _firestore
        .collection(usersCollection)
        .doc(user.id)
        .update(user.toFirestore());
  }

  static Stream<List<AppUser>> getUsersStream() {
    return _firestore.collection(usersCollection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  static Stream<List<AppUser>> getCaretakersStream() {
    return _firestore
        .collection(usersCollection)
        .where('role', isEqualTo: 'caretaker')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  // Room Management
  static Future<void> createRoom(Room room) async {
    await _firestore
        .collection(roomsCollection)
        .doc(room.id)
        .set(room.toFirestore());
  }

  static Future<void> updateRoom(Room room) async {
    await _firestore
        .collection(roomsCollection)
        .doc(room.id)
        .update(room.toFirestore());
  }

  static Future<void> deleteRoom(String roomId) async {
    await _firestore.collection(roomsCollection).doc(roomId).delete();
  }

  static Stream<List<Room>> getRoomsStream() {
    return _firestore
        .collection(roomsCollection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
  }

  static Stream<List<Room>> getUserRoomsStream(String userId, UserRole role) {
    Query query = _firestore
        .collection(roomsCollection)
        .where('isActive', isEqualTo: true);

    if (role == UserRole.parent) {
      query = query.where('parentId', isEqualTo: userId);
    } else if (role == UserRole.caretaker) {
      query = query.where('caretakerIds', arrayContains: userId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
  }

  // Alarm Management
  static Future<String> createAlarm(Alarm alarm) async {
    final docRef =
        await _firestore.collection(alarmsCollection).add(alarm.toFirestore());
    return docRef.id;
  }

  static Future<void> updateAlarm(Alarm alarm) async {
    await _firestore
        .collection(alarmsCollection)
        .doc(alarm.id)
        .update(alarm.toFirestore());
  }

  static Stream<Alarm?> getActiveAlarmStream(String roomId) {
    return _firestore
        .collection(alarmsCollection)
        .where('roomId', isEqualTo: roomId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return Alarm.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  static Stream<List<Alarm>> getAlarmsForCaretakerStream(String userId) {
    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .snapshots()
        .asyncExpand((userDoc) {
      if (!userDoc.exists) return Stream.value([]);

      final user = AppUser.fromFirestore(userDoc);
      if (user.assignedRooms.isEmpty) return Stream.value([]);

      return _firestore
          .collection(alarmsCollection)
          .where('roomId', whereIn: user.assignedRooms)
          .where('status', isEqualTo: 'active')
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Alarm.fromFirestore(doc)).toList());
    });
  }

  // Real-time alarm trigger
  static Future<void> triggerAlarm({
    required String roomId,
    required String parentId,
  }) async {
    // First, deactivate any existing alarms for this room
    final existingAlarms = await _firestore
        .collection(alarmsCollection)
        .where('roomId', isEqualTo: roomId)
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in existingAlarms.docs) {
      await doc.reference.update({'status': 'inactive'});
    }

    // Create new alarm
    final alarm = Alarm(
      id: '',
      roomId: roomId,
      parentId: parentId,
      status: AlarmStatus.active,
      triggeredAt: DateTime.now(),
    );

    await createAlarm(alarm);
  }

  static Future<void> acknowledgeAlarm({
    required String alarmId,
    required String acknowledgedBy,
  }) async {
    await _firestore.collection(alarmsCollection).doc(alarmId).update({
      'status': 'acknowledged',
      'acknowledgedAt': Timestamp.fromDate(DateTime.now()),
      'acknowledgedBy': acknowledgedBy,
    });
  }

  static Future<void> resetAlarm(String alarmId) async {
    await _firestore
        .collection(alarmsCollection)
        .doc(alarmId)
        .update({'status': 'inactive'});
  }

  // FCM Token Management (disabled for web development)
  static Future<void> updateUserFCMToken(String userId) async {
    try {
      // Skip FCM on web development
      if (kIsWeb) {
        print('Skipping FCM token update on web');
        return;
      }

      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore
            .collection(usersCollection)
            .doc(userId)
            .update({'fcmToken': token});
      }
    } catch (e) {
      print('Error updating FCM token: $e');
      // Don't throw error, just log it
    }
  }
}
