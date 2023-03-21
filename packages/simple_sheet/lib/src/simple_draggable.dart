// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

///
typedef DragWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

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
  SSPoint get maxPoint;
  SSPoint get snapPoint;
  SSPoint get minPoint;
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
    final canMove = _scrollController.hasClients
        ? isClosing && _scrollController.position.extentBefore <= 0
        : isClosing;

    late final canMoveFromTop = isOpen && canMove;
    // -ve Local position means pointer reached outside of the view,
    late final crossHandler = position.dy < 0;
    late final canMoveFromMid =
        _initialOffset == midThreshold && (crossHandler || canMove);

    if (canMoveFromTop || canMoveFromMid) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset);
      }
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

      // -ve flingVelocity => close, +ve flingVelocity => open
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
class SimpleDraggable extends StatefulWidget {
  ///
  const SimpleDraggable({
    required this.builder,
    this.animationController,
    this.onClosing,
    this.onClose,
    this.onDispose,
    this.minDragThreshold,
    this.midThreshold = 0.45,
    this.maxPoint,
    this.snapPoint,
    this.minPoint,
    this.byPosition = false,
    this.delegate = const _DefaultDelegate(),
    super.key,
  });

  ///
  final AnimationController? animationController;

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
  final VoidCallback? onClosing;

  ///
  final VoidCallback? onClose;

  ///
  final VoidCallback? onDispose;

  ///
  final double? minDragThreshold;

  ///
  final double midThreshold;

  ///
  final SSPoint? maxPoint;

  ///
  final SSPoint? snapPoint;

  ///
  final SSPoint? minPoint;

  ///
  final bool byPosition;

  ///
  final SimpleDraggableDelegate? delegate;

  @override
  State<SimpleDraggable> createState() => SimpleDraggableController();
}

///
class SimpleDraggableController extends State<SimpleDraggable>
    with SingleTickerProviderStateMixin, _GestureMixin {
  late AnimationController _controller;
  late SDController _con;

  @override
  void initState() {
    super.initState();
    _controller = widget.animationController ??
        AnimationController(
          vsync: this,
          value: widget.midThreshold,
        );
    _con = SDController().._init();
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      _controller.dispose();
    }
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  SSPoint get maxPoint =>
      widget.maxPoint ??
      const SSPoint(
        offset: 1,
        snapThreshold: 0.3,
      );

  @override
  SSPoint get snapPoint => const SSPoint(
        offset: 0.45,
        snapThreshold: 0.2,
      );

  @override
  SSPoint get minPoint => const SSPoint();

  @override
  AnimationController get controller => _controller;

  @override
  double get midThreshold => widget.midThreshold;

  VelocityTracker? _velocityTracker;

  ///
  void close() => _close();

  void _onPointerDown(PointerDownEvent event) {
    log('Down ====>>');
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
    final handler = widget.delegate?.buildHandler(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: ColoredBox(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (handler != null) {
              return CustomMultiChildLayout(
                delegate: _LayoutDelegate(
                  progress: _controller.value,
                  max: 1,
                  min: widget.midThreshold,
                  byPosition: widget.byPosition,
                ),
                children: [
                  // Handler
                  LayoutId(id: _Type.handler, child: handler),
                  // Body
                  LayoutId(
                    id: _Type.body,
                    child: SizedBox.expand(child: child),
                  ),
                  // Scrim
                  LayoutId(
                    id: _Type.scrim,
                    child: Listener(
                      onPointerDown: _onPointerDown,
                      onPointerMove: _onPointerMove,
                      onPointerUp: _onPointerUp,
                      behavior: HitTestBehavior.translucent,
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ],
              );
            }

            // Position based
            if (widget.byPosition) {
              return CustomSingleChildLayout(
                delegate: _Layout(progress: _controller.value),
                child: SizedBox.expand(child: child),
              );
            }

            // Size based
            return FractionallySizedBox(
              heightFactor: _controller.value,
              widthFactor: 1,
              alignment: Alignment.bottomCenter,
              child: child,
            );
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.horizontal) {
                return true;
              }
              // While dragging may be we can disable child pointer
              return false;
            },
            child: NotificationListener<DraggableScrollableNotification>(
              onNotification: _extentChanged,
              child: widget.builder(context, scrollController),
              // child: Listener(
              //   onPointerDown: _onPointerDown,
              //   onPointerMove: _onPointerMove,
              //   onPointerUp: _onPointerUp,
              //   behavior: HitTestBehavior.opaque,
              //   child: widget.builder(context, scrollController),
              // ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Layout extends SingleChildLayoutDelegate {
  _Layout({required this.progress});

  final double progress;

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0, size.height - size.height * progress);
  }

  @override
  bool shouldRelayout(covariant _Layout oldDelegate) =>
      oldDelegate.progress != progress;
}

enum _Type { handler, body, scrim }

class _LayoutDelegate extends MultiChildLayoutDelegate {
  _LayoutDelegate({
    required this.progress,
    required this.max,
    required this.min,
    required this.byPosition,
  });

  final double progress;
  final double max;
  final double min;
  final bool byPosition;

  final _handlerHeight = 21;

  // Size based layout
  void _sizeBased(Size size) {
    final visibleHeight = size.height * progress;
    final looseConstraints = BoxConstraints.loose(size);

    final remaining = (max - progress) / (max - min);
    var handlerSize = Size.zero;

    // Handler
    if (hasChild(_Type.handler)) {
      handlerSize = layoutChild(_Type.handler, looseConstraints);
      positionChild(
        _Type.handler,
        Offset(0, size.height - visibleHeight),
      );
    }

    final bodyConstraints = looseConstraints.tighten(
      width: size.width,
      height: visibleHeight -
          _handlerHeight -
          (handlerSize.height - _handlerHeight) * (1 - remaining),
    );

    if (hasChild(_Type.body)) {
      layoutChild(_Type.body, bodyConstraints);
      positionChild(
        _Type.body,
        Offset(0, size.height - bodyConstraints.maxHeight),
      );
    }
  }

  // Position based layout
  void _positionBased(Size size) {
    final visibleHeight = size.height * progress;
    final looseConstraints = BoxConstraints.loose(size);

    final remaining = (max - progress) / (max - min);
    var handlerSize = Size.zero;

    // Handler
    if (hasChild(_Type.handler)) {
      handlerSize = layoutChild(_Type.handler, looseConstraints);
      positionChild(
        _Type.handler,
        Offset(0, size.height - visibleHeight),
      );
    }

    if (hasChild(_Type.body)) {
      layoutChild(
        _Type.body,
        looseConstraints.tighten(
          width: size.width,
          height: size.height - handlerSize.height,
        ),
      );
      positionChild(
        _Type.body,
        Offset(
          0,
          size.height -
              visibleHeight +
              _handlerHeight +
              (handlerSize.height - _handlerHeight) * (1 - remaining),
        ),
      );
    }
  }

  @override
  void performLayout(Size size) {
    // Layout handler and content
    byPosition ? _positionBased(size) : _sizeBased(size);
    // Layout scrim
    if (hasChild(_Type.scrim)) {
      layoutChild(_Type.scrim, BoxConstraints.tight(size));
      positionChild(
        _Type.scrim,
        Offset(0, size.height - size.height * progress),
      );
    }
  }

  @override
  bool shouldRelayout(covariant _LayoutDelegate oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.max != max ||
      oldDelegate.min != min ||
      oldDelegate.byPosition != byPosition;
}

abstract class SimpleDraggableDelegate {
  const SimpleDraggableDelegate();

  double get handlerMinHeight => 21;

  Widget? buildHandler(BuildContext context) {
    // return Container(
    //   alignment: Alignment.center,
    //   height: handlerMinHeight,
    //   color: Colors.black,
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(4),
    //     child: Container(
    //       width: 40,
    //       height: 5,
    //       color: Colors.grey.shade700,
    //     ),
    //   ),
    // );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          alignment: Alignment.center,
          height: handlerMinHeight,
          color: Colors.black,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 40,
              height: 5,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.pink,
            border: Border.all(color: Colors.yellow),
          ),
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {
                    log('Pressed');
                  },
                  icon: const Icon(Icons.close),
                  alignment: Alignment.centerLeft,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  const Text('Pankaj Koirala'),
                  const SizedBox(height: 4),
                  Text(
                    '23 Items',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    log('Pressed');
                  },
                  icon: const Icon(Icons.chevron_right),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

///
class _DefaultDelegate extends SimpleDraggableDelegate {
  const _DefaultDelegate();
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

class SDController with ChangeNotifier implements Listenable {
  var _isDisposed = false;

  ///
  void _init() {}

  @mustCallSuper
  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  @mustCallSuper
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
