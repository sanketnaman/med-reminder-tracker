import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable animation widgets and helpers for Mediaro.
/// All animations are subtle, calm, and professional — suitable for a healthcare app.

// ─── FadeSlideIn ──────────────────────────────────────────────
/// Fades in and slides up by [offset] pixels. Used for staggered card entry.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.offset = 12,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 40),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }
}

// ─── FadeScaleIn ──────────────────────────────────────────────
/// Fades in with subtle scale (0.96 → 1.0). Used for logo/splash.
class FadeScaleIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;

  const FadeScaleIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.beginScale = 0.96,
  });

  @override
  State<FadeScaleIn> createState() => _FadeScaleInState();
}

class _FadeScaleInState extends State<FadeScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }
}

// ─── AnimatedCount ────────────────────────────────────────────
/// Smoothly transitions between integer values (e.g., 50% → 75%).
class AnimatedCount extends StatelessWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String suffix;

  const AnimatedCount({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 500),
    this.style,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          '$val$suffix',
          style: style,
        );
      },
    );
  }
}

// ─── AnimatedProgressBar ──────────────────────────────────────
/// Smoothly animates the fill width of a progress bar.
class AnimatedProgressBar extends StatelessWidget {
  final double percent;
  final double height;
  final Duration duration;
  final Gradient? fillGradient;
  final Color? trackColor;

  const AnimatedProgressBar({
    super.key,
    required this.percent,
    this.height = 18,
    this.duration = const Duration(milliseconds: 600),
    this.fillGradient,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent / 100),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    color: trackColor ?? Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      gradient: fillGradient ??
                          LinearGradient(
                            colors: [
                              Color.lerp(
                                const Color(0xFF5B8DEF),
                                const Color(0xFF35B779),
                                value.clamp(0, 1),
                              )!,
                              Color.lerp(
                                const Color(0xFF7BA7F7),
                                const Color(0xFF35B779),
                                value.clamp(0, 1),
                              )!.withOpacity(0.85),
                            ],
                          ),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── AnimatedCircularProgress ─────────────────────────────────
/// Animated circular progress indicator with percentage text.
class AnimatedCircularProgress extends StatelessWidget {
  final double percent;
  final double size;
  final double strokeWidth;
  final Duration duration;
  final Color? progressColor;

  const AnimatedCircularProgress({
    super.key,
    required this.percent,
    this.size = 90,
    this.strokeWidth = 8,
    this.duration = const Duration(milliseconds: 700),
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent / 100),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final displayPercent = (value * 100).round();
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size - strokeWidth * 2,
                height: size - strokeWidth * 2,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? const Color(0xFF20C9D8),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.2),
                ),
              ),
              Text(
                '$displayPercent%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── AnimatedCheckmark ────────────────────────────────────────
/// Subtle checkmark that appears with a scale+fade. Used for "Taken" transitions.
class AnimatedCheckmark extends StatefulWidget {
  final bool show;
  final double size;
  final Color color;
  final Duration duration;

  const AnimatedCheckmark({
    super.key,
    required this.show,
    this.size = 24,
    this.color = const Color(0xFF35B779),
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    if (widget.show) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCheckmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0);
    } else if (!widget.show && oldWidget.show) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: Icon(
          Icons.check_circle,
          size: widget.size,
          color: widget.color,
        ),
      ),
    );
  }
}

// ─── StaggeredListView ────────────────────────────────────────
/// Wraps children with staggered FadeSlideIn animations.
class StaggeredListView extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final double offset;

  const StaggeredListView({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.offset = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        return FadeSlideIn(
          delay: staggerDelay * index,
          offset: offset,
          child: children[index],
        );
      }),
    );
  }
}

// ─── SmoothSwitch ─────────────────────────────────────────────
/// Cross-fades between two widgets. Used for profile switching.
class SmoothSwitch extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SmoothSwitch({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

// ─── PulseDot ─────────────────────────────────────────────────
/// Subtle pulsing dot for live/upcoming indicators.
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulseDot({
    super.key,
    this.color = const Color(0xFF5B8DEF),
    this.size = 8,
  });

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

// ─── PageTransition ───────────────────────────────────────────
/// Fade-through page transition for navigation.
class SlideUpTransition extends PageRouteBuilder {
  final Widget page;

  SlideUpTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            );
            return FadeTransition(
              opacity: curved,
              child: child,
            );
          },
        );
}

// ─── AnimatedOpacityOnTap ─────────────────────────────────────
/// Wraps a child with a subtle press animation (scale down + opacity).
class AnimatedOpacityOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const AnimatedOpacityOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.97,
  });

  @override
  State<AnimatedOpacityOnTap> createState() => _AnimatedOpacityOnTapState();
}

class _AnimatedOpacityOnTapState extends State<AnimatedOpacityOnTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _animation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _animation,
        child: widget.child,
      ),
    );
  }
}

// ─── AnimatedSuccessOverlay ───────────────────────────────────
/// Shows a brief success checkmark overlay (for Take Now, etc.)
class AnimatedSuccessOverlay extends StatefulWidget {
  final bool show;
  final Widget child;

  const AnimatedSuccessOverlay({
    super.key,
    required this.show,
    required this.child,
  });

  @override
  State<AnimatedSuccessOverlay> createState() => _AnimatedSuccessOverlayState();
}

class _AnimatedSuccessOverlayState extends State<AnimatedSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.show) _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedSuccessOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _controller.reverse();
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF35B779),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF35B779).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
