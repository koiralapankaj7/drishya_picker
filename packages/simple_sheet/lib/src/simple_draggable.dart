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
// const double _minDragThreshold = 20;
const _maxPoint = SPoint(offset: 1, snapThreshold: 0.3);
const _snapPoint = SPoint(offset: 0.45, snapThreshold: 0.2);
const _minPoint = SPoint();

///
class SimpleDraggable extends StatefulWidget {
  ///
  SimpleDraggable({
    required this.builder,
    this.controller,
    this.scrollController,
    this.setting = const SDraggableSetting(),
    this.delegate = const _DefaultDelegate(),
    super.key,
  }) : assert(
          setting.initialPoint >= setting.minPoint &&
              setting.initialPoint <= setting.maxPoint,
          'Initial point must be between minimum and maximum point.',
        );

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final DragWidgetBuilder builder;

  ///
  final SDController? controller;

  ///
  final ScrollController? scrollController;

  ///
  final SDraggableSetting setting;

  ///
  final SimpleDraggableDelegate? delegate;

  // /// Called when the bottom sheet begins to close.
  // ///
  // /// A bottom sheet might be prevented from closing (e.g., by user
  // /// interaction) even after this callback is called. For this reason, this
  // /// callback might be call multiple times for a given bottom sheet.
  // final VoidCallback? onClosing;

  // ///
  // final VoidCallback? onClose;

  // ///
  // final VoidCallback? onDispose;

  @override
  State<SimpleDraggable> createState() => _SimpleDraggableState();
}

///
class _SimpleDraggableState extends State<SimpleDraggable>
    with SingleTickerProviderStateMixin {
  final _childKey = GlobalKey(debugLabel: 'SimpleDraggable child');
  late SDController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SDController();
    _scrollController = widget.scrollController ?? ScrollController();
    _initController();
    _controller._animationController = AnimationController(
      vsync: this,
      value: widget.setting.initialPoint.offset,
    );
  }

  void _initController() {
    _controller
      .._childKey = _childKey
      .._setting = widget.setting
      .._scrollController = _scrollController
      .._initialized = true;
  }

  @override
  void didUpdateWidget(covariant SimpleDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);
    var needsSetup = false;
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? SDController();
      needsSetup = true;
    }

    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
      needsSetup = true;
    }

    if (needsSetup || oldWidget.setting != widget.setting) {
      _initController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  VelocityTracker? _velocityTracker;

  void _onPointerDown(PointerDownEvent event) {
    _controller._onDown(position: event.localPosition);
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _controller._move(delta: event.delta, position: event.localPosition);
    _velocityTracker!.addPosition(event.timeStamp, event.position);
  }

  void _onPointerUp(PointerUpEvent event) {
    _controller._settle(
      velocity: _velocityTracker!.getVelocity(),
      position: event.localPosition,
      // onClosing: widget.onClosing,
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
  Widget build(BuildContext context) {
    final handler = widget.delegate?.buildHandler(context);

    return KeyedSubtree(
      key: _childKey,
      child: Semantics(
        container: true,
        onDismiss: _controller.close,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ColoredBox(
            color: Colors.amber,
            child: AnimatedBuilder(
              animation: _controller.animation,
              builder: (context, child) {
                if (handler != null) {
                  return CustomMultiChildLayout(
                    delegate: _LayoutDelegate(
                      progress: _controller.animation.value,
                      setting: widget.setting,
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
                if (widget.setting.byPosition) {
                  return CustomSingleChildLayout(
                    delegate: _Layout(progress: _controller.animation.value),
                    child: SizedBox.expand(child: child),
                  );
                }

                // Size based
                return FractionallySizedBox(
                  heightFactor: _controller.animation.value,
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
                  child: widget.builder(context, _scrollController),
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
    required this.setting,
  });

  final double progress;
  final SDraggableSetting setting;

  final _handlerHeight = 21;

  // Size based layout
  void _sizeBased(Size size) {
    final max = setting.minPoint.offset;
    final min = setting.minPoint.offset;

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
    final max = setting.minPoint.offset;
    final min = setting.minPoint.offset;
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
    setting.byPosition ? _positionBased(size) : _sizeBased(size);
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
      oldDelegate.setting.maxPoint.offset != setting.maxPoint.offset ||
      oldDelegate.setting.minPoint.offset != setting.minPoint.offset ||
      oldDelegate.setting.byPosition != setting.byPosition;
}

abstract class SimpleDraggableDelegate {
  const SimpleDraggableDelegate();

  ///
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

@immutable
class SPoint {
  const SPoint({
    this.offset = 0,
    this.snapThreshold = 0,
    this.duration,
    this.curve,
  })  : assert(
          offset >= 0 && offset <= 1,
          'Offset must be between 1 and 0.',
        ),
        assert(
          snapThreshold >= 0 && snapThreshold <= 1,
          'Snap threshold must be between 1 and 0.',
        );

  /// Factor of the height
  final double offset;

  /// Factor
  final double snapThreshold;

  /// Animation duration
  final Duration? duration;

  /// Animation curve
  final Curve? curve;

  ///
  bool operator >(SPoint other) => offset > other.offset;

  ///
  bool operator >=(SPoint other) => offset >= other.offset;

  ///
  bool operator <(SPoint other) => offset < other.offset;

  ///
  bool operator <=(SPoint other) => offset <= other.offset;

  ///
  double operator +(SPoint other) => offset + other.offset;

  double operator -(SPoint other) => offset - other.offset;

  ///
  SPoint copyWith({
    double? offset,
    double? snapThreshold,
    Duration? duration,
    Curve? curve,
  }) {
    return SPoint(
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
  bool operator ==(covariant SPoint other) {
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

///
@immutable
class SDraggableSetting {
  const SDraggableSetting({
    this.maxPoint = _maxPoint,
    this.snapPoint = _snapPoint,
    this.minPoint = _minPoint,
    this.initialPoint = _minPoint,
    this.byPosition = false,
  });

  ///
  final SPoint maxPoint;

  ///
  final SPoint snapPoint;

  ///
  final SPoint minPoint;

  ///
  final SPoint initialPoint;

  ///
  final bool byPosition;

  ///
  SDraggableSetting copyWith({
    SPoint? maxPoint,
    SPoint? snapPoint,
    SPoint? minPoint,
    SPoint? initialPoint,
    bool? byPosition,
  }) {
    return SDraggableSetting(
      maxPoint: maxPoint ?? this.maxPoint,
      snapPoint: snapPoint ?? this.snapPoint,
      minPoint: minPoint ?? this.minPoint,
      initialPoint: initialPoint ?? this.initialPoint,
      byPosition: byPosition ?? this.byPosition,
    );
  }

  @override
  String toString() {
    return '''SDraggableSetting(maxPoint: $maxPoint, snapPoint: $snapPoint, minPoint: $minPoint, initialPoint: $initialPoint, byPosition: $byPosition)''';
  }

  @override
  bool operator ==(covariant SDraggableSetting other) {
    if (identical(this, other)) return true;

    return other.maxPoint == maxPoint &&
        other.snapPoint == snapPoint &&
        other.minPoint == minPoint &&
        other.initialPoint == initialPoint &&
        other.byPosition == byPosition;
  }

  @override
  int get hashCode {
    return maxPoint.hashCode ^
        snapPoint.hashCode ^
        minPoint.hashCode ^
        initialPoint.hashCode ^
        byPosition.hashCode;
  }
}

mixin _GestureMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late SDraggableSetting _setting;
  double get _childHeight;

  double _initialOffset = 0;
  Offset _initialPosition = Offset.zero;

  SPoint get _maxPoint => _setting.maxPoint;
  SPoint get _snapPoint => _setting.snapPoint;
  SPoint get _minPoint => _setting.minPoint;
  //controller.status == AnimationStatus.reverse;
  bool get _dismissUnderway => _animationController.isAnimating;
  bool get isFullyOpen => _initialOffset == _maxPoint.offset;
  bool get isSnapped => _initialOffset == _snapPoint.offset;
  bool get isMinimized => _value == _minPoint.offset;
  // 0.7 => When screen is fully open
  // midThreshold + 0.2 => When screen is halfway
  bool get _top =>
      _value > 0.7 || _value > _snapPoint.offset + _snapPoint.snapThreshold;
  // Move to center
  bool get _center =>
      isFullyOpen && _value < 0.7 ||
      isSnapped &&
          _animationController.isBetween(
            from: -0.15,
            to: 0.2,
            offset: _snapPoint.offset,
          );
  // Move to bottm, i.e, close
  bool get _bottom =>
      _value < _snapPoint.offset - _snapPoint.snapThreshold; //0.15;

  double get _value => _animationController.value;
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
      _value.toStringAsFixed(2),
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

    // If sheet is closing and scrollable content is at top
    // then can move gesture
    final canMove = _scrollController.hasClients
        ? isClosing && _scrollController.position.extentBefore <= 0
        : isClosing;

    late final canMoveFromTop = isFullyOpen && canMove;
    // -ve Local position means pointer reached outside of the view,
    late final crossHandler = position.dy < 0;
    late final canMoveFromMid =
        _initialOffset == _snapPoint.offset && (crossHandler || canMove);

    if (canMoveFromTop || canMoveFromMid) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset);
      }
      _animationController.value -= delta.dy / _childHeight;
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
        isFullyOpen && isClosing
            ? _snapPoint.offset
            : isClosing
                ? _minPoint.offset
                : _maxPoint.offset,
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

  double? _targetPosition() {
    if (_top) return _maxPoint.offset;
    if (_center) return _snapPoint.offset;
    if (_bottom) return _minPoint.offset;
    return null;
  }

  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 600,
        ratio: 1.1,
      ),
      startValue ?? _value,
      endValue,
      0,
    );
    _animationController.animateWith(simulation);
  }

  void _close() {
    _snapToPosition(
      _initialOffset == _maxPoint.offset ? _snapPoint.offset : _minPoint.offset,
    );
  }
}

///
class SDController extends ChangeNotifier with _GestureMixin {
  late GlobalKey<State<StatefulWidget>> _childKey;

  var _isDisposed = false;
  bool _initialized = false;

  @override
  double get _childHeight {
    final renderBox =
        _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

//
  T _assert<T>(T object) {
    assert(
      _initialized,
      'SDController is not attached to a widget. A SDController '
      'must be used in a SimpleDraggable before any of its methods are called.',
    );
    return object;
  }

  ///
  Animation<double> get animation => _assert(_animationController);

  ///
  void open() {}

  ///
  void close() => _close();

  ///
  void moveTo({required SPoint point}) {
    //
  }

  @mustCallSuper
  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  @mustCallSuper
  void dispose() {
    _animationController.dispose();
    _isDisposed = true;
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
