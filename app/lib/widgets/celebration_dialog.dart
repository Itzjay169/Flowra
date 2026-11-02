/// Celebratory completion dialog with particle animation and session summary.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flowra/utils/theme.dart';

/// Shows a celebratory success dialog when a task or focus/study session completes.
Future<void> showCelebrationDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  int? durationMinutes,
  int? blockedAttempts,
  VoidCallback? onConfirm,
}) {
  HapticFeedback.heavyImpact();
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _CelebrationDialog(
      title: title,
      subtitle: subtitle,
      durationMinutes: durationMinutes,
      blockedAttempts: blockedAttempts,
      onConfirm: onConfirm,
    ),
  );
}

class _CelebrationDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final int? durationMinutes;
  final int? blockedAttempts;
  final VoidCallback? onConfirm;

  const _CelebrationDialog({
    required this.title,
    required this.subtitle,
    this.durationMinutes,
    this.blockedAttempts,
    this.onConfirm,
  });

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Particle effect canvas
          if (!reduceMotion)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _ConfettiPainter(_controller.value),
                ),
              ),
            ),
          // Main Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
            ),
            elevation: 8,
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Trophy / Icon
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppTheme.successGreen,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Metrics Summary Row
                  if (widget.durationMinutes != null ||
                      widget.blockedAttempts != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.durationMinutes != null)
                            Column(
                              children: [
                                Text(
                                  '${widget.durationMinutes}m',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryIndigo,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Focused Time',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          if (widget.blockedAttempts != null)
                            Column(
                              children: [
                                Text(
                                  '${widget.blockedAttempts}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.warningOrange,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Distractions Blocked',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onConfirm?.call();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final Random _rng = Random(42);

  _ConfettiPainter(this.progress);

  static final List<_Particle> _particles = List.generate(40, (i) {
    final angle = _rng.nextDouble() * 2 * pi;
    final speed = 120 + _rng.nextDouble() * 160;
    final color = [
      AppTheme.primaryIndigo,
      AppTheme.successGreen,
      AppTheme.warningOrange,
      Colors.pinkAccent,
      Colors.amber,
      Colors.cyanAccent,
    ][_rng.nextInt(6)];
    final size = 4.0 + _rng.nextDouble() * 5.0;
    return _Particle(angle: angle, speed: speed, color: color, size: size);
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final distance = p.speed * progress;
      final x = center.dx + cos(p.angle) * distance;
      final y = center.dy + sin(p.angle) * distance + (progress * progress * 80);
      final alpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);

      paint.color = p.color.withAlpha(alpha);
      canvas.drawCircle(Offset(x, y), p.size * (1.0 - (progress * 0.5)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}
