import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'question_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _glowAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background orbs
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _BackgroundOrbsPainter(
                  animValue: _floatController.value,
                  primaryColor: cs.primary,
                  secondaryColor: cs.secondary,
                ),
              );
            },
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing icon
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (context, child) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.secondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary
                                      .withValues(alpha: 0.5 * _glowAnim.value),
                                  blurRadius: 40 * _glowAnim.value,
                                  spreadRadius: 10 * _glowAnim.value,
                                ),
                                BoxShadow(
                                  color: cs.secondary
                                      .withValues(alpha: 0.3 * _glowAnim.value),
                                  blurRadius: 60 * _glowAnim.value,
                                  spreadRadius: 5 * _glowAnim.value,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: const Icon(
                          Icons.bolt_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Gradient title text
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [cs.primary, cs.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Flutter\nQuiz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Subtitle pill
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          'Uji Pengetahuan Animasi Flutter-mu',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats pills row
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _StatPill(
                            icon: Icons.quiz_rounded,
                            label: '7 Soal',
                            color: cs.primary,
                          ),
                          const SizedBox(width: 10),
                          _StatPill(
                            icon: Icons.timer_outlined,
                            label: '~5 Menit',
                            color: cs.secondary,
                          ),
                          const SizedBox(width: 10),
                          const _StatPill(
                            icon: Icons.star_rounded,
                            label: 'Bonus XP',
                            color: Color(0xFFF59E0B),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 52),

                  // Glow CTA button
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: _GlowButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                              ) => const QuestionScreen(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return FadeThroughTransition(
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        label: 'Mulai Kuis',
                        icon: Icons.rocket_launch_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bottom hint text
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Text(
                      '⚡ Dibuat dengan Flutter Advanced Animations',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 11,
                        letterSpacing: 0.3,
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

/// Pill chip untuk statistik di home screen
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol dengan efek glow neon saat ditekan
class _GlowButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const _GlowButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _glow;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() => _pressed = true);
            _ctrl.forward();
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            _ctrl.reverse();
            widget.onPressed();
          },
          onTapCancel: () {
            setState(() => _pressed = false);
            _ctrl.reverse();
          },
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.secondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withValues(
                      alpha: 0.4 + 0.2 * _glow.value,
                    ),
                    blurRadius: 24 + 12 * _glow.value,
                    spreadRadius: 2 + 4 * _glow.value,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: cs.secondary.withValues(
                      alpha: 0.2 + 0.15 * _glow.value,
                    ),
                    blurRadius: 40 + 20 * _glow.value,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 24),
                  const SizedBox(width: 14),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Painter untuk background orbs yang mengambang & bergerak
class _BackgroundOrbsPainter extends CustomPainter {
  final double animValue;
  final Color primaryColor;
  final Color secondaryColor;

  _BackgroundOrbsPainter({
    required this.animValue,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Orb 1 - kanan atas (violet besar)
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.82 + 30 * math.sin(animValue * math.pi),
        size.height * 0.12 + 25 * math.cos(animValue * math.pi),
      ),
      180,
      primaryColor.withValues(alpha: 0.25),
    );

    // Orb 2 - kiri bawah (cyan besar)
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.08 + 20 * math.cos(animValue * math.pi),
        size.height * 0.82 + 30 * math.sin(animValue * math.pi),
      ),
      220,
      secondaryColor.withValues(alpha: 0.15),
    );

    // Orb 3 - tengah kiri (violet kecil)
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.15 + 15 * math.sin(animValue * math.pi * 1.4),
        size.height * 0.42 + 20 * math.cos(animValue * math.pi * 1.4),
      ),
      110,
      primaryColor.withValues(alpha: 0.1),
    );

    // Orb 4 - kiri atas (cyan kecil)
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.04 + 10 * math.cos(animValue * math.pi * 0.8),
        size.height * 0.08 + 10 * math.sin(animValue * math.pi * 0.8),
      ),
      90,
      secondaryColor.withValues(alpha: 0.18),
    );

    // Orb 5 - tengah kanan (gold kecil)
    _drawOrb(
      canvas,
      Offset(
        size.width * 0.88 + 12 * math.sin(animValue * math.pi * 1.2),
        size.height * 0.5 + 15 * math.cos(animValue * math.pi * 1.2),
      ),
      70,
      const Color(0xFFF59E0B).withValues(alpha: 0.12),
    );
  }

  void _drawOrb(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_BackgroundOrbsPainter old) =>
      old.animValue != animValue;
}
