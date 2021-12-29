import 'package:flutter/material.dart';

///
class CustomRouteSetting {
  ///
  /// Settings for route
  const CustomRouteSetting({
    this.curve = Curves.fastLinearToSlowEaseIn,
    this.start = TransitionFrom.bottomToTop,
    this.reverse = TransitionFrom.topToBottom,
    this.transitionDuration = const Duration(milliseconds: 350),
    this.reverseTransitionDuration = const Duration(milliseconds: 350),
    this.settings,
  });

  /// Route animation curve
  final Curve curve;

  /// Route transition will start from this location
  final TransitionFrom start;

  /// Reverse route transition will start from this location
  final TransitionFrom reverse;

  /// Transition duration
  final Duration transitionDuration;

  /// Reverse transition duration
  final Duration reverseTransitionDuration;

  /// Route settings
  final RouteSettings? settings;
}

/// Direction from where route transition will occure
enum TransitionFrom {
  /// Start from left side and end at right side
  leftToRight,

  /// Start from right side and end at left side
  rightToLeft,

  /// Start from top and end at bottom of the screen
  topToBottom,

  /// Start from bottom and end at top of the screen
  bottomToTop,
}

/// Built a slide page transition for the picker.
class SlideTransitionPageRoute<T> extends PageRoute<T> {
  ///
  SlideTransitionPageRoute({
    required this.builder,
    this.setting = const CustomRouteSetting(),
  })  : transitionDuration = setting.transitionDuration,
        reverseTransitionDuration = setting.reverseTransitionDuration,
        super(settings: setting.settings);

  ///
  final Widget builder;

  ///
  final CustomRouteSetting setting;

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
  ) =>
      builder;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reverse = animation.status == AnimationStatus.reverse;

    final tween = Tween(
      begin: reverse ? setting.reverse.reverseOffset : setting.start.offset,
      end: Offset.zero,
    ).chain(CurveTween(curve: setting.curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

const _bottom = Offset(0, 1);
const _top = Offset(0, -1);
const _right = Offset(1, 0);
const _left = Offset(-1, 0);

extension on TransitionFrom {
  Offset get offset {
    switch (this) {
      case TransitionFrom.bottomToTop:
        return _bottom;
      case TransitionFrom.topToBottom:
        return _top;
      case TransitionFrom.rightToLeft:
        return _right;
      case TransitionFrom.leftToRight:
        return _left;
    }
  }

  Offset get reverseOffset {
    switch (this) {
      case TransitionFrom.bottomToTop:
        return _top;
      case TransitionFrom.topToBottom:
        return _bottom;
      case TransitionFrom.rightToLeft:
        return _left;
      case TransitionFrom.leftToRight:
        return _right;
    }
  }
}
