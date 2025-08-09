import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/models/app_user.dart';
import '../widgets/alarm_button.dart';
import '../widgets/room_card.dart';
import '../providers/parent_provider.dart';

class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final parentState = ref.watch(currentUserParentStateProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Orangtua'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
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
          ref.invalidate(parentProvider);
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

              // Room Selection Section
              _buildRoomSection(
                  parentState, user), // Oper user ke _buildRoomSection
              const Gap(24),

              // Main Alarm Section
              if (parentState.selectedRoom != null) ...[
                _buildAlarmSection(parentState),
                const Gap(24),
              ],

              // Status Section
              _buildStatusSection(),
              const Gap(24),

              // Quick Actions
              _buildQuickActions(),
            ],
          ),
        ),
      ),
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
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.family_restroom,
                color: Color(0xFF2196F3),
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
                  const Text(
                    'Tekan tombol alarm untuk memanggil pengasuh',
                    style: TextStyle(
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

  Widget _buildRoomSection(ParentState parentState, AppUser user) {
    // Tambahkan parameter user
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Kamar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(12),
        if (parentState.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (parentState.userRooms.isEmpty)
          _buildNoRoomsCard()
        else
          _buildRoomsList(
              parentState.userRooms, user), // Oper user ke _buildRoomsList
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
              'Belum ada kamar tersedia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Gap(8),
            Text(
              'Hubungi admin untuk menambahkan kamar dan mengassign pengasuh',
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

  Widget _buildRoomsList(List<dynamic> rooms, AppUser user) {
    // Tambahkan parameter user
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RoomCard(
            room: room,
            onTap: () {
              ref
                  .read(parentProvider(user.id).notifier)
                  .selectRoom(room); // Gunakan user yang diterima
            },
          ),
        );
      },
    );
  }

  Widget _buildAlarmSection(ParentState parentState) {
    final selectedRoom = parentState.selectedRoom;

    if (selectedRoom == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Kamar: ${selectedRoom.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'Pengasuh: ${selectedRoom.caretakerIds.length} orang',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const Gap(24),

            // Main Alarm Button
            AlarmButton(
              isActive: parentState.activeAlarm != null,
              onPressed: () {
                final user = ref.read(currentUserProvider);
                if (user != null) {
                  final notifier = ref.read(parentProvider(user.id).notifier);
                  if (parentState.activeAlarm != null) {
                    notifier.resetAlarm();
                  } else {
                    notifier.triggerAlarm();
                  }
                }
              },
            ),

            if (parentState.activeAlarm != null) ...[
              const Gap(16),
              _buildAlarmStatus(parentState.activeAlarm!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmStatus(dynamic alarm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alarm.isAcknowledged ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              alarm.isAcknowledged ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            alarm.isAcknowledged ? Icons.check_circle : Icons.access_time,
            color:
                alarm.isAcknowledged ? Colors.green[600] : Colors.orange[600],
            size: 32,
          ),
          const Gap(8),
          Text(
            alarm.isAcknowledged ? 'Panggilan Diterima!' : 'Menunggu Respon...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  alarm.isAcknowledged ? Colors.green[600] : Colors.orange[600],
            ),
          ),
          const Gap(4),
          Text(
            alarm.isAcknowledged
                ? 'Pengasuh telah menerima panggilan'
                : 'Alarm sedang berbunyi di perangkat pengasuh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Koneksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(8),
                const Text('Terhubung ke server'),
              ],
            ),
          ],
        ),
      ),
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
                    onPressed: () {
                      // Show alarm history
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Riwayat'),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Show settings
                    },
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
}
