import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlarmButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AlarmButton({
    super.key,
    required this.isActive,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<AlarmButton> createState() => _AlarmButtonState();
}

class _AlarmButtonState extends State<AlarmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AlarmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.heavyImpact();
          if (!widget.isActive) {
            setState(() {});
          }
        },
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isActive
                  ? _pulseAnimation.value
                  : _scaleAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: widget.isActive
                        ? [
                            Colors.red[400]!,
                            Colors.red[600]!,
                            Colors.red[800]!,
                          ]
                        : [
                            const Color(0xFFE53935),
                            const Color(0xFFD32F2F),
                            const Color(0xFFB71C1C),
                          ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isActive
                          ? Colors.red.withOpacity(0.4)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: widget.isActive ? 20 : 15,
                      spreadRadius: widget.isActive ? 5 : 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring animation for active state
                    if (widget.isActive)
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),

                    // Inner content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isActive ? Icons.stop : Icons.emergency,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isActive ? 'STOP' : 'ALARM',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        if (widget.isLoading) ...[
                          const SizedBox(height: 8),
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SmallAlarmButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback? onPressed;
  final String roomName;

  const SmallAlarmButton({
    super.key,
    required this.isActive,
    this.onPressed,
    required this.roomName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.red[600] : Colors.red[400],
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: isActive ? 15 : 8,
              spreadRadius: isActive ? 3 : 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.stop : Icons.emergency,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              roomName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
