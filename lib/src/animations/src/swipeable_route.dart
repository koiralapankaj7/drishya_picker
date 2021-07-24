import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'scroll_listener.dart';

///
enum _SlidingState {
  ///
  slidingUp,

  ///
  slidingDown,

  ///
  idle,
}

const double _kMinFlingVelocity = 2.0; // Screen widths per second.

// Offset from fully on screen to 1/3 offscreen to the top.
final Animatable<Offset> _kMiddleBottomTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(-1.0 / 3.0, 0.0),
);

/// A modal route that replaces the entire screen with an facebook
/// model transition.
///
/// {@macro flutter.swipeable.swipeableRouteTransitionMixin}
///
/// By default, when a modal route is replaced by another, the previous route
/// remains in memory. To free all the resources when this is not necessary, set
/// [maintainState] to false.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] when an optional
/// `result` can be provided.
///
/// See also:
///
///  * [SwipeableRouteTransitionMixin], for a mixin that provides
///  * facebook model transition for this modal route.

class SwipeablePageRoute<T> extends PageRoute<T>
    with SwipeableRouteTransitionMixin<T> {
  /// Creates a page route for use in an facebook model designed app.
  ///
  /// The [builder], [maintainState], and [fullscreenDialog] arguments must not
  /// be null.
  SwipeablePageRoute({
    required this.builder,
    int? notificationDepth,
    this.title,
    RouteSettings? settings,
    this.maintainState = true,
    // bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: false) {
    // assert(opaque);
    SwipeableRouteTransitionMixin.notificationDepth = notificationDepth;
  }

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  final String? title;

  @override
  final bool maintainState;

  @override
  final bool opaque = false;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

/// A mixin that replaces the entire screen with an facebook model
/// transition for a [PageRoute].
///
/// {@template SwipeableRouteTransitionMixin}
/// The page slides in from the bottom and exits in reverse.
/// The page also shifts to the left in parallax when
/// another page enters to cover it.
///
/// The page slides in from the bottom and exits in reverse with no parallax
/// effect for fullscreen dialogs.
/// {@endtemplate}
///
/// See also:
///
///  * [MaterialRouteTransitionMixin], which is a mixin that provides
///    platform-appropriate transitions for a [PageRoute].
///  * [SwipeablePageRoute], which is a [PageRoute] that leverages this mixin.
mixin SwipeableRouteTransitionMixin<T> on PageRoute<T> {
  ///
  static int? notificationDepth;

  /// Builds the primary contents of the route.
  @protected
  Widget buildContent(BuildContext context);

  /// {@template flutter.swipeable.SwipeableRouteTransitionMixin.title}
  /// A title string for this route.
  ///
  /// {@endtemplate}
  String? get title;

  ValueNotifier<String?>? _previousTitle;

  /// The title string of the previous [SwipeablePageRoute].
  ///
  /// The [ValueListenable]'s value is readable after the route is installed
  /// onto a [Navigator]. The [ValueListenable] will also notify its listeners
  /// if the value changes (such as by replacing the previous route).
  ///
  /// The [ValueListenable] itself will be null before the route is installed.
  /// Its content value will be null if the previous route has no title or
  /// is not a [SwipeablePageRoute].
  ///
  /// See also:
  ///
  ///  * [ValueListenableBuilder], which can be used to listen and rebuild
  ///    widgets based on a ValueListenable.
  ValueListenable<String?> get previousTitle {
    assert(
      _previousTitle != null,
      'Cannot read the previousTitle for a route that'
      ' has not yet been installed',
    );
    return _previousTitle!;
  }

  @override
  void didChangePrevious(Route<dynamic>? previousRoute) {
    final previousTitleString = previousRoute is SwipeableRouteTransitionMixin
        ? previousRoute.title
        : null;
    if (_previousTitle == null) {
      _previousTitle = ValueNotifier<String?>(previousTitleString);
    } else {
      _previousTitle!.value = previousTitleString;
    }
    super.didChangePrevious(previousRoute);
  }

  @override
  // A relatively rigorous eyeball estimation.
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route
    // is a fullscreen dialog.
    return nextRoute is SwipeableRouteTransitionMixin &&
        !nextRoute.fullscreenDialog;
  }

  /// True if an facebook model-style back swipe pop gesture is currently
  /// underway for [route].
  ///
  /// This just check the route's [NavigatorState.userGestureInProgress].
  ///
  /// See also:
  ///
  ///  * [popGestureEnabled], which returns true if a user-triggered pop gesture
  ///    would be allowed.
  static bool isPopGestureInProgress(PageRoute<dynamic> route) {
    return route.navigator!.userGestureInProgress;
  }

  /// True if an facebook model-style back swipe pop
  /// gesture is currently underway for this route.
  ///
  /// See also:
  ///
  ///  * [isPopGestureInProgress], which returns true if a Swipeable pop gesture
  ///    is currently underway for specific route.
  ///  * [popGestureEnabled], which returns true if a user-triggered pop gesture
  ///    would be allowed.
  bool get popGestureInProgress => isPopGestureInProgress(this);

  /// Whether a pop gesture can be started by the user.
  ///
  /// Returns true if the user can edge-swipe to a previous route.
  ///
  /// Returns false once [isPopGestureInProgress] is true, but
  /// [isPopGestureInProgress] can only become true if [popGestureEnabled] was
  /// true first.
  ///
  /// This should only be used between frames, not during build.
  bool get popGestureEnabled => _isPopGestureEnabled(this);

  static bool _isPopGestureEnabled<T>(PageRoute<T> route) {
    // If there's nothing to go back to, then obviously we don't support
    // the back gesture.
    if (route.isFirst) return false;
    // If the route wouldn't actually pop if we popped it, then the gesture
    // would be really confusing (or would skip internal routes),
    // so disallow it.
    if (route.willHandlePopInternally) return false;
    // If attempts to dismiss this route might be vetoed such as in a page
    // with forms, then do not allow the user to dismiss the route with a swipe.
    if (route.hasScopedWillPopCallback) return false;
    // Fullscreen dialogs aren't dismissible by back swipe.
    if (route.fullscreenDialog) return false;
    // If we're in an animation already, we cannot be manually swiped.
    if (route.animation!.status != AnimationStatus.completed) return false;
    // If we're being popped into, we also cannot be swiped until the pop above
    // it completes. This translates to our secondary animation being
    // dismissed.
    if (route.secondaryAnimation!.status != AnimationStatus.dismissed) {
      return false;
    }
    // If we're in a gesture already, we cannot start another.
    if (isPopGestureInProgress(route)) return false;

    // Looks like a back gesture would be welcome!
    return true;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final child = buildContent(context);
    final result = Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    );

    return result;
  }

  // Called by _SwipeableBackGestureDetector when a pop ("back") drag start
  // gesture is detected. The returned controller handles all of the subsequent
  // drag events.
  static _SwipeableBackGestureController<T> _startPopGesture<T>(
      PageRoute<T> route) {
    assert(_isPopGestureEnabled(route));
    return _SwipeableBackGestureController<T>(
      navigator: route.navigator!,
      controller: route.controller!, // protected access
    );
  }

  ///
  /// This method can be applied to any [PageRoute], not just
  /// [SwipeablePageRoute]. It's typically used to provide a Swipeable style
  /// vertical transition for material widgets.
  ///
  static Widget buildPageTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Check if the route has an animation that's currently participating
    // in a back swipe gesture.
    //
    // In the middle of a back gesture drag, let the transition be linear to
    // match finger motions.
    final linearTransition = isPopGestureInProgress(route);

    return _SwipeableBackGestureDetector<T>(
      notificationDepth: notificationDepth,
      enabledCallback: () => _isPopGestureEnabled<T>(route),
      onStartPopGesture: () => _startPopGesture<T>(route),
      builder: (slidingState) {
        return SwipeablePageTransition(
          primaryRouteAnimation: animation,
          secondaryRouteAnimation: secondaryAnimation,
          linearTransition: linearTransition,
          slidingState: slidingState,
          child: child,
        );
      },
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return buildPageTransitions<T>(
        this, context, animation, secondaryAnimation, child);
  }
}

/// Provides an facebook model-style page transition animation.
///
/// The page slides in from the right and exits in reverse.
/// It also shifts to the left in a parallax motion when another page
/// enters to cover it.
class SwipeablePageTransition extends StatelessWidget {
  /// Creates an facebook model-style page transition.
  ///
  ///  * `primaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when this screen is being pushed.
  ///  * `secondaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when another screen is being pushed on top of this one.
  ///  * `linearTransition` is whether to perform the transitions linearly.
  ///    Used to precisely track back gesture drags.
  SwipeablePageTransition({
    Key? key,
    required this.child,
    required this.primaryRouteAnimation,
    required this.slidingState,
    required Animation<double> secondaryRouteAnimation,
    required bool linearTransition,
  })  : _secondaryPositionAnimation = (linearTransition
                ? secondaryRouteAnimation
                : CurvedAnimation(
                    parent: secondaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kMiddleBottomTween),
        super(key: key);

  // When this page is becoming covered by another page.
  final Animation<Offset> _secondaryPositionAnimation;
  // final Animation<Decoration> _primaryShadowAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  /// When this page is coming in to cover another page.
  final Animation<double> primaryRouteAnimation;

  /// Sliding state UP/DOWN
  final _SlidingState slidingState;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));

    final slidingUp = slidingState == _SlidingState.slidingUp;
    final slidingDown = slidingState == _SlidingState.slidingDown;

    return SlideTransition(
      position: _secondaryPositionAnimation,
      transformHitTests: false,
      child: SlideTransition(
        position: CurvedAnimation(
          parent: primaryRouteAnimation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        ).drive(
          Tween(
            begin: Offset(
              0.0,
              slidingUp
                  ? primaryRouteAnimation.value - 1
                  : slidingDown
                      ? 1 - primaryRouteAnimation.value
                      : 1.0,
            ),
            end: Offset(
              0.0,
              slidingUp
                  ? primaryRouteAnimation.value - 1
                  : slidingDown
                      ? 1 - primaryRouteAnimation.value
                      : 0.0,
            ),
          ),
        ),
        child: Column(
          children: [
            Expanded(child: child),
            SizedBox(
              height: slidingDown && primaryRouteAnimation.value > 0.4
                  ? (1 - primaryRouteAnimation.value) *
                      MediaQuery.of(context).size.height
                  : 0.0,
            ),
          ],
        ),
      ),
    );
  }
}

/// This is the widget side of [_SwipeableBackGestureController].
///
/// This widget provides a gesture recognizer which, when it determines the
/// route can be closed with a back gesture, creates the controller and
/// feeds it the input from the gesture recognizer.
///
/// The gesture data is converted from absolute coordinates to logical
/// coordinates by this widget.
///
/// The type `T` specifies the return type of the route with which this gesture
/// detector is associated.
class _SwipeableBackGestureDetector<T> extends StatefulWidget {
  const _SwipeableBackGestureDetector({
    Key? key,
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.builder,
    this.notificationDepth,
  }) : super(key: key);

  final Widget Function(_SlidingState slidingState) builder;

  final ValueGetter<bool> enabledCallback;

  final ValueGetter<_SwipeableBackGestureController<T>> onStartPopGesture;

  final int? notificationDepth;

  @override
  _SwipeableBackGestureDetectorState<T> createState() =>
      _SwipeableBackGestureDetectorState<T>();
}

class _SwipeableBackGestureDetectorState<T>
    extends State<_SwipeableBackGestureDetector<T>> {
  // Animation status listener
  void _listener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      slidingState = _SlidingState.idle;
      _scrollController = null;
      _backGestureController?.controller.removeStatusListener(_listener);
    }
  }

  //
  _SwipeableBackGestureController<T>? _backGestureController;

  //
  ScrollController? _scrollController;

  // Initial position of pointer
  var _pointerInitialPosition = Offset.zero;

  // Tracking pointer velocity for snaping panel
  VelocityTracker? _velocityTracker;

  // Current sliding state
  var slidingState = _SlidingState.idle;

  //
  var _overScroll = true;

  //
  double _convertToLogical(double value) {
    return slidingState == _SlidingState.slidingDown ? value : -value;
  }

  // Pointer down event
  void _onPointerDown(PointerDownEvent event) {
    assert(mounted);
    if (_backGestureController != null) return;

    _backGestureController = widget.onStartPopGesture()
      ..controller.addStatusListener(_listener);
    _pointerInitialPosition = event.position;
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  // Pointer move event
  void _onPointerMove(PointerMoveEvent event) {
    assert(mounted);
    if (_backGestureController == null) return;
    if (!_shouldScroll(event.position.dy)) return;
    if (!_overScroll) return;

    _scrollController?.position.hold(() {});

    _velocityTracker!.addPosition(event.timeStamp, event.position);

    slidingState = _pointerInitialPosition.dy - event.position.dy < 0.0
        ? _SlidingState.slidingDown
        : _SlidingState.slidingUp;

    _backGestureController!
        .dragUpdate(_convertToLogical(event.delta.dy / context.size!.height));
  }

  void _onPointerUp(PointerUpEvent event) {
    assert(mounted);
    if (_velocityTracker == null) return;
    if (_backGestureController == null) return;

    _backGestureController!.dragEnd(_convertToLogical(
        _velocityTracker!.getVelocity().pixelsPerSecond.dy /
            context.size!.height));

    _backGestureController = null;
    _scrollController = null;
    _velocityTracker = null;
    _overScroll = true;
  }

  // If pointer is moved by more than 2 px then only begain
  bool _shouldScroll(double currentDY) {
    return (currentDY.abs() - _pointerInitialPosition.dy.abs()).abs() > 30.0;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: ScrollListener(
        notificationDepth: widget.notificationDepth,
        onScrollUpdate: (controller, overScroll) {
          _scrollController = controller;
          _overScroll = overScroll;
        },
        child: widget.builder(slidingState),
      ),
    );
  }
}

/// A controller for an facebook model-style back gesture.
///
/// This is created by a [SwipeablePageRoute] in response from a gesture caught
/// by a [_SwipeableBackGestureDetector] widget, which then also feeds it input
/// from the gesture. It controls the animation controller owned by the route,
/// based on the input provided by the gesture detector.
///
/// This class works entirely in logical coordinates (0.0 is new page dismissed,
/// 1.0 is new page on top).
///
/// The type `T` specifies the return type of the route with which this gesture
/// detector controller is associated.
class _SwipeableBackGestureController<T> {
  /// Creates a controller for an facebook model-style back gesture.
  ///
  /// The [navigator] and [controller] arguments must not be null.
  _SwipeableBackGestureController({
    required this.navigator,
    required this.controller,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  /// The drag gesture has changed by [delta]. The total range of the
  /// drag should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// The drag gesture has ended with a horizontal motion of
  /// [velocity] as a fraction of screen width per second.
  void dragEnd(double velocity) {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native
    // facebook model animations.
    final bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.pop();

      // The popping may have finished inline if already at the target
      // destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        controller.animateBack(
          0.0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastLinearToSlowEaseIn,
        );
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since SwipeablePageTransition
      // depends on userGestureInProgress.
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
