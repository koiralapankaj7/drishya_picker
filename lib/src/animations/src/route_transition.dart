import 'package:flutter/material.dart';

/// Built a slide page transition for the picker.
class SlideTransitionPageRoute<T> extends PageRoute<T> {
  ///
  SlideTransitionPageRoute({
    required this.builder,
    this.transitionCurve = Curves.fastLinearToSlowEaseIn,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.reverseTransitionDuration = const Duration(milliseconds: 400),
    this.begainHorizontal = false,
    this.endHorizontal = false,
    RouteSettings? settings,
  }) : super(settings: settings);

  ///
  final Widget builder;

  ///
  final Curve transitionCurve;

  ///
  final bool begainHorizontal;

  ///
  final bool endHorizontal;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final bool opaque = true;

  @override
  final bool barrierDismissible = false;

  @override
  final bool maintainState = true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    var horizontal = begainHorizontal;
    if (animation.status == AnimationStatus.reverse &&
        horizontal != endHorizontal) {
      horizontal = endHorizontal;
    }
    final begin = horizontal ? const Offset(1, 0) : const Offset(0, 1);
    final tween = Tween(begin: begin, end: Offset.zero).chain(
      CurveTween(curve: transitionCurve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
