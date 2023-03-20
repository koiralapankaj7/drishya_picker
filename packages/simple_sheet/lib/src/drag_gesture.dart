// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

///
typedef DragWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

const double _topSnapThreshold = 0.7;
const double _initialThreshold = 0.45;
const double _midSnapThreshold = 0.2;

const double _minFlingVelocity = 800;
// const double _closeProgressThreshold = 0.5;
const double _minDragThreshold = 20;

@immutable
class SSPoint {
  const SSPoint({
    this.offset = 0,
    this.snapThreshold = 0,
    this.duration,
    this.curve,
  });

  final double offset;
  final double snapThreshold;
  final Duration? duration;
  final Curve? curve;

  ///
  SSPoint copyWith({
    double? offset,
    double? snapThreshold,
    Duration? duration,
    Curve? curve,
  }) {
    return SSPoint(
      offset: offset ?? this.offset,
      snapThreshold: snapThreshold ?? this.snapThreshold,
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }

  @override
  String toString() {
    return '''SSPoint(offset: $offset, snapThreshold: $snapThreshold, duration: $duration, curve: $curve)''';
  }

  @override
  bool operator ==(covariant SSPoint other) {
    if (identical(this, other)) return true;
    return other.offset == offset &&
        other.snapThreshold == snapThreshold &&
        other.duration == duration &&
        other.curve == curve;
  }

  @override
  int get hashCode {
    return offset.hashCode ^
        snapThreshold.hashCode ^
        duration.hashCode ^
        curve.hashCode;
  }
}

mixin _GestureMixin<T extends StatefulWidget> on State<T> {
  SSPoint maxPoint = const SSPoint(offset: 1, snapThreshold: 0.3);
  SSPoint snapPoint = const SSPoint(offset: 0.45, snapThreshold: 0.2);
  SSPoint minPoint = const SSPoint();

  double get midThreshold;
  AnimationController get controller;
  final _scrollController = ScrollController();

  double _initialOffset = 0;
  Offset _initialPosition = Offset.zero;

  bool get _dismissUnderway => controller.isAnimating;
//controller.status == AnimationStatus.reverse;

  final GlobalKey _childKey = GlobalKey(debugLabel: 'BottomSheet child');
  double get _childHeight {
    final renderBox =
        _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  Widget buildContent(BuildContext context, ScrollController scrollController);

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _childKey,
      child: Semantics(
        container: true,
        onDismiss: _close,
        child: buildContent(context, _scrollController),
      ),
    );
  }

  //
  bool _isScrollInEffect(Offset position) {
    // +ve position.dy => Pointer is inside the view
    // -ve position.dy => Pointer is outside the view
    return _scrollController.hasClients &&
        _scrollController.position.extentBefore > 0 &&
        position.dy > 0;
  }

  ///
  void _onDown({required Offset position}) {
    _initialOffset = double.parse(
      controller.value.toStringAsFixed(2),
    );
    _initialPosition = position;
  }

  ///
  void _move({required Offset delta, required Offset position}) {
    if (_dismissUnderway) return;
    // if (_isScrollInEffect(position)) return;
    // _scrollController.jumpTo(_scrollController.offset);
    // controller.value -= delta.dy / _childHeight;

    final isClosing = _initialPosition.dy - position.dy < 0;

    // If sheet is closing and scrollable content is at top then can move gesture
    final canMove = isClosing &&
        _scrollController.hasClients &&
        _scrollController.position.extentBefore <= 0;

    late final canMoveFromTop = isOpen && canMove;
    // -ve Local position means pointer reached outside of the view,
    late final crossHandler = position.dy < 0;
    late final canMoveFromMid =
        _initialOffset == midThreshold && (crossHandler || canMove);

    if (canMoveFromTop || canMoveFromMid) {
      _scrollController.jumpTo(_scrollController.offset);
      controller.value -= delta.dy / _childHeight;
    }
  }

  ///
  void _settle({
    required Velocity velocity,
    required Offset position,
    VoidCallback? onClosing,
  }) {
    if (_dismissUnderway) return;

    var isClosing = false;

    // Fling movement
    if (velocity.pixelsPerSecond.dy.abs() > _minFlingVelocity) {
      // If scroll is in effect can't fling the sheet
      if (_isScrollInEffect(position)) return;

      final flingVelocity = -velocity.pixelsPerSecond.dy / _childHeight;

      // -ve flingVelocity => close
      // +ve flingVelocity => open
      if (flingVelocity < 0.0) {
        isClosing = true;
      }

      _snapToPosition(
        isOpen && isClosing
            ? midThreshold
            : isClosing
                ? 0
                : 1,
      );
    } else {
      final target = _targetPosition();
      if (target != null) {
        isClosing = target == 0;
        _snapToPosition(target);
      }
    }

    if (isClosing && onClosing != null) {
      onClosing();
    }
  }

  bool get isOpen => _initialOffset == 1;
  bool get isVisible => _initialOffset == midThreshold;
  bool get isClose => controller.value == 0;

  /// 0.7 => When screen is fully open
  /// midThreshold + 0.2 => When screen is halfway
  bool get _top =>
      controller.value > 0.7 || controller.value > midThreshold + 0.2;

  /// Move to center
  bool get _center =>
      isOpen && controller.value < 0.7 ||
      isVisible &&
          controller.isBetween(from: -0.15, to: 0.2, offset: midThreshold);

  /// Move to bottm, i.e, close
  bool get _bottom => controller.value < midThreshold - 0.15;

  double? _targetPosition() {
    if (_top) return 1;
    if (_center) return midThreshold;
    if (_bottom) return 0;
    return null;
  }

  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 600,
        ratio: 1.1,
      ),
      startValue ?? controller.value,
      endValue,
      0,
    );
    controller.animateWith(simulation);
  }

  void _close() {
    _snapToPosition(_initialOffset == 1.0 ? midThreshold : 0.0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

///
class DragGesture extends StatefulWidget {
  ///
  const DragGesture({
    required this.builder,
    required this.animationController,
    required this.onClosing,
    this.onClose,
    this.onDispose,
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
  final DragWidgetBuilder builder;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final VoidCallback onClosing;

  ///
  final VoidCallback? onClose;

  ///
  final VoidCallback? onDispose;

  ///
  final double? minDragThreshold;

  ///
  final double midThreshold;

  @override
  State<DragGesture> createState() => DragGestureController();
}

///
class DragGestureController extends State<DragGesture> with _GestureMixin {
  @override
  AnimationController get controller => widget.animationController;

  @override
  double get midThreshold => widget.midThreshold;

  VelocityTracker? _velocityTracker;

  ///
  void close() => _close();

  void _onPointerDown(PointerDownEvent event) {
    _onDown(position: event.localPosition);
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _move(delta: event.delta, position: event.localPosition);
    _velocityTracker!.addPosition(event.timeStamp, event.position);
  }

  void _onPointerUp(PointerUpEvent event) {
    _settle(
      velocity: _velocityTracker!.getVelocity(),
      position: event.localPosition,
      onClosing: widget.onClosing,
    );
    _velocityTracker = null;
  }

  ///
  bool _extentChanged(DraggableScrollableNotification notification) {
    // if (notification.extent == notification.minExtent) {
    //   widget.onClosing();
    // }
    return false;
  }

  @override
  Widget buildContent(BuildContext context, ScrollController scrollController) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.horizontal) {
          return true;
        }
        // While dragging may be we can disable child pointer
        return false;
      },
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: _extentChanged,
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          child: widget.builder(context, scrollController),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }
}

///
extension AnimationControllerX on AnimationController {
  ///
  void snapToPosition(double end, {double? from}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 600,
        ratio: 1.1,
      ),
      from ?? value,
      end,
      0,
    );
    animateWith(simulation);
  }

  /// true, if AnimationController [value] is between [from] and [to]
  ///
  /// [from] => minimum value (inclusive),
  /// [to] => maximum value (inclusive),
  /// [offset] => Common value which will be added to [from] and [to],
  bool isBetween({
    required double from,
    required double to,
    double offset = 0,
  }) =>
      value >= (from + offset) && value <= (offset + to);
}
