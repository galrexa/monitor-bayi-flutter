// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AcknowledgeButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  const AcknowledgeButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text = 'TERIMA PANGGILAN',
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
  });

  @override
  State<AcknowledgeButton> createState() => _AcknowledgeButtonState();
}

class _AcknowledgeButtonState extends State<AcknowledgeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? 56,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.backgroundColor ?? Colors.green[600],
                  foregroundColor: widget.foregroundColor ?? Colors.white,
                  elevation: 4,
                  shadowColor: Colors.green.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuickAcknowledgeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String roomName;

  const QuickAcknowledgeButton({
    super.key,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green[600],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              roomName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingAcknowledgeButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final int alarmCount;

  const FloatingAcknowledgeButton({
    super.key,
    this.onPressed,
    required this.alarmCount,
  });

  @override
  State<FloatingAcknowledgeButton> createState() =>
      _FloatingAcknowledgeButtonState();
}

class _FloatingAcknowledgeButtonState extends State<FloatingAcknowledgeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: widget.onPressed,
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.check_circle),
            label: Text(
              'Terima ${widget.alarmCount} Alarm',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
