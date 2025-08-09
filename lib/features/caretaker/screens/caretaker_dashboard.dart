import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/models/app_user.dart';
import '../providers/caretaker_provider.dart';
import '../widgets/alarm_notification.dart';
import '../widgets/room_monitor_card.dart';
// ignore: unused_import
import '../widgets/acknowledge_button.dart';

class CaretakerDashboard extends ConsumerStatefulWidget {
  const CaretakerDashboard({super.key});

  @override
  ConsumerState<CaretakerDashboard> createState() => _CaretakerDashboardState();
}

class _CaretakerDashboardState extends ConsumerState<CaretakerDashboard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes for background alarm management
    final caretakerNotifier = ref.read(caretakerProvider.notifier);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        caretakerNotifier.onAppBackground();
        break;
      case AppLifecycleState.resumed:
        caretakerNotifier.onAppForeground();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final caretakerState = ref.watch(caretakerProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Listen for alarm changes and show notifications
    ref.listen<CaretakerState>(caretakerProvider, (previous, next) {
      _handleAlarmChanges(previous, next);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pengasuh'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          // Active alarms indicator
          if (caretakerState.activeAlarms.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_active),
                    onPressed: () => _showAlarmsBottomSheet(),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${caretakerState.activeAlarms.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authProvider.notifier).signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Keluar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(caretakerProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(user),
              const Gap(24),

              // Active Alarms Section (Priority)
              if (caretakerState.activeAlarms.isNotEmpty) ...[
                _buildActiveAlarmsSection(caretakerState.activeAlarms),
                const Gap(24),
              ],

              // Monitored Rooms Section
              _buildMonitoredRoomsSection(caretakerState.assignedRooms),
              const Gap(24),

              // Status Section
              _buildStatusSection(caretakerState),
              const Gap(24),

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),

      // Floating alarm acknowledgment for active alarms
      floatingActionButton: caretakerState.activeAlarms.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _acknowledgeAllAlarms(),
              backgroundColor: Colors.green[600],
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Terima Semua',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildWelcomeCard(AppUser user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.baby_changing_station,
                color: Color(0xFF4CAF50),
                size: 32,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${user.name}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'Monitoring ${user.assignedRooms.length} kamar',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlarmsSection(List<dynamic> activeAlarms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emergency, color: Colors.red, size: 24),
            const Gap(8),
            const Text(
              'Alarm Aktif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${activeAlarms.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Gap(12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activeAlarms.length,
          itemBuilder: (context, index) {
            final alarm = activeAlarms[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AlarmNotification(
                alarm: alarm,
                onAcknowledge: () => _acknowledgeAlarm(alarm),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonitoredRoomsSection(List<dynamic> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kamar yang Dipantau',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(12),
        if (rooms.isEmpty)
          _buildNoRoomsCard()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return RoomMonitorCard(
                room: room,
                hasActiveAlarm: _hasActiveAlarmForRoom(room.id),
                onTap: () => _showRoomDetails(room),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNoRoomsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.home_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const Gap(16),
            const Text(
              'Belum ada kamar yang dipantau',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            Text(
              'Hubungi admin untuk assign kamar yang akan Anda pantau',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(CaretakerState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Sistem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            _buildStatusItem(
              'Koneksi',
              'Terhubung',
              Colors.green,
              Icons.wifi,
            ),
            const Gap(8),
            _buildStatusItem(
              'Notifikasi',
              state.notificationsEnabled ? 'Aktif' : 'Nonaktif',
              state.notificationsEnabled ? Colors.green : Colors.orange,
              Icons.notifications,
            ),
            const Gap(8),
            _buildStatusItem(
              'Audio',
              state.audioEnabled ? 'Aktif' : 'Nonaktif',
              state.audioEnabled ? Colors.green : Colors.orange,
              Icons.volume_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const Gap(8),
        Text('$label: '),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _testAlarm(),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Test Alarm'),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text('Pengaturan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAlarmChanges(CaretakerState? previous, CaretakerState next) {
    // Show notification for new alarms
    if (previous != null) {
      final newAlarms = next.activeAlarms.where((alarm) =>
          !previous.activeAlarms.any((prevAlarm) => prevAlarm.id == alarm.id));

      for (final alarm in newAlarms) {
        _showAlarmNotification(alarm);
      }
    }
  }

  void _showAlarmNotification(dynamic alarm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚨 ALARM: ${alarm.roomName ?? "Kamar ${alarm.roomId}"}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'TERIMA',
          textColor: Colors.white,
          onPressed: () => _acknowledgeAlarm(alarm),
        ),
      ),
    );
  }

  void _acknowledgeAlarm(dynamic alarm) {
    ref.read(caretakerProvider.notifier).acknowledgeAlarm(alarm.id);
  }

  void _acknowledgeAllAlarms() {
    ref.read(caretakerProvider.notifier).acknowledgeAllAlarms();
  }

  bool _hasActiveAlarmForRoom(String roomId) {
    final state = ref.read(caretakerProvider);
    return state.activeAlarms.any((alarm) => alarm.roomId == roomId);
  }

  void _showAlarmsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AlarmsBottomSheet(),
    );
  }

  void _showRoomDetails(dynamic room) {
    showDialog(
      context: context,
      builder: (context) => RoomDetailsDialog(room: room),
    );
  }

  void _testAlarm() {
    ref.read(caretakerProvider.notifier).testAlarm();
  }

  void _showSettings() {
    // Navigate to settings
  }
}

class AlarmsBottomSheet extends ConsumerWidget {
  const AlarmsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAlarms = ref.watch(caretakerProvider).activeAlarms;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Alarm Aktif',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: activeAlarms.length,
            itemBuilder: (context, index) {
              final alarm = activeAlarms[index];
              return AlarmNotification(
                alarm: alarm,
                onAcknowledge: () {
                  ref
                      .read(caretakerProvider.notifier)
                      .acknowledgeAlarm(alarm.id);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class RoomDetailsDialog extends StatelessWidget {
  final dynamic room;

  const RoomDetailsDialog({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(room.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deskripsi: ${room.description}'),
          const Gap(8),
          Text('Status: ${room.isActive ? "Aktif" : "Nonaktif"}'),
          const Gap(8),
          Text('Pengasuh: ${room.caretakerIds.length} orang'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
