import 'package:flutter/material.dart';
import '../../admin/models/room_model.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool hasActiveAlarm;

  const RoomCard({
    super.key,
    required this.room,
    this.onTap,
    this.isSelected = false,
    this.hasActiveAlarm = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: isSelected
                ? Colors.blue[400]!
                : hasActiveAlarm
                    ? Colors.red[400]!
                    : Colors.grey[300]!,
            width: isSelected || hasActiveAlarm ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hasActiveAlarm
                        ? Colors.red[100]
                        : isSelected
                            ? Colors.blue[100]
                            : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasActiveAlarm ? Icons.emergency : Icons.home,
                    color: hasActiveAlarm
                        ? Colors.red[600]
                        : isSelected
                            ? Colors.blue[600]
                            : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              hasActiveAlarm ? Colors.red[700] : Colors.black87,
                        ),
                      ),
                      if (room.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          room.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                if (hasActiveAlarm && !isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ALARM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Room info
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.people,
                  label: '${room.caretakerIds.length} Pengasuh',
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.circle,
                  label: room.isActive ? 'Aktif' : 'Nonaktif',
                  color: room.isActive ? Colors.green : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required MaterialColor color, // Ubah dari Color ke MaterialColor
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color:
                color[600], // Sekarang aman karena color adalah MaterialColor
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color[600], // Sekarang aman
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class RoomGridCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final bool hasActiveAlarm;

  const RoomGridCard({
    super.key,
    required this.room,
    this.onTap,
    this.hasActiveAlarm = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: hasActiveAlarm ? Colors.red[50] : Colors.white,
          border: Border.all(
            color: hasActiveAlarm ? Colors.red[400]! : Colors.grey[300]!,
            width: hasActiveAlarm ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hasActiveAlarm ? Colors.red[100] : Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasActiveAlarm ? Icons.emergency : Icons.home,
                color: hasActiveAlarm ? Colors.red[600] : Colors.blue[600],
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              room.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: hasActiveAlarm ? Colors.red[700] : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${room.caretakerIds.length} pengasuh',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            if (hasActiveAlarm) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ALARM AKTIF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
