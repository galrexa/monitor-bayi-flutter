import 'package:flutter/material.dart';
import '../../admin/models/room_model.dart';

class RoomMonitorCard extends StatelessWidget {
  final Room room;
  final bool hasActiveAlarm;
  final VoidCallback? onTap;

  const RoomMonitorCard({
    super.key,
    required this.room,
    this.hasActiveAlarm = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: hasActiveAlarm ? Colors.red[50] : Colors.white,
          border: Border.all(
            color: hasActiveAlarm ? Colors.red[400]! : Colors.grey[300]!,
            width: hasActiveAlarm ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: hasActiveAlarm
                  ? Colors.red.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: hasActiveAlarm ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status indicator and icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: hasActiveAlarm ? Colors.red[100] : Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasActiveAlarm ? Icons.emergency : Icons.home,
                    color: hasActiveAlarm ? Colors.red[600] : Colors.green[600],
                    size: 28,
                  ),
                ),

                // Pulsing animation for active alarm
                if (hasActiveAlarm)
                  Positioned.fill(
                    child: _PulsingCircle(
                      color: Colors.red[400]!,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Room name
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

            // Room description
            if (room.description.isNotEmpty)
              Text(
                room.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 8),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: hasActiveAlarm ? Colors.red[600] : Colors.green[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasActiveAlarm ? 'ALARM!' : 'Normal',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingCircle extends StatefulWidget {
  final Color color;

  const _PulsingCircle({required this.color});

  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.color.withOpacity(_opacityAnimation.value),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RoomStatusCard extends StatelessWidget {
  final Room room;
  final String status;
  final Color statusColor;
  final VoidCallback? onTap;

  const RoomStatusCard({
    super.key,
    required this.room,
    required this.status,
    required this.statusColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            Icons.home,
            color: statusColor,
          ),
        ),
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(room.description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
