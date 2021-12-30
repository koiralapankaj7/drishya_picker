import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// State of the panel
enum PanelState {
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
/// Settings for gallery panel
@immutable
class PanelSetting {
  ///
  const PanelSetting({
    this.maxHeight,
    this.minHeight,
    this.headerHeight = kToolbarHeight,
    this.thumbHandlerHeight = 25.0,
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
  // final double? topMargin;

  /// Panel maximum height
  ///
  /// mediaQuery = MediaQuery.of(context)
  /// Default: mediaQuery.size.height -  mediaQuery.padding.top
  final double? maxHeight;

  /// Panel minimum height
  /// Default: 37% of [maxHeight]
  final double? minHeight;

  /// Panel header height
  ///
  /// Default:  [kToolbarHeight]
  final double headerHeight;

  /// Panel thumb handler height, which will be used to drag the panel
  ///
  /// Default: 25.0 px
  final double thumbHandlerHeight;

  /// Point from where panel will start fling animation to snap it's height
  /// to [minHeight] or [maxHeight]
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

  /// Header max height
  double get headerMaxHeight => thumbHandlerHeight + headerHeight;

  /// Helper function
  PanelSetting copyWith({
    double? maxHeight,
    double? minHeight,
    double? headerHeight,
    double? thumbHandlerHeight,
    double? snapingPoint,
    Color? headerBackground,
    Color? foregroundColor,
    Color? backgroundColor,
    SystemUiOverlayStyle? overlayStyle,
  }) {
    return PanelSetting(
      maxHeight: maxHeight ?? this.maxHeight,
      minHeight: minHeight ?? this.minHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      thumbHandlerHeight: thumbHandlerHeight ?? this.thumbHandlerHeight,
      snapingPoint: snapingPoint ?? this.snapingPoint,
      headerBackground: headerBackground ?? this.headerBackground,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overlayStyle: overlayStyle ?? this.overlayStyle,
    );
  }

  @override
  String toString() {
    return '''
    PanelSetting(
      maxHeight: $maxHeight, 
      minHeight: $minHeight, 
      headerHeight: $headerHeight, 
      thumbHandlerHeight: $thumbHandlerHeight, 
      snapingPoint: $snapingPoint, 
      headerBackground: $headerBackground, 
      foregroundColor: $foregroundColor, 
      backgroundColor: $backgroundColor, 
      overlayStyle: $overlayStyle
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PanelSetting &&
        other.maxHeight == maxHeight &&
        other.minHeight == minHeight &&
        other.headerHeight == headerHeight &&
        other.thumbHandlerHeight == thumbHandlerHeight &&
        other.snapingPoint == snapingPoint &&
        other.headerBackground == headerBackground &&
        other.foregroundColor == foregroundColor &&
        other.backgroundColor == backgroundColor &&
        other.overlayStyle == overlayStyle;
  }

  @override
  int get hashCode {
    return maxHeight.hashCode ^
        minHeight.hashCode ^
        headerHeight.hashCode ^
        thumbHandlerHeight.hashCode ^
        snapingPoint.hashCode ^
        headerBackground.hashCode ^
        foregroundColor.hashCode ^
        backgroundColor.hashCode ^
        overlayStyle.hashCode;
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
  late Size _size;
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
          PanelValue(
            factor: _animationController.value,
            state: _aboveHalfWay ? PanelState.max : PanelState.min,
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
        ? PanelState.slidingDown
        : PanelState.slidingUp;
    final panelState = _panelController.value.state;
    final mediaQuery = MediaQuery.of(context);

    if (!_scrollToTop &&
        panelState == PanelState.min &&
        state == PanelState.slidingUp) {
      final pointerReachedHandler =
          (mediaQuery.size.height - event.position.dy) > _panelMinHeight;
      _scrollToTop = pointerReachedHandler;
    }

    if (!_scrollToBottom &&
        panelState == PanelState.max &&
        state == PanelState.slidingDown) {
      final isControllerOffsetZero =
          _scrollController.hasClients && _scrollController.offset == 0.0;

      final headerMinPosition = _size.height - _panelMaxHeight;
      final headerMaxPosition = headerMinPosition + _setting.headerHeight;
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
              ? _setting.thumbHandlerHeight
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

  void _slidePanelWithPosition(double factor, PanelState state) {
    _panelController.attach(
      PanelValue(
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);

        _size = constraints.biggest;
        _panelMaxHeight =
            _setting.maxHeight ?? _size.height - mediaQuery.padding.top;
        _panelMinHeight = _setting.minHeight ?? _panelMaxHeight * 0.37;
        _remainingSpace = _panelMaxHeight - _panelMinHeight;

        return ValueListenableBuilder<bool>(
          valueListenable: _panelController._panelVisibility,
          builder: (context, bool isVisible, child) {
            return isVisible ? child! : const SizedBox();
          },
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  // Space between sliding panel and status bar
                  const Spacer(),

                  // Sliding panel
                  ValueListenableBuilder(
                    valueListenable: _panelController,
                    builder: (context, PanelValue value, child) {
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
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.controller == null) {
      _panelController.dispose();
    }
    super.dispose();
  }
  //
}

/// Sliding panel controller
class PanelController extends ValueNotifier<PanelValue> {
  ///
  PanelController({
    ScrollController? scrollController,
  })  : _scrollController = scrollController ?? ScrollController(),
        _panelVisibility = ValueNotifier(false),
        super(const PanelValue());

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

  /// Current state of the pannel
  PanelState get panelState => value.state;

  /// If panel is open return true, otherwise false
  bool get isVisible => _panelVisibility.value;

  /// Gestaure status
  bool get isGestureEnabled => _gesture;

  /// Change gesture status
  set isGestureEnabled(bool isEnable) {
    if (isGestureEnabled && isEnable) return;
    _gesture = isEnable;
  }

  ///
  /// Open panel to the viewport
  ///
  void openPanel() {
    _internal = true;
    if (value.state == PanelState.min) return;
    value = value.copyWith(
      state: PanelState.min,
      factor: 0,
      offset: 0,
      position: Offset.zero,
    );
    _panelVisibility.value = true;
    _gesture = true;
    _internal = false;
  }

  ///
  /// Maximize panel to its full size
  ///
  void maximizePanel() {
    if (value.state == PanelState.max) return;
    _state._snapToPosition(1);
  }

  /// Minimize panel to its minimum size
  void minimizePanel() {
    if (value.state == PanelState.min) return;
    _state._snapToPosition(0);
  }

  ///
  /// Close Panel from viewport
  ///
  void closePanel() {
    if (!isVisible || value.state == PanelState.close) return;
    _internal = true;
    value = value.copyWith(
      state: PanelState.close,
      factor: 0,
      offset: 0,
      position: Offset.zero,
    );
    _panelVisibility.value = false;
    _gesture = false;
    _internal = false;
  }

  ///
  @internal
  void pausePanel() {
    _internal = true;
    if (value.state == PanelState.paused) return;
    value = value.copyWith(state: PanelState.paused);
    _panelVisibility.value = false;
    _internal = false;
  }

  ///
  @internal
  void attach(PanelValue sliderValue) {
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
  set value(PanelValue newValue) {
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
@immutable
class PanelValue {
  ///
  const PanelValue({
    this.state = PanelState.close,
    this.factor = 0.0,
    this.offset = 0.0,
    this.position = Offset.zero,
  });

  /// Sliding state
  final PanelState state;

  /// From 0.0 - 1.0
  final double factor;

  /// Height of the panel
  final double offset;

  /// Position of the panel
  final Offset position;

  ///
  PanelValue copyWith({
    PanelState? state,
    double? factor,
    double? offset,
    Offset? position,
  }) {
    return PanelValue(
      state: state ?? this.state,
      factor: factor ?? this.factor,
      offset: offset ?? this.offset,
      position: position ?? this.position,
    );
  }

  @override
  String toString() {
    return '''
    PanelValue(
      state: $state, 
      factor: $factor, 
      offset: $offset, 
      position: $position
    )''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PanelValue &&
        other.state == state &&
        other.factor == factor &&
        other.offset == offset &&
        other.position == position;
  }

  @override
  int get hashCode {
    return state.hashCode ^
        factor.hashCode ^
        offset.hashCode ^
        position.hashCode;
  }
}
