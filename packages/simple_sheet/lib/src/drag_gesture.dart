import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const double _minFlingVelocity = 800;
// const double _closeProgressThreshold = 0.5;
const double _minDragThreshold = 20;

class _AllowVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) => acceptGesture(pointer);
}

///
class DragGesture extends StatefulWidget {
  /// Creates a bottom sheet.
  ///
  /// Typically, bottom sheets are created implicitly by
  /// [ScaffoldState.showBottomSheet], for persistent bottom sheets, or by
  /// [showModalBottomSheet], for modal bottom sheets.
  const DragGesture({
    required this.builder,
    required this.animationController,
    required this.onClosing,
    this.onDragStart,
    this.onDragEnd,
    this.minDragThreshold,
    this.midThreshold = 0.45,
    super.key,
  });

  ///
  final AnimationController animationController;

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final VoidCallback onClosing;

  /// Would typically be used to change the bottom sheet animation curve so
  /// that it tracks the user's finger accurately.
  final BottomSheetDragStartHandler? onDragStart;

  /// Would typically be used to reset the bottom sheet animation curve, so
  /// that it animates non-linearly. Called before [onClosing] if the bottom
  /// sheet is closing.
  final BottomSheetDragEndHandler? onDragEnd;

  ///
  final double? minDragThreshold;

  ///
  final double midThreshold;

  @override
  State<DragGesture> createState() => _DragGestureState();
}

class _DragGestureState extends State<DragGesture> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');
  ScrollController? _scrollController;
  late final _AllowVerticalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = _AllowVerticalDragGestureRecognizer();
    // ..onStart = _handleDragStart
    // ..onUpdate = _handleDragUpdate
    // ..onEnd = _handleDragEnd;
  }

  // Tracking pointer velocity for snaping panel
  VelocityTracker? _velocityTracker;

  double get _childHeight {
    final renderBox =
        _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  bool get _dismissUnderway =>
      widget.animationController.status == AnimationStatus.reverse;

  double _initialOffset = 0;

  void _handleDragStart(DragStartDetails details) {
    _initialOffset = double.parse(
      widget.animationController.value.toStringAsFixed(2),
    );
    // log('${widget.animationController.status} : $_initialOffset');
    if (_scrollController?.hasClients ?? false) {
      _scrollController!.position.hold(() {});
    }
    widget.onDragStart?.call(details);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_dismissUnderway) {
      return;
    }
    widget.animationController.value -= details.primaryDelta! / _childHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dismissUnderway) {
      return;
    }

    var isClosing = false;

    // Fling
    if (details.velocity.pixelsPerSecond.dy.abs() > _minFlingVelocity) {
      final flingVelocity = -details.velocity.pixelsPerSecond.dy / _childHeight;

      // -ve flingVelocity => close
      // +ve flingVelocity => open
      if (flingVelocity < 0.0) {
        isClosing = true;
      }

      if (isClosing && _initialOffset == 1.0) {
        // widget.animationController.reverse();
        // _snapToPosition(widget.midThreshold);
        _toCenter();
      } else if (widget.animationController.value > 0.0) {
        // widget.animationController.fling(velocity: flingVelocity);
        _snapToPosition(isClosing ? 0.0 : 1.0);
      }
    } else {
      // Max
      if (_initialOffset == 1.0) {
        if (widget.animationController.value > 0.7) {
          // widget.animationController.forward();
          _snapToPosition(1);
        } else {
          // _snapToPosition(widget.midThreshold);
          _toCenter();
        }
      }

      // Min
      if (_initialOffset == widget.midThreshold) {
        if (widget.animationController.value > widget.midThreshold + 0.2) {
          // Open full screen
          widget.animationController.forward();
        } else if (widget.animationController.value <
            widget.midThreshold - 0.15) {
          // Close
          // widget.animationController.fling(velocity: -1);
          // widget.animationController.animateTo(
          //   0,
          //   curve: Curves.decelerate,
          //   duration: const Duration(milliseconds: 200),
          // );
          _snapToPosition(0);
          isClosing = true;
        } else {
          // Keep in center
          // widget.animationController.fling(velocity: widget.midThreshold);
          // _snapToPosition(widget.midThreshold);
          _toCenter();
        }
      }
    }

    // else if (widget.animationController.value < 0.7) {
    //   if (widget.animationController.value > 0.0) {
    //     widget.animationController.fling(velocity: -1);
    //   }
    //   isClosing = true;
    // } else {
    //   log('Forward ===> ${widget.animationController.value}');
    //   widget.animationController.forward();
    // }

    widget.onDragEnd?.call(details, isClosing: isClosing);

    if (isClosing) {
      widget.onClosing();
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _recognizer.addPointer(event);
    _initialOffset = double.parse(
      widget.animationController.value.toStringAsFixed(2),
    );
    _velocityTracker ??= VelocityTracker.withKind(event.kind);

    // widget.onDragStart?.call(details);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_dismissUnderway) {
      return;
    }
    widget.animationController.value -= event.delta.dy / _childHeight;
    _velocityTracker!.addPosition(event.timeStamp, event.position);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_dismissUnderway) {
      return;
    }

    var isClosing = false;

    final velocity = _velocityTracker!.getVelocity();

    // Fling
    if (velocity.pixelsPerSecond.dy.abs() > _minFlingVelocity) {
      final flingVelocity = -velocity.pixelsPerSecond.dy / _childHeight;

      // -ve flingVelocity => close
      // +ve flingVelocity => open
      if (flingVelocity < 0.0) {
        isClosing = true;
      }

      if (isClosing && _initialOffset == 1.0) {
        // widget.animationController.reverse();
        // _snapToPosition(widget.midThreshold);
        _toCenter();
      } else if (widget.animationController.value > 0.0) {
        // widget.animationController.fling(velocity: flingVelocity);
        _snapToPosition(isClosing ? 0.0 : 1.0);
      }
    } else {
      // Max
      if (_initialOffset == 1.0) {
        if (widget.animationController.value > 0.7) {
          // widget.animationController.forward();
          _snapToPosition(1);
        } else {
          // _snapToPosition(widget.midThreshold);
          _toCenter();
        }
      }

      // Min
      if (_initialOffset == widget.midThreshold) {
        if (widget.animationController.value > widget.midThreshold + 0.2) {
          // Open full screen
          widget.animationController.forward();
        } else if (widget.animationController.value <
            widget.midThreshold - 0.15) {
          // Close
          // widget.animationController.fling(velocity: -1);
          // widget.animationController.animateTo(
          //   0,
          //   curve: Curves.decelerate,
          //   duration: const Duration(milliseconds: 200),
          // );
          _snapToPosition(0);
          isClosing = true;
        } else {
          // Keep in center
          // widget.animationController.fling(velocity: widget.midThreshold);
          // _snapToPosition(widget.midThreshold);
          _toCenter();
        }
      }
    }

    // else if (widget.animationController.value < 0.7) {
    //   if (widget.animationController.value > 0.0) {
    //     widget.animationController.fling(velocity: -1);
    //   }
    //   isClosing = true;
    // } else {
    //   log('Forward ===> ${widget.animationController.value}');
    //   widget.animationController.forward();
    // }

    // widget.onDragEnd?.call(details, isClosing: isClosing);

    if (isClosing) {
      widget.onClosing();
    }

    _velocityTracker = null;
  }

  void _toCenter() {
    _snapToPosition(widget.midThreshold);
    // widget.animationController.animateTo(
    //   widget.midThreshold,
    //   curve: Curves.decelerate,
    //   duration: const Duration(milliseconds: 200),
    // );
  }

  ///
  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 600,
        ratio: 1.1,
      ),
      startValue ?? widget.animationController.value,
      endValue,
      0,
    );
    widget.animationController.animateWith(simulation);
  }

  bool extentChanged(DraggableScrollableNotification notification) {
    if (notification.extent == notification.minExtent) {
      widget.onClosing();
    }
    return false;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      key: _childKey,
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.horizontal) {
          return true;
        }
        // While dragging may be we can disable child pointer
        return false;
      },
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: extentChanged,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          child: widget.builder(context),
        ),
      ),
    );
  }
}
