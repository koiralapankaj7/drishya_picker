import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
enum TriggerMode {
  /// Will triggered on continuous scrolling
  /// Listener will be triggered as soon as list reach either top or bottom
  ///
  anywhere,

  /// Will triggered on reaching top or bottom, will ignore continuous scrolling
  onEdge,
}

///
class ScrollListener extends StatefulWidget {
  ///
  const ScrollListener({
    Key? key,
    required this.child,
    required this.onScrollUpdate,
    this.onScrollStart,
    this.notificationDepth,
    this.triggerMode = TriggerMode.onEdge,
  }) : super(key: key);

  ///
  final Widget child;

  ///
  final void Function(ScrollController? controller, bool overScroll)
      onScrollUpdate;

  ///
  final void Function()? onScrollStart;

  ///
  final int? notificationDepth;

  ///
  final TriggerMode triggerMode;

  @override
  ScrollListenerState createState() => ScrollListenerState();
}

/// Contains the state for a [ScrollListener]. This class can be used to
/// Listen to a [ScrollController] and get notified when the list reaches
/// either bottom or top.
class ScrollListenerState extends State<ScrollListener> {
  @override
  void dispose() {
    super.dispose();
  }

  var _isReadyOnStart = false;
  var _disableGlow = true;
  var _continuousScroll = false;

  bool _isAtEdge(ScrollNotification notification) {
    return notification.metrics.extentBefore == 0.0 ||
        notification.metrics.extentAfter == 0.0;
  }

  bool get _triggerAnyWhere => widget.triggerMode == TriggerMode.anywhere;

  bool get _triggerOnEdge => widget.triggerMode == TriggerMode.onEdge;

  void _scrollStart(ScrollStartNotification notification) {
    _isReadyOnStart = _isAtEdge(notification);
    _disableGlow = _isReadyOnStart;
    widget.onScrollStart?.call();
  }

  // for BouncingScrollPhysics
  void _scrollUpdate(ScrollUpdateNotification notification) {
    final atEdge = _isAtEdge(notification);
    _continuousScroll = true;
    final overScroll = atEdge &&
        (_triggerAnyWhere ||
            (_isReadyOnStart &&
                _triggerOnEdge &&
                notification.dragDetails != null));
    _finish(notification, overScroll);
  }

  void _overScroll(OverscrollNotification notification) {
    final overScroll =
        (_triggerAnyWhere || (_triggerOnEdge && !_continuousScroll));
    _finish(notification, overScroll);
  }

  void _scrolEnd(ScrollEndNotification notification) {
    _isReadyOnStart = false;
    _disableGlow = true;
    _continuousScroll = false;
  }

  void _finish(ScrollNotification notification, bool overScroll) {
    final controller = notification.context != null
        ? Scrollable.of(notification.context!)?.widget.controller
        : null;

    // final scrollDirection =
    //     controller?.position.userScrollDirection ?? ScrollDirection.idle;
    // final atBottom = notification.metrics.extentAfter == 0.0;
    // final atTop = notification.metrics.extentBefore == 0.0;

    // final scrolling =
    //     (atBottom && scrollDirection == ScrollDirection.forward) ||
    //         (atTop && scrollDirection == ScrollDirection.reverse);

    // log('$atBottom  $scrollDirection : $scrolling');

    // widget.onScrollUpdate(controller, !continueScroll && overScroll);
    widget.onScrollUpdate(controller, overScroll);

    //     final scrolledPixel =
    //     (_pointerInitialPosition?.dy ?? 0.0) - currentPosition.dy;

    // final height = MediaQuery.of(context).size.height;

    // final factor = (scrolledPixel.abs() / height).clamp(0.0, 1.0);

    // final str = factor.toStringAsFixed(2);
    // final slidePercent = double.parse(str);

    // final controller = notification.context != null
    //     ? Scrollable.of(notification.context!)?.widget.controller
    //     : null;
    // widget.onOverScroll(slidePercent, scrolledPixel.isNegative, controller);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if ((widget.notificationDepth ?? 0) != notification.depth) return false;

    if (notification is ScrollStartNotification) {
      _scrollStart(notification);
    } else if (notification is ScrollUpdateNotification) {
      _scrollUpdate(notification);
    } else if (notification is OverscrollNotification) {
      _overScroll(notification);
    } else if (notification is ScrollEndNotification) {
      _scrolEnd(notification);
    } else if (notification is UserScrollNotification) {}

    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0) return false;
    if (_disableGlow) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );
  }
}
