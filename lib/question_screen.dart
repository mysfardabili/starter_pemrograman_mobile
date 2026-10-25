import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'flip_effect.dart';
import 'view_model.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final QuizViewModel viewModel = QuizViewModel(
    onGameOver: _handleGameOver,
  );
  VoidCallback? _showGameOverScreen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: const Text(
              'Kuis Animasi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AnimatedOpacity(
                  opacity:
                      viewModel.hasNextQuestion && viewModel.didAnswerQuestion
                          ? 1.0
                          : 0.3,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap:
                        viewModel.hasNextQuestion && viewModel.didAnswerQuestion
                            ? () => viewModel.getNextQuestion()
                            : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              color: cs.secondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: cs.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Space for AppBar
                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.top +
                            kToolbarHeight +
                            12,
                      ),

                      // Progress bar neon
                      _NeonProgressBar(viewModel: viewModel),
                      const SizedBox(height: 16),

                      // Question card with OpenContainer transition
                      PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 350),
                        layoutBuilder: (entries) {
                          return Stack(
                            alignment: Alignment.topCenter,
                            children: entries,
                          );
                        },
                        transitionBuilder: (
                          child,
                          animation,
                          secondaryAnimation,
                        ) {
                          return FadeThroughTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            child: child,
                          );
                        },
                        child: QuestionCard(
                          key: ValueKey(viewModel.currentQuestion?.question),
                          question: viewModel.currentQuestion?.question,
                          viewModel: viewModel,
                          onChangeOpenContainer: _handleChangeOpenContainer,
                          questionNumber: viewModel.answeredQuestionCount,
                          totalQuestions: viewModel.totalQuestions,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Answer cards 2x2 grid
                      AnswerCards(
                        onTapped: (index) => viewModel.checkAnswer(index),
                        answers:
                            viewModel.currentQuestion?.possibleAnswers ?? [],
                        correctAnswer:
                            viewModel.didAnswerQuestion
                                ? viewModel.currentQuestion?.correctAnswer
                                : null,
                        selectedAnswer: viewModel.selectedAnswer,
                      ),

                      const SizedBox(height: 12),

                      // Status bar at bottom
                      StatusBar(viewModel: viewModel),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _handleChangeOpenContainer(VoidCallback openContainer) {
    _showGameOverScreen = openContainer;
  }

  void _handleGameOver() {
    if (_showGameOverScreen != null) {
      _showGameOverScreen!();
    }
  }
}

// ─────────────────────────────────────────────
// Neon progress bar di bagian atas
// ─────────────────────────────────────────────
class _NeonProgressBar extends StatelessWidget {
  final QuizViewModel viewModel;

  const _NeonProgressBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress =
        viewModel.answeredQuestionCount / viewModel.totalQuestions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soal ${viewModel.answeredQuestionCount} dari ${viewModel.totalQuestions}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: progress),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                builder: (context, value, _) {
                  return Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: cs.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            builder: (context, value, _) {
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.secondary],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: cs.secondary.withValues(alpha: 0.7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Kartu soal dengan glassmorphism + OpenContainer
// ─────────────────────────────────────────────
class QuestionCard extends StatelessWidget {
  final String? question;
  final QuizViewModel viewModel;
  final ValueChanged<VoidCallback> onChangeOpenContainer;
  final int questionNumber;
  final int totalQuestions;

  const QuestionCard({
    required this.question,
    required this.viewModel,
    required this.onChangeOpenContainer,
    required this.questionNumber,
    required this.totalQuestions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: OpenContainer(
        key: ValueKey(question),
        tappable: false,
        closedElevation: 0,
        closedColor: const Color(0xFF0A0F1E),
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        closedBuilder: (context, openContainer) {
          onChangeOpenContainer(openContainer);
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Q badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cs.primary.withValues(alpha: 0.25),
                            cs.secondary.withValues(alpha: 0.25),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Q$questionNumber',
                        style: TextStyle(
                          color: cs.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Step dots
                    Row(
                      children: List.generate(totalQuestions, (i) {
                        final isActive = i < questionNumber;
                        final isCurrent = i == questionNumber - 1;
                        return Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: isCurrent ? 14 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isActive
                                ? cs.secondary
                                : Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: cs.secondary.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Question text
                Text(
                  question ?? '',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    letterSpacing: 0.1,
                  ),
                ),

                const SizedBox(height: 8),

                // Hint
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pilih salah satu jawaban di bawah',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        openBuilder: (context, closeContainer) {
          return GameOverScreen(
            score: viewModel.score,
            total: viewModel.totalQuestions,
            onRestart: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Grid kartu jawaban
// ─────────────────────────────────────────────
class AnswerCards extends StatelessWidget {
  final List<String> answers;
  final ValueChanged<int> onTapped;
  final int? correctAnswer;
  final int? selectedAnswer;

  const AnswerCards({
    required this.answers,
    required this.onTapped,
    required this.correctAnswer,
    required this.selectedAnswer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 5 / 2,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: List.generate(answers.length, (index) {
        return CardFlipEffect(
          delayAmount: index.toDouble() / 2,
          duration: const Duration(milliseconds: 300),
          child: AnimatedAnswerCard(
            key: ValueKey(
              '${answers.length > index ? answers[index] : ''}_$index',
            ),
            answer: answers.length > index ? answers[index] : '',
            onTapped: () => onTapped(index),
            isCorrectAnswer: correctAnswer == index,
            isSelectedAnswer: selectedAnswer == index,
            didAnswer: correctAnswer != null,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Kartu jawaban dengan animasi scale + glassmorphism
// ─────────────────────────────────────────────
class AnimatedAnswerCard extends StatefulWidget {
  final String answer;
  final VoidCallback onTapped;
  final bool isCorrectAnswer;
  final bool isSelectedAnswer;
  final bool didAnswer;

  const AnimatedAnswerCard({
    required this.answer,
    required this.onTapped,
    required this.isCorrectAnswer,
    required this.isSelectedAnswer,
    required this.didAnswer,
    super.key,
  });

  @override
  State<AnimatedAnswerCard> createState() => _AnimatedAnswerCardState();
}

class _AnimatedAnswerCardState extends State<AnimatedAnswerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.91),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.91, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_tapController);
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.didAnswer) {
      _tapController.forward(from: 0);
      widget.onTapped();
    }
  }

  Color _bgColor(BuildContext context) {
    if (!widget.didAnswer) return Colors.white.withValues(alpha: 0.06);
    if (widget.isCorrectAnswer) return const Color(0xFF064E3B).withValues(alpha: 0.85);
    if (widget.isSelectedAnswer) return const Color(0xFF4A0014).withValues(alpha: 0.85);
    return Colors.white.withValues(alpha: 0.03);
  }

  Color _borderColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!widget.didAnswer) return Colors.white.withValues(alpha: 0.1);
    if (widget.isCorrectAnswer) return cs.tertiary.withValues(alpha: 0.8);
    if (widget.isSelectedAnswer) return cs.error.withValues(alpha: 0.7);
    return Colors.white.withValues(alpha: 0.05);
  }

  Color _textColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!widget.didAnswer) return Colors.white.withValues(alpha: 0.85);
    if (widget.isCorrectAnswer) return cs.tertiary;
    if (widget.isSelectedAnswer) return cs.error;
    return Colors.white.withValues(alpha: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showFeedback =
        widget.didAnswer && (widget.isCorrectAnswer || widget.isSelectedAnswer);
    final feedbackIcon = widget.isCorrectAnswer
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final feedbackColor = widget.isCorrectAnswer ? cs.tertiary : cs.error;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _bgColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor(context),
              width: 1.5,
            ),
            boxShadow: [
              if (widget.isCorrectAnswer)
                BoxShadow(
                  color: cs.tertiary.withValues(alpha: 0.35),
                  blurRadius: 20,
                )
              else if (widget.isSelectedAnswer)
                BoxShadow(
                  color: cs.error.withValues(alpha: 0.25),
                  blurRadius: 16,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    widget.answer,
                    style: TextStyle(
                      color: _textColor(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (showFeedback)
                Positioned(
                  top: 6,
                  right: 6,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Icon(feedbackIcon, color: feedbackColor, size: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Status bar bawah: skor, gems, progress soal
// ─────────────────────────────────────────────
class StatusBar extends StatelessWidget {
  final QuizViewModel viewModel;

  const StatusBar({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score (animated counter)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Row(
              key: ValueKey(viewModel.score),
              children: [
                Icon(
                  Icons.bolt_rounded,
                  size: 20,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 4),
                Text(
                  '${viewModel.score}',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ' pts',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Diamond gem indicators (Implicit animation dengan ColorTween + AnimatedScale)
          ScoreboardIndicator(
            score: viewModel.score,
            totalQuestions: viewModel.totalQuestions,
          ),

          // Counter soal
          Row(
            children: [
              Icon(
                Icons.layers_rounded,
                size: 15,
                color: Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 5),
              Text(
                '${viewModel.answeredQuestionCount}/${viewModel.totalQuestions}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Scoreboard Indicator – diamond gems
// Sesuai Step 4 Codelab: Implicit Animations
// ─────────────────────────────────────────────
class ScoreboardIndicator extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ScoreboardIndicator({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < totalQuestions; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: AnimatedGem(isActive: score > i),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// AnimatedGem menggunakan TweenAnimationBuilder<Color?> + AnimatedScale
// Sesuai teknik Codelab Step 4
// ─────────────────────────────────────────────
class AnimatedGem extends StatelessWidget {
  final bool isActive;

  const AnimatedGem({required this.isActive, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        begin: Colors.white.withValues(alpha: 0.1),
        end: isActive ? cs.secondary : Colors.white.withValues(alpha: 0.1),
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      builder: (context, color, child) {
        return AnimatedScale(
          scale: isActive ? 1.3 : 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          child: Icon(
            Icons.diamond_rounded,
            color: color,
            size: 18,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Game Over Screen dengan confetti & grade badge
// ─────────────────────────────────────────────
class GameOverScreen extends StatefulWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;

  const GameOverScreen({
    required this.score,
    required this.total,
    required this.onRestart,
    super.key,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _confettiController;
  late final Animation<double> _iconScale;
  late final Animation<double> _contentFade;
  late final Animation<double> _contentSlide;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<double>(begin: 32.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Generate confetti particles
    final rng = math.Random();
    for (int i = 0; i < 70; i++) {
      _particles.add(
        _ConfettiParticle(
          x: rng.nextDouble(),
          speed: 0.25 + rng.nextDouble() * 0.75,
          angle: rng.nextDouble() * 2 * math.pi,
          size: 4.0 + rng.nextDouble() * 7.0,
          color: const [
            Color(0xFF7C3AED),
            Color(0xFF06B6D4),
            Color(0xFFF59E0B),
            Color(0xFF10B981),
            Color(0xFFEF4444),
            Colors.white,
          ][rng.nextInt(6)],
          rotationSpeed: (rng.nextDouble() - 0.5) * 12,
        ),
      );
    }

    if (widget.score > 0) {
      _confettiController.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _getMessage() {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return '🏆 Sempurna! Luar Biasa!';
    if (ratio >= 0.7) return '🎉 Bagus Sekali!';
    if (ratio >= 0.5) return '💪 Cukup Baik!';
    return '📚 Tetap Semangat!';
  }

  String _getGrade() {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return 'S';
    if (ratio >= 0.7) return 'A';
    if (ratio >= 0.5) return 'B';
    if (ratio >= 0.3) return 'C';
    return 'D';
  }

  Color _getGradeColor() {
    final ratio = widget.score / widget.total;
    if (ratio == 1.0) return const Color(0xFFF59E0B);
    if (ratio >= 0.7) return const Color(0xFF10B981);
    if (ratio >= 0.5) return const Color(0xFF06B6D4);
    if (ratio >= 0.3) return const Color(0xFF7C3AED);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          // Confetti layer
          if (widget.score > 0)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

          // Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trophy icon with grade badge
                  ScaleTransition(
                    scale: _iconScale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getGradeColor().withValues(alpha: 0.07),
                          ),
                        ),
                        // Inner gradient circle
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.45),
                                blurRadius: 36,
                                spreadRadius: 4,
                              ),
                              BoxShadow(
                                color: cs.secondary.withValues(alpha: 0.2),
                                blurRadius: 60,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ),
                        // Grade badge
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _getGradeColor(),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0A0F1E),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getGradeColor().withValues(alpha: 0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getGrade(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Animated content (fade + slide up)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _contentFade.value,
                        child: Transform.translate(
                          offset: Offset(0, _contentSlide.value),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        const Text(
                          'Kuis Selesai!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getMessage(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // Diamond gems scoreboard
                        ScoreboardIndicator(
                          score: widget.score,
                          totalQuestions: widget.total,
                        ),

                        const SizedBox(height: 24),

                        // Score card glassmorphism
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 28,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'SKOR AKHIR',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Animated score counter (0 → score)
                              TweenAnimationBuilder<int>(
                                tween: IntTween(begin: 0, end: widget.score),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeOut,
                                builder: (context, value, _) {
                                  return ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [cs.primary, cs.secondary],
                                    ).createShader(bounds),
                                    child: Text(
                                      '$value',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 80,
                                        fontWeight: FontWeight.w900,
                                        height: 0.9,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 8),
                              Text(
                                'dari ${widget.total} jawaban benar',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Accuracy pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getGradeColor().withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: _getGradeColor().withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  'Akurasi ${(widget.score / widget.total * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: _getGradeColor(),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Restart button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onRestart,
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: const Text('Main Lagi'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
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

// ─────────────────────────────────────────────
// Confetti particles
// ─────────────────────────────────────────────
class _ConfettiParticle {
  final double x;
  final double speed;
  final double angle;
  final double size;
  final Color color;
  final double rotationSpeed;

  const _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.angle,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y =
          p.speed * progress * size.height * 1.6 - size.height * 0.1;
      final x =
          p.x * size.width +
          35 * math.sin(progress * 4 * math.pi + p.angle);
      final opacity =
          progress < 0.65 ? 1.0 : 1.0 - (progress - 0.65) / 0.35;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.48,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
