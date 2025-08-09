import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/models/app_user.dart';
import '../providers/admin_provider.dart';
import '../widgets/user_table.dart';
import '../widgets/room_form.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final adminState = ref.watch(adminProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pengguna', icon: Icon(Icons.people)),
            Tab(text: 'Kamar', icon: Icon(Icons.home)),
            Tab(text: 'Statistik', icon: Icon(Icons.analytics)),
          ],
        ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(adminState),
          _buildRoomsTab(adminState),
          _buildStatsTab(adminState),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AdminState state) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Total Pengguna',
                    '${state.users.length}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _buildStatsCard(
                    'Pengasuh',
                    '${state.users.where((u) => u.role == UserRole.caretaker).length}',
                    Icons.baby_changing_station,
                    Colors.green,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _buildStatsCard(
                    'Orangtua',
                    '${state.users.where((u) => u.role == UserRole.parent).length}',
                    Icons.family_restroom,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Add user button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.person_add),
                label: const Text('Tambah Pengguna'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const Gap(16),

            // Users list
            const Text(
              'Daftar Pengguna',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),

            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.users.isEmpty)
              const Center(
                child: Text('Belum ada pengguna'),
              )
            else
              UserTable(
                users: state.users,
                onEditUser: (user) => _showEditUserDialog(user),
                onDeleteUser: (user) => _showDeleteUserDialog(user),
                onAssignRooms: (user) => _showAssignRoomsDialog(user),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsTab(AdminState state) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stats
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    'Total Kamar',
                    '${state.rooms.length}',
                    Icons.home,
                    Colors.blue,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: _buildStatsCard(
                    'Aktif',
                    '${state.rooms.where((r) => r.isActive).length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const Gap(24),

            // Add room button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddRoomDialog(),
                icon: const Icon(Icons.add_home),
                label: const Text('Tambah Kamar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const Gap(16),

            // Rooms list
            const Text(
              'Daftar Kamar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(12),

            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.rooms.isEmpty)
              const Center(
                child: Text('Belum ada kamar'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final room = state.rooms[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: room.isActive
                            ? Colors.green[100]
                            : Colors.grey[100],
                        child: Icon(
                          Icons.home,
                          color: room.isActive
                              ? Colors.green[600]
                              : Colors.grey[600],
                        ),
                      ),
                      title: Text(room.name),
                      subtitle: Text(
                        '${room.caretakerIds.length} pengasuh • ${room.isActive ? "Aktif" : "Nonaktif"}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _showEditRoomDialog(room);
                              break;
                            case 'delete':
                              _showDeleteRoomDialog(room);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab(AdminState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistik Sistem',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),

          // System stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  _buildStatRow('Pengasuh Aktif',
                      '${state.users.where((u) => u.role == UserRole.caretaker && u.isActive).length}'),
                  _buildStatRow('Orangtua Terdaftar',
                      '${state.users.where((u) => u.role == UserRole.parent).length}'),
                ],
              ),
            ),
          ),
          const Gap(16),

          // Quick actions
          Card(
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
                        child: ElevatedButton.icon(
                          onPressed: () => _exportData(),
                          icon: const Icon(Icons.download),
                          label: const Text('Export Data'),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showSystemSettings(),
                          icon: const Icon(Icons.settings),
                          label: const Text('Pengaturan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const Gap(8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        onSave: (name, email, role) {
          ref.read(adminProvider.notifier).createUser(name, email, role);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onSave: (updatedUser) {
          ref.read(adminProvider.notifier).updateUser(updatedUser);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteUserDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Yakin ingin menghapus ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminProvider.notifier).deleteUser(user.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAssignRoomsDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (context) => AssignRoomsDialog(
        user: user,
        availableRooms: ref.read(adminProvider).rooms,
        onSave: (roomIds) {
          ref.read(adminProvider.notifier).assignUserToRooms(user.id, roomIds);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => RoomForm(
        onSave: (name, description) {
          ref.read(adminProvider.notifier).createRoom(name, description);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditRoomDialog(dynamic room) {
    showDialog(
      context: context,
      builder: (context) => RoomForm(
        room: room,
        onSave: (name, description) {
          ref
              .read(adminProvider.notifier)
              .updateRoom(room.id, name, description);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteRoomDialog(dynamic room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kamar'),
        content: Text('Yakin ingin menghapus ${room.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminProvider.notifier).deleteRoom(room.id);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    // Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur export data belum tersedia')),
    );
  }

  void _showSystemSettings() {
    // Implement system settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur pengaturan sistem belum tersedia')),
    );
  }
}

// Dialog widgets
class AddUserDialog extends StatefulWidget {
  final Function(String name, String email, UserRole role) onSave;

  const AddUserDialog({super.key, required this.onSave});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserRole _selectedRole = UserRole.parent;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Pengguna'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama'),
          ),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const Gap(16),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            decoration: const InputDecoration(labelText: 'Peran'),
            items: UserRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              _nameController.text,
              _emailController.text,
              _selectedRole,
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final AppUser user;
  final Function(AppUser) onSave;

  const EditUserDialog({super.key, required this.user, required this.onSave});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _nameController;
  late UserRole _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Pengguna'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nama'),
          ),
          const Gap(16),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            decoration: const InputDecoration(labelText: 'Peran'),
            items: UserRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Aktif'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(widget.user.copyWith(
              name: _nameController.text,
              role: _selectedRole,
              isActive: _isActive,
            ));
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class AssignRoomsDialog extends StatefulWidget {
  final AppUser user;
  final List<dynamic> availableRooms;
  final Function(List<String>) onSave;

  const AssignRoomsDialog({
    super.key,
    required this.user,
    required this.availableRooms,
    required this.onSave,
  });

  @override
  State<AssignRoomsDialog> createState() => _AssignRoomsDialogState();
}

class _AssignRoomsDialogState extends State<AssignRoomsDialog> {
  late List<String> _selectedRoomIds;

  @override
  void initState() {
    super.initState();
    _selectedRoomIds = List.from(widget.user.assignedRooms);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Kamar - ${widget.user.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.availableRooms.length,
          itemBuilder: (context, index) {
            final room = widget.availableRooms[index];
            return CheckboxListTile(
              title: Text(room.name),
              subtitle: Text(room.description),
              value: _selectedRoomIds.contains(room.id),
              onChanged: (selected) {
                setState(() {
                  if (selected!) {
                    _selectedRoomIds.add(room.id);
                  } else {
                    _selectedRoomIds.remove(room.id);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => widget.onSave(_selectedRoomIds),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

extension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.parent:
        return 'Orangtua';
      case UserRole.caretaker:
        return 'Pengasuh';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
