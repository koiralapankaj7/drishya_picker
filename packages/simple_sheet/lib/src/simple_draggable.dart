// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const _defaultDuration = Duration(milliseconds: 250);

///
typedef DraggableWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

const double _minFlingVelocity = 800;
const _maxPoint = SPoint(offset: 1);
const _snapPoint = SPoint(offset: 0.45);
const _minPoint = SPoint();

///
class SimpleDraggable extends StatefulWidget {
  ///
  const SimpleDraggable({
    required this.builder,
    this.controller,
    this.scrollController,
    this.byPosition = false,
    this.delegate,
    super.key,
  });

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final DraggableWidgetBuilder builder;

  ///
  final SDController? controller;

  ///
  final ScrollController? scrollController;

  ///
  final bool byPosition;

  ///
  final SimpleDraggableDelegate? delegate;

  @override
  State<SimpleDraggable> createState() => _SimpleDraggableState();
}

///
class _SimpleDraggableState extends State<SimpleDraggable>
    with TickerProviderStateMixin {
  final _childKey = GlobalKey(debugLabel: 'SimpleDraggable child');
  late SDController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    log('_SimpleDraggableState.initState');
    _controller = widget.controller ?? SDController(vsync: this);
    _scrollController = widget.scrollController ?? ScrollController();
    _initController();
  }

  void _initController() {
    _controller._init(
      childKey: _childKey,
      scrollController: _scrollController,
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
      _controller = widget.controller ?? SDController(vsync: this);
      needsUpdate = true;
    }

    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController == null) {
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
      needsUpdate = true;
    }

    if (needsUpdate) {
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

  @override
  Widget build(BuildContext context) {
    // return widget.builder(context, _scrollController);
    final handler =
        (widget.delegate ?? const _DefaultDelegate()).buildHandler(context);

    return Material(
      type: MaterialType.transparency,
      key: _childKey,
      child: WillPopScope(
        onWillPop: () async {
          if (_controller.animation.value <= 0.0) return true;
          await _controller.close();
          return true;
        },
        child: AnimatedBuilder(
          animation: _controller.animation,
          builder: (context, child) {
            if (handler != null) {
              return CustomMultiChildLayout(
                delegate: _LayoutDelegate(
                  progress: _controller.animation.value,
                  byPosition: widget.byPosition,
                  controller: _controller,
                ),
                children: [
                  // Handler
                  LayoutId(
                    id: _Type.handler,
                    child: Listener(
                      onPointerDown: _controller._onPointerDown,
                      onPointerMove: _controller._onHandlerMove,
                      onPointerUp: _controller._onPointerUp,
                      behavior: HitTestBehavior.translucent,
                      child: handler,
                    ),
                  ),

                  // Body
                  LayoutId(
                    id: _Type.body,
                    child: SizedBox.expand(child: child),
                  ),
                ],
              );
            }

            // Position based
            if (widget.byPosition) {
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
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                overscroll: false,
              ),
              child: Listener(
                onPointerDown: _controller._onPointerDown,
                onPointerMove: _controller._onPointerMove,
                onPointerUp: _controller._onPointerUp,
                behavior: HitTestBehavior.translucent,
                child: widget.builder(context, _scrollController),
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

enum _Type { handler, body }

class _LayoutDelegate extends MultiChildLayoutDelegate {
  _LayoutDelegate({
    required this.progress,
    required this.byPosition,
    required this.controller,
  });

  final double progress;
  final bool byPosition;
  final SDController controller;

  final _handlerHeight = 21;

  // Size based layout
  void _sizeBased(Size size) {
    final max = controller.maxPoint.offset;
    final snap = controller.snapPoint.offset;

    final visibleHeight = size.height * progress;
    final looseConstraints = BoxConstraints.loose(size);

    final remaining = (max - progress) / (max - snap);
    var handlerSize = Size.zero;

    // Handler
    if (hasChild(_Type.handler)) {
      handlerSize = layoutChild(_Type.handler, looseConstraints);
      positionChild(
        _Type.handler,
        Offset(0, size.height - visibleHeight),
        // Offset.zero,
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
        // Offset(
        //   0,
        //   _handlerHeight +
        //       (handlerSize.height - _handlerHeight) *
        //           (1 - remaining).clamp(0, 1),
        // ),
      );
    }
  }

  // Position based layout
  void _positionBased(Size size) {
    final max = controller.maxPoint.offset;
    final min = controller.snapPoint.offset;
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
    byPosition ? _positionBased(size) : _sizeBased(size);
    // // Layout scrim
    // if (hasChild(_Type.scrim)) {
    //   layoutChild(_Type.scrim, BoxConstraints.tight(size));
    //   positionChild(
    //     _Type.scrim,
    //     Offset(0, size.height - size.height * progress),
    //   );
    // }
  }

  @override
  bool shouldRelayout(covariant _LayoutDelegate oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.byPosition != byPosition;
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
    this.snapThreshold = 0.15,
    // this.minFlingVelocity = 800,
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

  ///
  // final double minFlingVelocity;

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
class SDController extends ChangeNotifier {
  SDController({
    required TickerProvider vsync,
    this.maxPoint = _maxPoint,
    this.snapPoint = _snapPoint,
    this.minPoint = _minPoint,
    this.initialPoint = _minPoint,
  }) : assert(
          initialPoint >= minPoint && initialPoint <= maxPoint,
          'Initial point must be between minimum and maximum point.',
        ) {
    log('Controller init ==>>');
    _animationController = AnimationController(
      vsync: vsync,
      duration: initialPoint.duration ?? _defaultDuration,
      reverseDuration: initialPoint.duration ?? _defaultDuration,
      value: initialPoint.offset,
    );
    _currentPoint = initialPoint;
  }

  ///
  final SPoint maxPoint;

  ///
  final SPoint snapPoint;

  ///
  final SPoint minPoint;

  ///
  final SPoint initialPoint;

  late final AnimationController _animationController;
  late SPoint _currentPoint;

  late GlobalKey<State<StatefulWidget>> _childKey;
  late ScrollController _scrollController;

  var _isDisposed = false;
  // SDState _state = SDState.close;
  VelocityTracker? _velocityTracker;
  // double _initialOffset = 0;
  // Offset _initialPosition = Offset.zero;

  void _init({
    required GlobalKey<State<StatefulWidget>> childKey,
    required ScrollController scrollController,
  }) {
    _childKey = childKey;
    _scrollController = scrollController;
  }

  double get _childHeight {
    final renderBox =
        _childKey.currentContext!.findRenderObject()! as RenderBox;
    return renderBox.size.height;
  }

  List<SPoint> get _points => [
        minPoint,
        snapPoint,
        maxPoint,
      ];

  bool get _underway => _animationController.isAnimating;
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
    // _initialOffset = _value;
    // _initialPosition = event.localPosition;
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  void _onHandlerMove(PointerMoveEvent event) {
    if (_underway) return;
    _animationController.value -= event.delta.dy / _childHeight;
    _velocityTracker!.addPosition(event.timeStamp, event.position);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_underway) return;
    final position = event.localPosition;

    if (_isScrollInEffect(position)) {
      final reachedHandler = position.dy - 20 < 0;
      if (reachedHandler) {
        _scrollController.jumpTo(_scrollController.offset);
        _animationController.value -= event.delta.dy / _childHeight;
      }
    } else {
      _animationController.value -= event.delta.dy / _childHeight;
    }

    _velocityTracker!.addPosition(event.timeStamp, event.position);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_underway) return;
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

      late SPoint nextPoint;
      final index = _points.indexOf(_currentPoint);
      if (isClosing) {
        nextPoint = index > 0 ? _points[index - 1] : _currentPoint;
      } else {
        nextPoint =
            index < _points.length - 1 ? _points[index + 1] : _currentPoint;
      }
      _updatePoint(nextPoint);
    } else {
      final nextPoint = _points.firstWhere(
        (p) =>
            _value > p.offset - p.snapThreshold &&
            _value < p.offset + p.snapThreshold,
        orElse: () => _currentPoint,
      );
      _updatePoint(nextPoint);
    }
  }

  // void _updateState(SDState state) {
  //   if (state == _state) return;
  //   _state = state;
  //   notifyListeners();
  // }

  TickerFuture _updatePoint(SPoint point) {
    final duration = point.duration ?? _defaultDuration;
    // final full = (_currentPoint.offset - _value).abs();
    // final newDuration = duration.inMilliseconds * full / point.offset;
    TickerFuture.complete();
    return _animationController.animateTo(
      point.offset,
      duration: duration,
      curve: point.curve ?? Curves.decelerate,
    )..then((value) {
        if (point == _currentPoint) return;
        _currentPoint = point;
        notifyListeners();
      });
  }

  // =========================== PUBLIC API ===========================
  // ==================================================================

  // SDState get state => _state;

  SPoint get point => _currentPoint;

  ///
  Animation<double> get animation => _animationController;

  ///
  TickerFuture open() => _updatePoint(snapPoint);

  ///
  TickerFuture close() => _updatePoint(_minPoint);

  ///
  TickerFuture animateTo(SPoint point) => _updatePoint(point);

  ///
  void moveTo(SPoint point) => _animationController.value = point.offset;

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
    log('Controller disposed ==>>');
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

/// ===================NEW======================

class SimpleDraggableScopeNew extends StatefulWidget {
  ///
  const SimpleDraggableScopeNew({
    required this.child,
    super.key,
  });

  ///
  final Widget child;

  @override
  State<SimpleDraggableScopeNew> createState() =>
      _SimpleDraggableScopeNewState();
}

class _SimpleDraggableScopeNewState extends State<SimpleDraggableScopeNew> {
  SDController? _controller;

  Future<void> _update(SDController? controller) async {
    await null;
    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return widget.child;

    return AnimatedBuilder(
      animation: _controller!.animation,
      builder: (context, child) {
        return FractionallySizedBox(
          heightFactor: (1 - _controller!.animation.value)
              .clamp(1 - _controller!.snapPoint.offset, 1),
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

///
class DraggableRoute<T> extends ModalRoute<T> {
  DraggableRoute({
    // required this.simpleDraggable,
    required this.child,
  }) {
    // print(context);
    // _state = context.findAncestorStateOfType<_SimpleDraggableScopeNewState>();
  }

  final Widget child;

  // final SimpleDraggable simpleDraggable;
//  SDController? controller,
//   ScrollController? scrollController,
//   bool byPosition = false,
//   SimpleDraggableDelegate? delegate,

  // late SDController _controller;
  // _SimpleDraggableScopeNewState? _state;

  @override
  void install() {
    super.install();
    log('install');
    // _controller = simpleDraggable.controller ?? SDController(vsync: navigator!);
  }

  // void _upodateState(BuildContext context) {
  //   if (_state != null) return;
  //   _state = subtreeContext!
  //       .findAncestorStateOfType<_SimpleDraggableScopeNewState>();
  //   _state?._update(_controller);
  // }

  // @override
  // void dispose() {
  //   log('dispose');
  //   _state?._update(null);
  //   _state = null;
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  bool get allowSnapshotting => false;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    log('buildPage');
    // return const Material(
    //   color: Colors.amber,
    // );
    // _upodateState(subtreeContext!);
    return Material(
      type: MaterialType.transparency,
      // child: SimpleDraggable(
      //   controller: _controller,
      //   builder: (context, controller) {
      //     return Container();
      //   },
      //   byPosition: simpleDraggable.byPosition,
      //   delegate: simpleDraggable.delegate,
      //   scrollController: simpleDraggable.scrollController,
      // ),
      child: child,
    );
  }

  // @override
  // TickerFuture didPush() {
  //   log('didPush');
  //   Future.delayed(Duration.zero, _controller.open);
  //   return super.didPush();
  // }

  // @override
  // bool didPop(T? result) {
  //   log('didPop');
  //   if (_controller.animation.value > 0) {
  //     _controller.close().then((_) => navigator!.pop(result));
  //     return false;
  //   }
  //   return super.didPop(result);
  // }

  @override
  List<OverlayEntry> get overlayEntries {
    return [
      // OverlayEntry(
      //   builder: (context) => GestureDetector(
      //     onTap: navigator!.pop,
      //     behavior: HitTestBehavior.translucent,
      //     child: const SizedBox.expand(),
      //   ),
      // ),
      super.overlayEntries.last,
    ];
  }
}

///
Future<T?> showSimpleDraggableSheet<T>({
  required BuildContext context,
  required DraggableWidgetBuilder builder,
  SDController? controller,
  ScrollController? scrollController,
  bool byPosition = false,
  SimpleDraggableDelegate? delegate,
}) {
  final widget = _TestWrapper(
    scopeState:
        context.findAncestorStateOfType<_SimpleDraggableScopeNewState>(),
    builder: (c) {
      return SimpleDraggable(
        builder: builder,
        controller: c,
        scrollController: scrollController,
        byPosition: byPosition,
        delegate: delegate,
      );
    },
  );
  return Navigator.of(context).push<T>(
    DraggableRoute<T>(
      // context,
      // simpleDraggable: SimpleDraggable(
      //   builder: builder,
      //   controller: controller,
      //   scrollController: scrollController,
      //   byPosition: byPosition,
      //   delegate: delegate,
      // ),
      child: widget,
    ),
  );
}

class _TestWrapper extends StatefulWidget {
  const _TestWrapper({
    required this.builder,
    this.scopeState,
  });

  final Widget Function(SDController controller) builder;

  final _SimpleDraggableScopeNewState? scopeState;

  @override
  State<_TestWrapper> createState() => _TestWrapperState();
}

class _TestWrapperState extends State<_TestWrapper>
    with TickerProviderStateMixin {
  late SDController controller;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    TickerFuture.complete();
    controller = SDController(vsync: this);
    // Future.delayed(Duration.zero, controller.open);
    TickerFuture.complete();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    widget.scopeState?._update(controller);
    WidgetsBinding.instance.endOfFrame.then((value) {
      controller.open();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    widget.scopeState?._update(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        print(_animationController.value);
        return child!;
      },
      child: widget.builder(controller),
    );
  }
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
