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
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SDController();
    _scrollController = widget.scrollController ?? ScrollController();
    _animationController = AnimationController(
      vsync: this,
      value: widget.setting.initialPoint.offset,
    );
    _initController();
  }

  void _initController() {
    _controller._init(
      childKey: _childKey,
      animationController: _animationController,
      scrollController: _scrollController,
      setting: widget.setting,
    );
  }

  @override
  void didUpdateWidget(covariant SimpleDraggable oldWidget) {
    super.didUpdateWidget(oldWidget);
    var needsUpdate = false;
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _controller.dispose();
      }
      _controller = widget.controller ?? SDController();
      needsUpdate = true;
    }

    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
      needsUpdate = true;
    }

    if (needsUpdate || oldWidget.setting != widget.setting) {
      if (oldWidget.setting.initialPoint != widget.setting.initialPoint) {
        _controller._animationController.value =
            widget.setting.initialPoint.offset;
      }
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handler = widget.delegate?.buildHandler(context);

    return SafeArea(
      key: _childKey,
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
                    onPointerDown: _controller._onPointerDown,
                    onPointerMove: _controller._onPointerMove,
                    onPointerUp: _controller._onPointerUp,
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
          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: _controller.animation.value,
              widthFactor: 1,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
        child: Semantics(
          container: true,
          onDismiss: _controller.close,
          child: handler != null
              ? widget.builder(context, _scrollController)
              : Listener(
                  onPointerDown: _controller._onPointerDown,
                  onPointerMove: _controller._onPointerMove,
                  onPointerUp: _controller._onPointerUp,
                  behavior: HitTestBehavior.translucent,
                  child: widget.builder(context, _scrollController),
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
    final max = setting.maxPoint.offset;
    final min = setting.snapPoint.offset;

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
          (handlerSize.height - _handlerHeight) * (1 - remaining).clamp(0, 1),
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
    final max = setting.maxPoint.offset;
    final min = setting.snapPoint.offset;
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
              (handlerSize.height - _handlerHeight) *
                  (1 - remaining).clamp(0, 1),
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

///
class SDController extends ChangeNotifier {
  late GlobalKey<State<StatefulWidget>> _childKey;
  late AnimationController _animationController;
  late ScrollController _scrollController;
  late SDraggableSetting _setting;
  late SPoint _currentPoint;

  var _isDisposed = false;
  bool _initialized = false;
  SDState _state = SDState.close;
  VelocityTracker? _velocityTracker;
  double _initialOffset = 0;
  Offset _initialPosition = Offset.zero;

  void _init({
    required GlobalKey<State<StatefulWidget>> childKey,
    required AnimationController animationController,
    required ScrollController scrollController,
    required SDraggableSetting setting,
  }) {
    _childKey = childKey;
    _animationController = animationController;
    _scrollController = scrollController;
    _setting = setting;
    _currentPoint = setting.initialPoint;
    _initialized = true;
  }

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

  SPoint get _maxPoint => _setting.maxPoint;
  SPoint get _snapPoint => _setting.snapPoint;
  SPoint get _minPoint => _setting.minPoint;

  List<SPoint> get _points => [
        _setting.minPoint,
        _setting.snapPoint,
        _setting.maxPoint,
      ];

  //controller.status == AnimationStatus.reverse;
  bool get _dismissUnderway => _animationController.isAnimating;
  bool get isFullyOpen => _initialOffset == _maxPoint.offset;
  bool get isSnapped => _initialOffset == _snapPoint.offset;
  bool get isMinimized => _value == _minPoint.offset;

  // 0.7 => When screen is fully open
  // midThreshold + 0.2 => When screen is halfway
  bool get _goToTop =>
      _value > (_maxPoint.offset - _maxPoint.snapThreshold) ||
      _value > _snapPoint.offset + _snapPoint.snapThreshold;

  // Move to center
  bool get _goToCenter =>
      isFullyOpen && _value < (_maxPoint.offset - _maxPoint.snapThreshold) ||
      isSnapped &&
          _animationController.isBetween(
            from: -_snapPoint.snapThreshold,
            to: _snapPoint.snapThreshold,
            offset: _snapPoint.offset,
          );

  // Move to bottm, i.e, close
  bool get _goToBottom =>
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
  void _onPointerDown(PointerDownEvent event) {
    // _initialOffset = double.parse(
    //   _value.toStringAsFixed(2),
    // );
    _initialOffset = _value;
    _initialPosition = event.localPosition;
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  ///
  void _onPointerMove(PointerMoveEvent event) {
    if (_dismissUnderway) return;
    final position = event.localPosition;
    final isClosing = _initialPosition.dy - position.dy < 0;
    _updateState(isClosing ? SDState.slidingDown : SDState.slidingUp);

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

    log('$canMoveFromTop : $canMoveFromMid');

    if (canMoveFromTop || canMoveFromMid) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset);
      }
      _animationController.value -= event.delta.dy / _childHeight;
    }

    _velocityTracker!.addPosition(event.timeStamp, event.position);
  }

  ///
  void _onPointerUp(PointerUpEvent event) {
    if (_dismissUnderway) return;
    final velocity = _velocityTracker!.getVelocity();
    _velocityTracker = null;

    var isClosing = false;

    // Fling movement
    if (velocity.pixelsPerSecond.dy.abs() > _minFlingVelocity) {
      // If scroll is in effect can't fling the sheet
      if (_isScrollInEffect(event.localPosition)) return;

      final flingVelocity = -velocity.pixelsPerSecond.dy / _childHeight;

      // -ve flingVelocity => close, +ve flingVelocity => open
      if (flingVelocity < 0.0) {
        isClosing = true;
      }

      final point = isFullyOpen && isClosing
          ? _snapPoint
          : isClosing
              ? _minPoint
              : _maxPoint;

      // _snapToPosition(point.offset);
      _animateTo(point);
    } else {
      final point = _targetPoint();
      if (point != null) {
        isClosing = point.offset == 0;
        // _snapToPosition(point.offset);
        _animateTo(point);
      }
    }

    // if (isClosing && onClosing != null) {
    //   onClosing();
    // }
  }

  SPoint? _targetPoint() {
    if (_goToTop) return _maxPoint;
    if (_goToCenter) return _snapPoint;
    if (_goToBottom) return _minPoint;
    return null;
  }

  void _animateTo(SPoint point) {
    _animationController.animateTo(
      point.offset,
      duration: point.duration ?? const Duration(milliseconds: 250),
      curve: point.curve ?? Curves.decelerate,
    );
  }

  void _close() {
    // _snapToPosition(
    //   _initialOffset == _maxPoint.offset ?
    //_snapPoint.offset : _minPoint.offset,
    // );
    _animateTo(
      _initialOffset == _maxPoint.offset ? _snapPoint : _minPoint,
    );
  }

  void _updateState(SDState state) {
    if (state == _state) return;
    _state = state;
    notifyListeners();
  }

  void _updatePoint(SPoint point) {
    if (point == _currentPoint) return;
    _currentPoint = point;
    notifyListeners();
  }

  // =========================== PUBLIC API ===========================
  // ==================================================================

  SDState get state => _state;

  SPoint get point => _currentPoint;

  ///
  Animation<double> get animation => _assert(_animationController);

  ///
  void open() {
    _state = SDState.min;
  }

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
    _initialized = false;
    _isDisposed = true;
    super.dispose();
  }
}

/// State of the panel
enum SDState {
  /// Panel is currently sliding up
  slidingUp,

  /// Panel is currently sliding down
  slidingDown,

  /// Panel is at its max size
  max,

  /// Panel is at its min size
  min,

  /// Panel is closed
  close,

  /// Panel is in pause state, where gesture will not work
  paused,
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

// mixin _GestureMixin {
//   late AnimationController _animationController;
//   late ScrollController _scrollController;
//   late SDraggableSetting _setting;
//   double get _childHeight;

//   double _initialOffset = 0;
//   Offset _initialPosition = Offset.zero;

//   SPoint get _maxPoint => _setting.maxPoint;
//   SPoint get _snapPoint => _setting.snapPoint;
//   SPoint get _minPoint => _setting.minPoint;

//   List<SPoint> get _points => [_minPoint, _snapPoint, _maxPoint];

//   //controller.status == AnimationStatus.reverse;
//   bool get _dismissUnderway => _animationController.isAnimating;
//   bool get isFullyOpen => _initialOffset == _maxPoint.offset;
//   bool get isSnapped => _initialOffset == _snapPoint.offset;
//   bool get isMinimized => _value == _minPoint.offset;

//   // 0.7 => When screen is fully open
//   // midThreshold + 0.2 => When screen is halfway
//   bool get _goToTop =>
//       _value > (_maxPoint.offset - _maxPoint.snapThreshold) ||
//       _value > _snapPoint.offset + _snapPoint.snapThreshold;

//   // Move to center
//   bool get _goToCenter =>
//       isFullyOpen && _value < (_maxPoint.offset - _maxPoint.snapThreshold) ||
//       isSnapped &&
//           _animationController.isBetween(
//             from: -_snapPoint.snapThreshold,
//             to: _snapPoint.snapThreshold,
//             offset: _snapPoint.offset,
//           );

//   // Move to bottm, i.e, close
//   bool get _goToBottom =>
//       _value < _snapPoint.offset - _snapPoint.snapThreshold; //0.15;

//   double get _value => _animationController.value;

//   //
//   bool _isScrollInEffect(Offset position) {
//     // +ve position.dy => Pointer is inside the view
//     // -ve position.dy => Pointer is outside the view
//     return _scrollController.hasClients &&
//         _scrollController.position.extentBefore > 0 &&
//         position.dy > 0;
//   }

//   ///
//   void _onDown({required Offset position}) {
//     // _initialOffset = double.parse(
//     //   _value.toStringAsFixed(2),
//     // );
//     log('$_initialOffset');
//     _initialOffset = _value;
//     _initialPosition = position;
//   }

//   VerticalDirection? _direction;

//   ///
//   void _move({required Offset delta, required Offset position}) {
//     if (_dismissUnderway) return;

//     final isClosing = _initialPosition.dy - position.dy < 0;
//     _direction = isClosing ? VerticalDirection.down : VerticalDirection.up;

//     // If sheet is closing and scrollable content is at top
//     // then can move gesture
//     final canMove = _scrollController.hasClients
//         ? isClosing && _scrollController.position.extentBefore <= 0
//         : isClosing;

//     late final canMoveFromTop = isFullyOpen && canMove;
//     // -ve Local position means pointer reached outside of the view,
//     late final crossHandler = position.dy < 0;
//     late final canMoveFromMid =
//         _initialOffset == _snapPoint.offset && (crossHandler || canMove);

//     log('$canMoveFromTop : $canMoveFromMid');

//     if (canMoveFromTop || canMoveFromMid) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.offset);
//       }
//       _animationController.value -= delta.dy / _childHeight;
//     }
//   }

//   ///
//   void _settle({
//     required Velocity velocity,
//     required Offset position,
//     VoidCallback? onClosing,
//   }) {
//     if (_dismissUnderway) return;

//     var isClosing = false;

//     // Fling movement
//     if (velocity.pixelsPerSecond.dy.abs() > _minFlingVelocity) {
//       // If scroll is in effect can't fling the sheet
//       if (_isScrollInEffect(position)) return;

//       final flingVelocity = -velocity.pixelsPerSecond.dy / _childHeight;

//       // -ve flingVelocity => close, +ve flingVelocity => open
//       if (flingVelocity < 0.0) {
//         isClosing = true;
//       }

//       final point = isFullyOpen && isClosing
//           ? _snapPoint
//           : isClosing
//               ? _minPoint
//               : _maxPoint;

//       // _snapToPosition(point.offset);
//       _animateTo(point);
//     } else {
//       final point = _targetPoint();
//       if (point != null) {
//         isClosing = point.offset == 0;
//         // _snapToPosition(point.offset);
//         _animateTo(point);
//       }
//     }

//     if (isClosing && onClosing != null) {
//       onClosing();
//     }
//   }

//   SPoint? _targetPoint() {
//     if (_goToTop) return _maxPoint;
//     if (_goToCenter) return _snapPoint;
//     if (_goToBottom) return _minPoint;
//     return null;
//   }

//   void _animateTo(SPoint point) {
//     _animationController.animateTo(
//       point.offset,
//       duration: point.duration ?? const Duration(milliseconds: 250),
//       curve: point.curve ?? Curves.decelerate,
//     );
//   }

//   void _close() {
//     // _snapToPosition(
//     //   _initialOffset == _maxPoint.offset ?
//     //_snapPoint.offset : _minPoint.offset,
//     // );
//     _animateTo(
//       _initialOffset == _maxPoint.offset ? _snapPoint : _minPoint,
//     );
//   }

//   // void _snapToPosition(double endValue, {double? startValue}) {
//   //   final Simulation simulation = SpringSimulation(
//   //     SpringDescription.withDampingRatio(
//   //       mass: 1,
//   //       stiffness: 600,
//   //       ratio: 1.1,
//   //     ),
//   //     startValue ?? _value,
//   //     endValue,
//   //     0,
//   //   );
//   //   _animationController.animateWith(simulation);
//   // }
// }
