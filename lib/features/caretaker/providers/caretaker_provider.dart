// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/notification_service.dart';
import '../../shared/models/app_user.dart';
import '../../admin/models/room_model.dart';
import '../../parent/models/alarm_model.dart';
import '../../auth/providers/auth_provider.dart';

class CaretakerState {
  final List<Room> assignedRooms;
  final List<Alarm> activeAlarms;
  final bool isLoading;
  final bool notificationsEnabled;
  final bool audioEnabled;
  final String? error;

  const CaretakerState({
    this.assignedRooms = const [],
    this.activeAlarms = const [],
    this.isLoading = false,
    this.notificationsEnabled = true,
    this.audioEnabled = true,
    this.error,
  });

  CaretakerState copyWith({
    List<Room>? assignedRooms,
    List<Alarm>? activeAlarms,
    bool? isLoading,
    bool? notificationsEnabled,
    bool? audioEnabled,
    String? error,
  }) {
    return CaretakerState(
      assignedRooms: assignedRooms ?? this.assignedRooms,
      activeAlarms: activeAlarms ?? this.activeAlarms,
      isLoading: isLoading ?? this.isLoading,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      error: error,
    );
  }

  bool get hasActiveAlarms => activeAlarms.isNotEmpty;
  int get activeAlarmCount => activeAlarms.length;
}

class CaretakerNotifier extends StateNotifier<CaretakerState> {
  CaretakerNotifier(this._userId)
      : super(const CaretakerState(isLoading: true)) {
    _initialize();
  }

  final String _userId;

  void _initialize() {
    _loadAssignedRooms();
    _listenToAlarms();
  }

  void _loadAssignedRooms() {
    FirebaseService.getUserRoomsStream(_userId, UserRole.caretaker).listen(
      (rooms) {
        state = state.copyWith(
          assignedRooms: rooms,
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

  void _listenToAlarms() {
    FirebaseService.getAlarmsForCaretakerStream(_userId).listen(
      (alarms) {
        final previousAlarms = state.activeAlarms;
        state = state.copyWith(activeAlarms: alarms);

        // Handle new alarms
        _handleNewAlarms(previousAlarms, alarms);

        // Handle alarm audio
        _handleAlarmAudio(alarms);
      },
      onError: (error) {
        print('Error listening to alarms: $error');
      },
    );
  }

  void _handleNewAlarms(List<Alarm> previousAlarms, List<Alarm> newAlarms) {
    // Find truly new alarms (not just updates)
    final newAlarmIds = newAlarms.map((a) => a.id).toSet();
    final previousAlarmIds = previousAlarms.map((a) => a.id).toSet();
    final addedAlarmIds = newAlarmIds.difference(previousAlarmIds);

    for (final alarmId in addedAlarmIds) {
      final alarm = newAlarms.firstWhere((a) => a.id == alarmId);
      _triggerAlarmNotification(alarm);
    }
  }

  void _handleAlarmAudio(List<Alarm> alarms) {
    if (!state.audioEnabled) return;

    if (alarms.isNotEmpty) {
      // Play alarm sound for active alarms
      _playAlarmSound();
    } else {
      // Stop alarm sound when no active alarms
      AudioService.stopAlarm();
    }
  }

  Future<void> _triggerAlarmNotification(Alarm alarm) async {
    if (!state.notificationsEnabled) return;

    // Get room info for better notification
    final room = state.assignedRooms.firstWhere(
      (r) => r.id == alarm.roomId,
      orElse: () => Room(
        id: alarm.roomId,
        name: 'Kamar ${alarm.roomId}',
        createdAt: DateTime.now(),
      ),
    );

    // Show local notification
    await NotificationService.showLocalNotification(
      title: '🚨 Baby Monitor Alarm',
      body: 'Panggilan dari ${room.name}!',
      payload: alarm.id,
    );
  }

  Future<void> _playAlarmSound() async {
    if (!state.audioEnabled) return;

    try {
      // Find custom alarm sound if available
      String? customSound;
      for (final alarm in state.activeAlarms) {
        final room = state.assignedRooms.firstWhere(
          (r) => r.id == alarm.roomId,
          orElse: () => Room(id: '', name: '', createdAt: DateTime.now()),
        );
        if (room.customAlarmSound != null) {
          customSound = room.customAlarmSound;
          break;
        }
      }

      await AudioService.playAlarm(customSound: customSound);
    } catch (e) {
      print('Error playing alarm sound: $e');
    }
  }

  Future<void> acknowledgeAlarm(String alarmId) async {
    try {
      await FirebaseService.acknowledgeAlarm(
        alarmId: alarmId,
        acknowledgedBy: _userId,
      );

      // Remove from local state immediately for better UX
      final updatedAlarms =
          state.activeAlarms.where((alarm) => alarm.id != alarmId).toList();

      state = state.copyWith(activeAlarms: updatedAlarms);

      // Stop alarm sound if no more active alarms
      if (updatedAlarms.isEmpty) {
        AudioService.stopAlarm();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> acknowledgeAllAlarms() async {
    final alarmIds = state.activeAlarms.map((a) => a.id).toList();

    for (final alarmId in alarmIds) {
      try {
        await FirebaseService.acknowledgeAlarm(
          alarmId: alarmId,
          acknowledgedBy: _userId,
        );
      } catch (e) {
        print('Error acknowledging alarm $alarmId: $e');
      }
    }

    // Clear all alarms locally
    state = state.copyWith(activeAlarms: []);
    AudioService.stopAlarm();
  }

  Future<void> testAlarm() async {
    if (!state.audioEnabled) return;

    try {
      await AudioService.testSound('audio/default_alarm.mp3');
    } catch (e) {
      state = state.copyWith(error: 'Gagal test alarm: $e');
    }
  }

  void toggleNotifications() {
    state = state.copyWith(
      notificationsEnabled: !state.notificationsEnabled,
    );
  }

  void toggleAudio() {
    state = state.copyWith(
      audioEnabled: !state.audioEnabled,
    );

    // Stop current alarm if audio disabled
    if (!state.audioEnabled) {
      AudioService.stopAlarm();
    } else if (state.hasActiveAlarms) {
      _playAlarmSound();
    }
  }

  void onAppBackground() {
    // Handle app going to background
    // Keep audio playing for alarms
    print('App went to background - alarms: ${state.activeAlarmCount}');
  }

  void onAppForeground() {
    // Handle app coming to foreground
    // Refresh state and check for missed alarms
    print('App came to foreground - refreshing state');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    // Stop any playing alarms when disposing
    AudioService.stopAlarm();
    super.dispose();
  }
}

final caretakerProvider =
    StateNotifierProvider<CaretakerNotifier, CaretakerState>((ref) {
  final user = ref.watch(authProvider).appUser;
  if (user?.role == UserRole.caretaker) {
    return CaretakerNotifier(user!.id);
  }
  throw Exception('Invalid user role for caretaker provider');
});

// Helper providers
final activeAlarmsProvider = Provider<List<Alarm>>((ref) {
  return ref.watch(caretakerProvider).activeAlarms;
});

final hasActiveAlarmsProvider = Provider<bool>((ref) {
  return ref.watch(caretakerProvider).hasActiveAlarms;
});

final assignedRoomsProvider = Provider<List<Room>>((ref) {
  return ref.watch(caretakerProvider).assignedRooms;
});
