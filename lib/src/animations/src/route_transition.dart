import 'package:flutter/material.dart';

/// Built a slide page transition for the picker.
class SlideTransitionPageRoute<T> extends PageRoute<T> {
  ///
  SlideTransitionPageRoute({
    required this.builder,
    this.transitionCurve = Curves.fastLinearToSlowEaseIn,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
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
    var begin = horizontal ? const Offset(1.0, 0.0) : const Offset(0.0, 1.0);
    var tween = Tween(begin: begin, end: Offset.zero).chain(
      CurveTween(curve: transitionCurve),
    );

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

// /// Camera and gallery route
// Route<T> _route<T>(
//   Widget page, {
//   bool horizontal = false,
//   String? name,
// }) {
//   return PageRouteBuilder<T>(
//     pageBuilder: (context, animation, secondaryAnimation) => page,
//     settings: RouteSettings(name: name),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = horizontal ? const Offset(1.0, 0.0) :
//const Offset(0.0, 1.0);
//       var end = Offset.zero;
//       var curve = Curves.ease;
//       var tween = Tween(begin: begin, end: end).
//chain(CurveTween(curve: curve));
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }
