import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

///
enum SlidingState {
  ///
  slidingUp,

  ///
  slidingDown,

  ///
  max,

  ///
  min,

  ///
  close,

  ///
  paused,
}

///
const double kDefaultSnapingPoint = 0.4;

///
const double kPanelHeaderMinHeight = 25.0;

///
const double kPanelHeaderMaxHeight = 75.0;

///
class SlidablePanel extends StatefulWidget {
  ///
  const SlidablePanel({
    Key? key,
    this.controller,
    this.panelHeaderMaxHeight,
    this.panelHeaderMinHeight,
    this.panelMinHeight,
    this.panelMaxHeight,
    this.snapingPoint,
    this.child,
  }) : super(key: key);

  ///
  final Widget? child;

  ///
  final double? panelHeaderMaxHeight;

  ///
  final double? panelHeaderMinHeight;

  ///
  final double? panelMinHeight;

  ///
  final double? panelMaxHeight;

  /// Between 0.0 and 1.0
  final double? snapingPoint;

  ///
  final PanelController? controller;

  @override
  _SlidablePanelState createState() => _SlidablePanelState();
}

class _SlidablePanelState extends State<SlidablePanel>
    with TickerProviderStateMixin {
  // late double _statusBarHeight;
  late double _panelHeaderMinHeight;
  late double _panelHeaderMaxHeight;
  late double _panelMinHeight;
  late double _panelMaxHeight;
  late double _remainingSpace;

  //
  late PanelController _panelController;

  // Scroll controller
  late ScrollController _scrollController;

  // Animation controller
  late AnimationController _animationController;

  // Tracking pointer velocity for snaping panel
  VelocityTracker? _velocityTracker;

  // Initial position of pointer
  var _pointerInitialPosition = Offset.zero;

  // true, if panel can be scrolled to bottom
  var _scrollToBottom = false;

  // true, if panel can be scrolled to top
  var _scrollToTop = false;

  // Initial position of pointer before scrolling panel to min height.
  var _pointerPositionBeforeScroll = Offset.zero;

  // true, if pointer is above halfway of the screen, false otherwise.
  bool get _aboveHalfWay =>
      _panelController.value.factor >
      (widget.snapingPoint ?? kDefaultSnapingPoint);

  @override
  void initState() {
    super.initState();

    _panelHeaderMinHeight =
        widget.panelHeaderMinHeight ?? kPanelHeaderMinHeight;
    _panelHeaderMaxHeight =
        widget.panelHeaderMaxHeight ?? kPanelHeaderMaxHeight;
    _panelMaxHeight = widget.panelMaxHeight!;
    _panelMinHeight = widget.panelMinHeight!;

    // Initialization of panel controller
    _panelController = (widget.controller ?? PanelController()).._init(this);

    _scrollController = _panelController.scrollController;

    if (_scrollController.hasClients) {
      _scrollController.addListener(() {
        if (_scrollToTop || _scrollToBottom && _scrollController.hasClients) {
          _scrollController.position.hold(() {});
        }
      });
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        _panelController.attach(SliderValue(
          factor: _animationController.value,
          state: _aboveHalfWay ? SlidingState.max : SlidingState.min,
        ));
      });
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerInitialPosition = event.position;
    _velocityTracker ??= VelocityTracker.withKind(event.kind);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_panelController.isGestureEnabled) return;

    if (_animationController.isAnimating) return;

    if (!_shouldScroll(event.position.dy)) return;

    _velocityTracker!.addPosition(event.timeStamp, event.position);

    final state = _pointerInitialPosition.dy - event.position.dy < 0.0
        ? SlidingState.slidingDown
        : SlidingState.slidingUp;
    final panelState = _panelController.value.state;
    final mediaQuery = MediaQuery.of(context);

    if (!_scrollToTop &&
        panelState == SlidingState.min &&
        state == SlidingState.slidingUp) {
      final pointerReachedHandler =
          (mediaQuery.size.height - event.position.dy) > _panelMinHeight;
      _scrollToTop = pointerReachedHandler;
    }

    if (!_scrollToBottom &&
        panelState == SlidingState.max &&
        state == SlidingState.slidingDown) {
      final isControllerOffsetZero =
          _scrollController.hasClients ? _scrollController.offset == 0.0 : true;
      final headerMinPosition = mediaQuery.padding.top;
      final headerMaxPosition = headerMinPosition + _panelHeaderMaxHeight;
      final isHandler = event.position.dy >= headerMinPosition &&
          event.position.dy <= headerMaxPosition;
      _scrollToBottom = isHandler || isControllerOffsetZero;
      if (_scrollToBottom) {
        _pointerPositionBeforeScroll = event.position;
      }
    }

    if (_scrollToTop || _scrollToBottom) {
      final startingPX = event.position.dy -
          (_scrollToTop
              ? _panelHeaderMinHeight
              : _pointerPositionBeforeScroll.dy);
      final num remainingPX =
          (_remainingSpace - startingPX).clamp(0.0, _remainingSpace);

      final num factor = (remainingPX / _remainingSpace).clamp(0.0, 1.0);
      _slidePanelWithPosition(factor as double, state);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_panelController.isGestureEnabled) return;

    if (_animationController.isAnimating) return;

    if (!_shouldScroll(event.position.dy)) return;

    final velocity = _velocityTracker!.getVelocity();

    if (_scrollToTop || _scrollToBottom) {
      // +ve velocity -> top to bottom
      // -ve velocity -> bottom to top
      final dyVelocity = velocity.pixelsPerSecond.dy;
      final flingPanel = dyVelocity.abs() > 800.0;
      final endValue = flingPanel
          ? (dyVelocity.isNegative ? 1.0 : 0.0)
          : (_aboveHalfWay ? 1.0 : 0.0);
      _snapToPosition(endValue);
    }

    _scrollToTop = false;
    _scrollToBottom = false;
    _pointerInitialPosition = Offset.zero;
    _pointerPositionBeforeScroll = Offset.zero;
    _velocityTracker = null;
  }

  // If pointer is moved by more than 2 px then only begain
  bool _shouldScroll(double currentDY) {
    return (currentDY.abs() - _pointerInitialPosition.dy.abs()).abs() > 2.0;
  }

  void _slidePanelWithPosition(double factor, SlidingState state) {
    _panelController.attach(SliderValue(
      factor: factor,
      state: state,
    ));
  }

  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 600.0,
        ratio: 1.1,
      ),
      startValue ?? _panelController.value.factor,
      endValue,
      0,
    );
    _animationController.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    // final _mediaQuery = MediaQuery.of(context);
    /// When making slidable different package then only set size from here
    // _panelMaxHeight = widget.panelMaxHeight ?? constraints.maxHeight;
    // _panelMinHeight = widget.panelMinHeight ?? _panelMaxHeight * 0.35;
    _remainingSpace = _panelMaxHeight - _panelMinHeight;

    return ValueListenableBuilder<bool>(
      valueListenable: _panelController.panelVisibility,
      builder: (context, bool isVisible, child) {
        return isVisible ? child! : const SizedBox();
      },
      child: Column(
        children: [
          // Status bar space
          // SizedBox(height: _mediaQuery.padding.top),

          // Space between sliding panel and status bar
          const Spacer(),

          // Sliding panel
          ValueListenableBuilder(
            valueListenable: _panelController,
            builder: (context, SliderValue value, child) {
              final height =
                  (_panelMinHeight + (_remainingSpace * value.factor))
                      .clamp(_panelMinHeight, _panelMaxHeight);
              return SizedBox(height: height, child: child);
            },
            child: Listener(
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
              child: widget.child ?? const SizedBox(),
            ),
          ),

          ///
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  //
}

///
class PanelController extends ValueNotifier<SliderValue> {
  ///
  PanelController({
    ScrollController? scrollController,
  })  : _scrollController = scrollController ?? ScrollController(),
        super(SliderValue());

  final ScrollController _scrollController;

  ///
  ScrollController get scrollController => _scrollController;

  late _SlidablePanelState _state;

  void _init(_SlidablePanelState state) {
    _state = state;
  }

  /// todo : make this getter only
  ValueNotifier<bool> panelVisibility = ValueNotifier(false);
  // bool get

  bool _gesture = true;

  ///
  double? get headerMinHeight => _state._panelHeaderMinHeight;

  ///
  double? get headerMaxHeight => _state._panelHeaderMaxHeight;

  ///
  double? get panelMinHeight => _state._panelMinHeight;

  ///
  double? get panelMaxHeight => _state._panelMaxHeight;

  ///
  SlidingState get panelState => value.state;

  /// If panel is open return true, otherwise false
  bool get isVisible => panelVisibility.value;

  ///
  bool get isGestureEnabled => _gesture;

  set isGestureEnabled(bool isEnable) {
    if (isGestureEnabled && isEnable) return;
    _gesture = isEnable;
  }

  /// Minimize panel
  void openPanel() {
    if (value.state == SlidingState.min) return;
    value = value.copyWith(state: SlidingState.min);
    panelVisibility.value = true;
  }

  /// Maximize panel
  void maximizePanel() {
    if (value.state == SlidingState.max) return;
    _state._snapToPosition(1.0);
  }

  ///
  void minimizePanel() {
    if (value.state == SlidingState.min) return;
    _state._snapToPosition(0.0);
  }

  /// Close Panel
  void closePanel() {
    if (value.state == SlidingState.close) return;
    value = value.copyWith(state: SlidingState.close);
    panelVisibility.value = false;
  }

  ///
  void pausePanel() {
    if (value.state == SlidingState.paused) return;
    value = value.copyWith(state: SlidingState.paused);
    panelVisibility.value = false;
  }

  ///
  void attach(SliderValue sliderValue) {
    value = value.copyWith(
      factor: sliderValue.factor,
      offset: sliderValue.offset,
      position: sliderValue.position,
      state: sliderValue.state,
    );
  }

  @override
  set value(SliderValue newValue) {
    super.value = newValue;
  }

  @override
  void dispose() {
    panelVisibility.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //
}

///
class SliderValue {
  ///
  SliderValue({
    this.state = SlidingState.close,
    this.factor = 0.0,
    this.offset = 0.0,
    this.position = Offset.zero,
  });

  /// Sliding state
  final SlidingState state;

  /// From 0.0 - 1.0
  final double factor;

  /// Height of the panel
  final double offset;

  /// Position of the panel
  final Offset position;

  ///
  SliderValue copyWith({
    SlidingState? state,
    double? factor,
    double? offset,
    Offset? position,
  }) {
    return SliderValue(
      state: state ?? this.state,
      factor: factor ?? this.factor,
      offset: offset ?? this.offset,
      position: position ?? this.position,
    );
  }
}
