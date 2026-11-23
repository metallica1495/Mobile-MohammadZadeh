import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A self-contained brand animation. Keeping the ticker in this widget means
/// the logo animation is not coupled to HomePage's hooks or rebuild lifecycle.
class BrandLogoAnimation extends StatefulWidget {
  const BrandLogoAnimation({super.key, required this.isAnimating});

  final bool isAnimating;

  @override
  State<BrandLogoAnimation> createState() => _BrandLogoAnimationState();
}

class _BrandLogoAnimationState extends State<BrandLogoAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      // The explicit brand animation should keep running even when Android's
      // global "remove animations" accessibility flag is enabled.
      animationBehavior: AnimationBehavior.preserve,
    );
    if (widget.isAnimating) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant BrandLogoAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating == oldWidget.isAnimating) return;
    if (widget.isAnimating) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final phase = _controller.value * math.pi * 2;
        final tilt = widget.isAnimating ? math.sin(phase) * .16 : 0.0;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, .0028)
          ..rotateX(tilt)
          ..rotateY(phase);
        final sparkle = widget.isAnimating
            ? (.55 + .45 * (math.sin(phase * 2) + 1) / 2)
            : .72;
        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/images/mobile_sirus_brand_logo.webp',
                  width: 206,
                  height: 206,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                Positioned(
                  top: 1,
                  left: 1,
                  child: Transform.rotate(
                    angle: phase,
                    child: Opacity(
                      opacity: sparkle,
                      child: const Icon(Icons.auto_awesome,
                          color: Color(0xFFFFD76A), size: 27),
                    ),
                  ),
                ),
                Positioned(
                  top: 1,
                  right: 1,
                  child: Transform.rotate(
                    angle: -phase * 1.4,
                    child: Opacity(
                      opacity: sparkle,
                      child: const Icon(Icons.star_rounded,
                          color: Color(0xFFFFE7A0), size: 25),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  left: 1,
                  child: Opacity(
                    opacity: sparkle,
                    child: const Icon(Icons.star_rounded,
                        color: Color(0xFFFFE7A0), size: 21),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Opacity(
                    opacity: sparkle,
                    child: const Icon(Icons.auto_awesome,
                        color: Color(0xFFFFD76A), size: 23),
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
