import 'dart:ui';

import 'package:flutter/material.dart';

///
class SlideGesture extends StatefulWidget {
  ///
  const SlideGesture({
    Key? key,
    this.controller,
    this.child,
    this.background,
  }) : super(key: key);

  ///
  final SlideController? controller;

  ///
  final Widget? child;

  ///
  final Color? background;

  @override
  _SlideGestureState createState() => _SlideGestureState();
}

class _SlideGestureState extends State<SlideGesture>
    with TickerProviderStateMixin {
  late final SlideController _sliderController;
  late AnimationController _animationController;

  Offset dragStart = Offset.zero;
  double slidePercent = 0.0;
  SlideDirection slideDirection = SlideDirection.none;

  static const fullTransitionPx = 200.0;
  static const _percentPerMilliSecond = 0.005; //0.00090; //0.005

  @override
  void initState() {
    super.initState();
    _sliderController = (widget.controller ?? SlideController(length: 0))
      .._init(this);
  }

  void _animate({
    required SlideDirection direction,
    required SlideGoal goal,
    required double slidePercent,
  }) {
    final startSlidePercent = slidePercent;
    double endSlidePercent;
    Duration duration;

    if (goal == SlideGoal.open) {
      endSlidePercent = 1.0;
      final slideRemaining = 1.0 - slidePercent;
      duration = Duration(
          milliseconds: (slideRemaining / _percentPerMilliSecond).round());
    } else {
      endSlidePercent = 0.0;
      duration = Duration(
          milliseconds: (slidePercent / _percentPerMilliSecond).round());
    }

    _animationController = AnimationController(duration: duration, vsync: this)
      ..addListener(() {
        final percent = lerpDouble(
              startSlidePercent,
              endSlidePercent,
              _animationController.value,
            ) ??
            0.0;
        slidePercent = double.parse(percent.toStringAsFixed(2));
        _sliderController._addSlideDetail(_SlideDetail(
          direction: direction,
          percent: slidePercent,
          state: SlideState.animating,
        ));
      })
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            _sliderController._addSlideDetail(_SlideDetail(
              direction: direction,
              percent: endSlidePercent,
              state: SlideState.doneAnimating,
            ));
          }
        },
      );
  }

  void onHorizontalDragStart(DragStartDetails details) {
    dragStart = details.globalPosition;
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (dragStart != Offset.zero) {
      final newPosition = details.globalPosition;
      final dx = dragStart.dx - newPosition.dx;

      final slideValue = _sliderController.value;
      final canDragLeftToRight = slideValue.currentIndex > 0;
      final canDragRightToLeft =
          slideValue.currentIndex < _sliderController.value.length - 1;

      if (dx > 0.0 && canDragRightToLeft) {
        slideDirection = SlideDirection.rightToLeft;
      } else if (dx < 0.0 && canDragLeftToRight) {
        slideDirection = SlideDirection.leftToRight;
      } else {
        slideDirection = SlideDirection.none;
      }

      // if (slideDirection != SlideDirection.none) {
      //   // dx can be -ve so use absolute value. What if user slide by more than 300 px (FULL_TRANSITION_PX) ?  That is why we are using clamp. So that slide percent always remain between 0,0 to 1.0
      //   final percent = (dx / fullTransitionPx).abs().clamp(0.0, 1.0);
      //   slidePercent = double.parse(percent.toStringAsFixed(2));
      // } else {
      //   slidePercent = 0.0;
      // }

      // _sliderController._addSlide(Slide(
      //   state: SlideState.dragging,
      //   direction: slideDirection,
      //   percent: slidePercent,
      // ));

      final shouldUpdate = (slideDirection == SlideDirection.leftToRight &&
              canDragLeftToRight) ||
          (slideDirection == SlideDirection.rightToLeft && canDragRightToLeft);

      if (shouldUpdate) {
        // dx can be -ve so use absolute value. What if user slide by more than
        // 300 px (fullTransitionPx) ?  That is why we are using clamp.
        // So that slide percent always remain between 0,0 to 1.0
        // slidePercent = (dx / fullTransitionPx).abs().clamp(0.0, 1.0);
        final percent = (dx / fullTransitionPx).abs().clamp(0.0, 1.0);
        slidePercent = double.parse(percent.toStringAsFixed(2));
        _sliderController._addSlideDetail(_SlideDetail(
          state: SlideState.dragging,
          direction: slideDirection,
          percent: slidePercent,
        ));
      }
    }
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    // Clean up
    dragStart = Offset.zero;
    _sliderController._addSlideDetail(_SlideDetail(
      state: SlideState.doneDragging,
      direction: SlideDirection.none,
      percent: 0.0,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _sliderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enableGesture =
        _sliderController.value.direction == SlideDirection.none;
    return GestureDetector(
      onHorizontalDragStart: enableGesture ? onHorizontalDragStart : null,
      onHorizontalDragUpdate: enableGesture ? onHorizontalDragUpdate : null,
      onHorizontalDragEnd: enableGesture ? onHorizontalDragEnd : null,
      child: Container(
        color: widget.background ?? Theme.of(context).scaffoldBackgroundColor,
        child: widget.child,
      ),
    );
  }
}

///
class SlideController extends ValueNotifier<SlideValue> {
  ///
  SlideController({required int length}) : super(SlideValue(length: length));

  late final ValueNotifier<_SlideDetail> _slideNotifier;

  late final _SlideGestureState _state;

  void _init(_SlideGestureState state) {
    _state = state;
    _slideNotifier = ValueNotifier(_SlideDetail())..addListener(_slideListener);
  }

  void _slideListener() {
    final slide = _slideNotifier.value;

    if (slide.state == SlideState.dragging) {
      _updateSlideValue(
        slideDirection: slide.direction,
        slidePercent: slide.percent,
        state: slide.state,
      );
      if (value.direction == SlideDirection.leftToRight) {
        _updateSlideValue(nextPageIndex: value.currentIndex - 1);
      } else if (value.direction == SlideDirection.rightToLeft) {
        _updateSlideValue(nextPageIndex: value.currentIndex + 1);
      } else {
        _updateSlideValue(nextPageIndex: value.currentIndex);
      }
      if (!slide.withGesture) {
        _slideNotifier.value = _SlideDetail(
          state: SlideState.doneDragging,
          direction: value.direction,
          percent: 0.0,
          withGesture: false,
        );
      }
    }

    if (slide.state == SlideState.doneDragging) {
      _updateSlideValue(state: slide.state);

      if (value.slidePercent > 0.5 || !slide.withGesture) {
        _state._animate(
          direction: value.direction,
          goal: SlideGoal.open,
          slidePercent: value.slidePercent,
        );
      } else {
        _state._animate(
          direction: value.direction,
          goal: SlideGoal.close,
          slidePercent: value.slidePercent,
        );
        _updateSlideValue(nextPageIndex: value.currentIndex);
      }
      _state._animationController.forward(from: 0.0);
    }

    if (slide.state == SlideState.animating) {
      _updateSlideValue(
        slideDirection: slide.direction,
        slidePercent: slide.percent,
        state: slide.state,
      );
    }

    if (slide.state == SlideState.doneAnimating) {
      _updateSlideValue(
        activeIndex: value.nextIndex,
        slideDirection: SlideDirection.none,
        slidePercent: 0.0,
        state: slide.state,
      );
      _state._animationController.dispose();
    }
    //
  }

  ///
  void _updateSlideValue({
    int? activeIndex,
    int? nextPageIndex,
    SlideDirection? slideDirection,
    double? slidePercent,
    SlideState? state,
  }) {
    value = value._copyWith(
      currentIndex: activeIndex,
      nextIndex: nextPageIndex,
      direction: slideDirection,
      slidePercent: slidePercent,
      state: state,
    );
  }

  ///
  void _addSlideDetail(_SlideDetail slide) {
    _slideNotifier.value = slide;
  }

  /// Run animation from provided direction without scrolling
  void runAnimationFrom(SlideDirection direction) {
    _slideNotifier.value = _SlideDetail(
      state: SlideState.dragging,
      direction: direction,
      percent: 0.0,
      withGesture: false,
    );
  }

  @override
  void dispose() {
    _slideNotifier.removeListener(_slideListener);
    _slideNotifier.dispose();
    super.dispose();
  }

//
}

class _SlideDetail {
  _SlideDetail({
    this.state = SlideState.none,
    this.direction = SlideDirection.none,
    this.percent = 0.0,
    this.withGesture = true,
  });

  final SlideState state;
  final SlideDirection direction;
  final double percent;
  final bool withGesture;
}

///
/// Slide value
class SlideValue {
  ///
  SlideValue({
    required this.length,
    this.currentIndex = 0,
    this.nextIndex = 0,
    this.direction = SlideDirection.none,
    this.slidePercent = 0.0,
    this.state = SlideState.none,
  });

  ///
  final int length;

  ///
  final int currentIndex;

  ///
  final int nextIndex;

  ///
  final SlideDirection direction;

  ///
  final double slidePercent;

  ///
  final SlideState state;

  ///
  SlideValue _copyWith({
    int? currentIndex,
    int? nextIndex,
    SlideDirection? direction,
    double? slidePercent,
    SlideState? state,
  }) =>
      SlideValue(
        currentIndex: currentIndex ?? this.currentIndex,
        nextIndex: nextIndex ?? this.nextIndex,
        direction: direction ?? this.direction,
        slidePercent: slidePercent ?? this.slidePercent,
        state: state ?? this.state,
        length: length,
      );
}

///
/// Slide gesture goal
///
enum SlideGoal {
  ///
  open,

  ///
  close,
}

///
/// Current slide state
///
enum SlideState {
  ///
  dragging,

  ///
  doneDragging,

  ///
  animating,

  ///
  doneAnimating,

  ///
  none,
}

///
/// Current sliding direction
///
enum SlideDirection {
  ///
  leftToRight,

  ///
  rightToLeft,

  ///
  none,
}
