import 'package:flutter/material.dart';
import '../../shared/models/app_user.dart';

class UserTable extends StatelessWidget {
  final List<AppUser> users;
  final Function(AppUser)? onEditUser;
  final Function(AppUser)? onDeleteUser;
  final Function(AppUser)? onAssignRooms;

  const UserTable({
    super.key,
    required this.users,
    this.onEditUser,
    this.onDeleteUser,
    this.onAssignRooms,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: user.roleColor.withOpacity(0.1),
              child: Icon(
                _getRoleIcon(user.role),
                color: user.roleColor,
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user.roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.roleDisplayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: user.roleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.isActive ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 11,
                          color: user.isActive
                              ? Colors.green[600]
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Email', user.email),
                    _buildInfoRow('Peran', user.roleDisplayName),
                    _buildInfoRow(
                        'Status', user.isActive ? 'Aktif' : 'Nonaktif'),
                    _buildInfoRow(
                      'Kamar yang Dipantau',
                      user.assignedRooms.isEmpty
                          ? 'Belum ada'
                          : '${user.assignedRooms.length} kamar',
                    ),
                    _buildInfoRow(
                      'Bergabung',
                      _formatDate(user.createdAt),
                    ),
                    if (user.lastLogin != null)
                      _buildInfoRow(
                        'Login Terakhir',
                        _formatDate(user.lastLogin!),
                      ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onEditUser?.call(user),
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (user.role == UserRole.caretaker) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => onAssignRooms?.call(user),
                              icon: const Icon(Icons.home, size: 16),
                              label: const Text('Assign'),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => onDeleteUser?.call(user),
                            icon: const Icon(Icons.delete, size: 16),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.parent:
        return Icons.family_restroom;
      case UserRole.caretaker:
        return Icons.baby_changing_station;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
