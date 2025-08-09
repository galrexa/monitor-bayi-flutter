import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/firebase_service.dart';
import '../../shared/models/app_user.dart';
import '../models/room_model.dart';

class AdminState {
  final List<AppUser> users;
  final List<Room> rooms;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.users = const [],
    this.rooms = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<AppUser>? users,
    List<Room>? rooms,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      users: users ?? this.users,
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier() : super(const AdminState(isLoading: true)) {
    _initialize();
  }

  void _initialize() {
    _loadUsers();
    _loadRooms();
  }

  void _loadUsers() {
    FirebaseService.getUsersStream().listen(
      (users) {
        state = state.copyWith(
          users: users,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  void _loadRooms() {
    FirebaseService.getRoomsStream().listen(
      (rooms) {
        state = state.copyWith(
          rooms: rooms,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
        );
      },
    );
  }

  Future<void> createUser(String name, String email, UserRole role) async {
    try {
      // Create Firebase Auth user with temporary password
      final credential = await FirebaseService.signUp(email, 'temp123456');

      // Create user profile
      final user = AppUser(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      await FirebaseService.createUser(user);

      // Note: In production, you'd want to send password reset email
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await FirebaseService.updateUser(user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Note: This only deletes the Firestore document
      // Firebase Auth user deletion requires additional setup
      final userRef = FirebaseService.firestore
          .collection(FirebaseService.usersCollection)
          .doc(userId);
      await userRef.delete();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> assignUserToRooms(String userId, List<String> roomIds) async {
    try {
      final user = state.users.firstWhere((u) => u.id == userId);
      final updatedUser = user.copyWith(assignedRooms: roomIds);
      await FirebaseService.updateUser(updatedUser);

      // Also update rooms to include this user in caretaker list
      if (user.role == UserRole.caretaker) {
        for (final roomId in roomIds) {
          final room = state.rooms.firstWhere((r) => r.id == roomId);
          final updatedCaretakers = [...room.caretakerIds];
          if (!updatedCaretakers.contains(userId)) {
            updatedCaretakers.add(userId);
          }

          final updatedRoom = room.copyWith(caretakerIds: updatedCaretakers);
          await FirebaseService.updateRoom(updatedRoom);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createRoom(String name, String description) async {
    try {
      const uuid = Uuid();
      final room = Room(
        id: uuid.v4(),
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      await FirebaseService.createRoom(room);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateRoom(
      String roomId, String name, String description) async {
    try {
      final room = state.rooms.firstWhere((r) => r.id == roomId);
      final updatedRoom = room.copyWith(
        name: name,
        description: description,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.updateRoom(updatedRoom);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await FirebaseService.deleteRoom(roomId);

      // Remove room from all users' assigned rooms
      for (final user in state.users) {
        if (user.assignedRooms.contains(roomId)) {
          final updatedRooms =
              user.assignedRooms.where((id) => id != roomId).toList();
          final updatedUser = user.copyWith(assignedRooms: updatedRooms);
          await FirebaseService.updateUser(updatedUser);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> assignParentToRoom(String parentId, String roomId) async {
    try {
      final room = state.rooms.firstWhere((r) => r.id == roomId);
      final updatedRoom = room.copyWith(parentId: parentId);
      await FirebaseService.updateRoom(updatedRoom);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier();
});
