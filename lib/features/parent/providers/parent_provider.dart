import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../shared/models/app_user.dart';
import '../../admin/models/room_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/alarm_model.dart';

class ParentState {
  final List<Room> userRooms;
  final Room? selectedRoom;
  final Alarm? activeAlarm;
  final bool isLoading;
  final String? error;

  const ParentState({
    this.userRooms = const [],
    this.selectedRoom,
    this.activeAlarm,
    this.isLoading = false,
    this.error,
  });

  ParentState copyWith({
    List<Room>? userRooms,
    Room? selectedRoom,
    Alarm? activeAlarm,
    bool? isLoading,
    String? error,
  }) {
    return ParentState(
      userRooms: userRooms ?? this.userRooms,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      activeAlarm: activeAlarm ?? this.activeAlarm,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ParentNotifier extends StateNotifier<ParentState> {
  ParentNotifier(this._userId) : super(const ParentState(isLoading: true)) {
    _initialize();
  }

  final String _userId;

  void _initialize() {
    _loadUserRooms();
  }

  void _loadUserRooms() {
    FirebaseService.getUserRoomsStream(_userId, UserRole.parent).listen(
      (rooms) {
        state = state.copyWith(
          userRooms: rooms,
          isLoading: false,
          error: null,
        );

        // Auto-select first room if available and none selected
        if (rooms.isNotEmpty && state.selectedRoom == null) {
          selectRoom(rooms.first);
        }
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  void selectRoom(Room room) {
    state = state.copyWith(selectedRoom: room);
    _listenToActiveAlarm(room.id);
  }

  void _listenToActiveAlarm(String roomId) {
    FirebaseService.getActiveAlarmStream(roomId).listen(
      (alarm) {
        state = state.copyWith(activeAlarm: alarm);
      },
      onError: (error) {
        // ignore: avoid_print
        print('Error listening to alarm: $error');
      },
    );
  }

  Future<void> triggerAlarm() async {
    if (state.selectedRoom == null) {
      state = state.copyWith(error: 'Pilih kamar terlebih dahulu');
      return;
    }

    try {
      await FirebaseService.triggerAlarm(
        roomId: state.selectedRoom!.id,
        parentId: _userId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetAlarm() async {
    if (state.activeAlarm == null) return;

    try {
      await FirebaseService.resetAlarm(state.activeAlarm!.id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final parentProvider =
    StateNotifierProvider.family<ParentNotifier, ParentState, String>(
  (ref, userId) => ParentNotifier(userId),
);

// Helper provider that automatically gets current user's rooms
final currentUserParentProvider = Provider<ParentNotifier?>((ref) {
  final user = ref.watch(authProvider).appUser;
  if (user?.role == UserRole.parent) {
    return ref.watch(parentProvider(user!.id).notifier);
  }
  return null;
});

// Provider for current user's parent state
final currentUserParentStateProvider = Provider<ParentState>((ref) {
  final user = ref.watch(authProvider).appUser;
  if (user?.role == UserRole.parent) {
    return ref.watch(parentProvider(user!.id));
  }
  return const ParentState();
});
