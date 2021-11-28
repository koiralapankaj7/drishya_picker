import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

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
/// Settings for gallery panel
///
class PanelSetting {
  ///
  const PanelSetting({
    this.topMargin,
    this.headerMaxHeight = 75.0,
    this.headerMinHeight = 25.0,
    this.minHeight,
    this.maxHeight,
    this.snapingPoint = 0.4,
    this.headerBackground = Colors.black,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.black,
    this.overlayStyle = SystemUiOverlayStyle.light,
  }) : assert(
          snapingPoint >= 0.0 && snapingPoint <= 1.0,
          '[snapingPoint] value must be between 1.0 and 0.0',
        );

  /// Margin for panel top. Which can be used to show status bar if you need
  /// to show panel above scaffold.
  final double? topMargin;

  /// Panel maximum height
  ///
  /// mediaQuery = MediaQuery.of(context)
  /// Default: mediaQuery.size.height -  mediaQuery.padding.top
  final double? maxHeight;

  /// Panel minimum height
  /// Default: 35% of [maxHeight]
  final double? minHeight;

  /// Panel header maximum size
  ///
  /// Default: 75.0 px
  final double headerMaxHeight;

  /// Panel header minimum size,
  ///
  /// which will be use as panel scroll handler
  /// Default: 25.0 px
  final double headerMinHeight;

  /// Point from where panel will start fling animation to snap it's height
  ///
  /// Value must be between 0.0 - 1.0
  /// Default: 0.4
  final double snapingPoint;

  /// Background color for panel header,
  /// Default: [Colors.black]
  final Color headerBackground;

  /// Background color for panel,
  /// Default: [Colors.black]
  final Color foregroundColor;

  /// If [headerBackground] is missing [backgroundColor] will be applied
  /// If [foregroundColor] is missing [backgroundColor] will be applied
  ///
  /// Default: [Colors.black]
  final Color backgroundColor;

  ///
  final SystemUiOverlayStyle overlayStyle;

  /// Helper function
  PanelSetting copyWith({
    double? topMargin,
    double? headerMaxHeight,
    double? headerMinHeight,
    double? minHeight,
    double? maxHeight,
    double? snapingPoint,
    Color? headerBackground,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return PanelSetting(
      topMargin: topMargin ?? this.topMargin,
      headerMaxHeight: headerMaxHeight ?? this.headerMaxHeight,
      headerMinHeight: headerMinHeight ?? this.headerMinHeight,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      snapingPoint: snapingPoint ?? this.snapingPoint,
      headerBackground: headerBackground ?? this.headerBackground,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

///
class SlidablePanel extends StatefulWidget {
  ///
  const SlidablePanel({
    Key? key,
    this.controller,
    this.setting,
    this.child,
  }) : super(key: key);

  ///
  final PanelSetting? setting;

  ///
  final Widget? child;

  ///
  final PanelController? controller;

  @override
  State<SlidablePanel> createState() => _SlidablePanelState();
}

class _SlidablePanelState extends State<SlidablePanel>
    with TickerProviderStateMixin {
  late double _panelMinHeight;
  late double _panelMaxHeight;
  late double _remainingSpace;
  late MediaQueryData _mediaQuery;
  late PanelSetting _setting;

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
      _panelController.value.factor > (_setting.snapingPoint);

  @override
  void initState() {
    super.initState();
    _setting = widget.setting ?? const PanelSetting();

    // Initialization of panel controller
    _panelController = (widget.controller ?? PanelController()).._init(this);

    _scrollController = _panelController.scrollController
      ..addListener(() {
        if ((_scrollToTop || _scrollToBottom) && _scrollController.hasClients) {
          _scrollController.position.hold(() {});
        }
      });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        _panelController.attach(
          SliderValue(
            factor: _animationController.value,
            state: _aboveHalfWay ? SlidingState.max : SlidingState.min,
          ),
        );
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
          _scrollController.hasClients && _scrollController.offset == 0.0;

      // final isControllerOffsetZero = _scrollController.hasClients
      //     ? _scrollController.offset == 0.0
      //     : false;
      // final headerMinPosition = mediaQuery.padding.top;
      // final headerMaxPosition = headerMinPosition + _panelHeaderMaxHeight;
      // final isHandler = event.position.dy >= headerMinPosition &&
      //     event.position.dy <= headerMaxPosition;
      // _scrollToBottom = isHandler || isControllerOffsetZero;

      final headerMinPosition = _mediaQuery.size.height - _panelMaxHeight;
      final headerMaxPosition = headerMinPosition + _setting.headerMaxHeight;
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
              ? _setting.headerMinHeight
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
    _panelController.attach(
      SliderValue(
        factor: factor,
        state: state,
      ),
    );
  }

  void _snapToPosition(double endValue, {double? startValue}) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: 600,
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
    _mediaQuery = MediaQuery.of(context);
    _panelMaxHeight = _setting.maxHeight ??
        _mediaQuery.size.height -
            (_setting.topMargin ?? _mediaQuery.padding.top);
    _panelMinHeight = _setting.minHeight ?? _panelMaxHeight * 0.35;
    _remainingSpace = _panelMaxHeight - _panelMinHeight;

    return ValueListenableBuilder<bool>(
      valueListenable: _panelController._panelVisibility,
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
        _panelVisibility = ValueNotifier(false),
        super(SliderValue());

  final ScrollController _scrollController;
  final ValueNotifier<bool> _panelVisibility;

  late _SlidablePanelState _state;

  // ignore: use_setters_to_change_properties
  void _init(_SlidablePanelState state) {
    _state = state;
  }

  bool _gesture = true;
  bool _internal = true;

  ///
  ScrollController get scrollController => _scrollController;

  ///
  ValueNotifier<bool> get panelVisibility => _panelVisibility;

  ///
  SlidingState get panelState => value.state;

  /// If panel is open return true, otherwise false
  bool get isVisible => _panelVisibility.value;

  ///
  bool get isGestureEnabled => _gesture;

  set isGestureEnabled(bool isEnable) {
    if (isGestureEnabled && isEnable) return;
    _gesture = isEnable;
  }

  /// Minimize panel
  void openPanel() {
    _internal = true;
    if (value.state == SlidingState.min) return;
    value = value.copyWith(
      state: SlidingState.min,
      factor: 0,
      offset: 0,
      position: Offset.zero,
    );
    _panelVisibility.value = true;
    _gesture = true;
    _internal = false;
  }

  /// Maximize panel
  void maximizePanel() {
    if (value.state == SlidingState.max) return;
    _state._snapToPosition(1);
  }

  ///
  void minimizePanel() {
    if (value.state == SlidingState.min) return;
    _state._snapToPosition(0);
  }

  /// Close Panel
  void closePanel() {
    _internal = true;
    if (value.state == SlidingState.close) return;
    value = value.copyWith(
      state: SlidingState.close,
      factor: 0,
      offset: 0,
      position: Offset.zero,
    );
    _panelVisibility.value = false;
    _gesture = false;
    _internal = false;
  }

  ///
  void pausePanel() {
    _internal = true;
    if (value.state == SlidingState.paused) return;
    value = value.copyWith(state: SlidingState.paused);
    _panelVisibility.value = false;
    _internal = false;
  }

  ///
  void attach(SliderValue sliderValue) {
    _internal = true;
    value = value.copyWith(
      factor: sliderValue.factor,
      offset: sliderValue.offset,
      position: sliderValue.position,
      state: sliderValue.state,
    );
    _internal = false;
  }

  @override
  set value(SliderValue newValue) {
    if (!_internal) return;
    super.value = newValue;
  }

  @override
  void dispose() {
    _panelVisibility.dispose();
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
