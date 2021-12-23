import 'package:flutter/material.dart';

/// {@template app_animated_cross_fade}
/// Abstraction of AnimatedCrossFade to override the layout centering
/// the widgets inside
/// {@endtemplate}
class AppAnimatedCrossFade extends StatelessWidget {
  /// {@macro app_animated_cross_fade}

  const AppAnimatedCrossFade({
    Key? key,
    required this.firstChild,
    required this.secondChild,
    required this.crossFadeState,
    this.duration,
    this.alignment,
  }) : super(key: key);

  /// First [Widget] to display
  final Widget firstChild;

  /// Second [Widget] to display
  final Widget secondChild;

  /// Specifies when to display [firstChild] or [secondChild]
  final CrossFadeState crossFadeState;

  ///
  final Duration? duration;

  ///
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState: crossFadeState,
      duration: duration ?? const Duration(milliseconds: 500),
      layoutBuilder: (
        Widget topChild,
        Key topChildKey,
        Widget bottomChild,
        Key bottomChildKey,
      ) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: alignment ?? Alignment.center,
          children: [
            Align(
              key: bottomChildKey,
              child: bottomChild,
            ),
            Align(
              alignment: alignment ?? Alignment.center,
              key: topChildKey,
              child: topChild,
            ),
          ],
        );
      },
    );
  }
}
