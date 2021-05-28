import 'dart:ui';

import 'package:flutter/material.dart';

import 'custom_slider_controller.dart';

///
class CustomSlider extends StatefulWidget {
  ///
  const CustomSlider({
    Key? key,
    required this.count,
    this.controller,
    this.child,
    this.background,
  }) : super(key: key);

  ///
  final int count;

  ///
  final CustomSliderController? controller;

  ///
  final Widget? child;

  ///
  final Color? background;

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider>
    with TickerProviderStateMixin {
  late final CustomSliderController _sliderController;
  late AnimationController _animationController;

  Offset dragStart = Offset.zero;
  double slidePercent = 0.0;
  SlideDirection slideDirection = SlideDirection.none;

  static const fullTransitionPx = 200.0;
  static const _percentPerMilliSecond = 0.005; //0.00090; //0.005

  @override
  void initState() {
    super.initState();
    _sliderController = (widget.controller ?? CustomSliderController())
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
        slidePercent = lerpDouble(
              startSlidePercent,
              endSlidePercent,
              _animationController.value,
            ) ??
            0.0;
        _sliderController._addSlide(Slide(
          direction: direction,
          percent: slidePercent,
          state: SlideState.animating,
        ));
      })
      ..addStatusListener(
        (AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            _sliderController._addSlide(Slide(
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
      final canDragRightToLeft = slideValue.currentIndex < widget.count - 1;

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
        _sliderController._addSlide(Slide(
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
    _sliderController._addSlide(Slide(
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
    return GestureDetector(
      onHorizontalDragStart: onHorizontalDragStart,
      onHorizontalDragUpdate: onHorizontalDragUpdate,
      onHorizontalDragEnd: onHorizontalDragEnd,
      child: Container(
        color: widget.background ?? Theme.of(context).scaffoldBackgroundColor,
        child: widget.child,
      ),
    );
  }
}

///
class CustomSliderController extends ValueNotifier<SliderValue> {
  ///
  CustomSliderController() : super(SliderValue());

  late final ValueNotifier<Slide> _slideNotifier;

  late final _CustomSliderState _state;

  void _init(_CustomSliderState state) {
    _state = state;
    _slideNotifier = ValueNotifier(Slide())..addListener(_slideListener);
  }

  void _slideListener() {
    final slide = _slideNotifier.value;

    if (slide.state == SlideState.dragging) {
      _updateState(
        slideDirection: slide.direction,
        slidePercent: slide.percent,
      );
      if (value.direction == SlideDirection.leftToRight) {
        _updateState(nextPageIndex: value.currentIndex - 1);
      } else if (value.direction == SlideDirection.rightToLeft) {
        _updateState(nextPageIndex: value.currentIndex + 1);
      } else {
        _updateState(nextPageIndex: value.currentIndex);
      }
      if (!slide.withGesture) {
        _slideNotifier.value = Slide(
          state: SlideState.doneDragging,
          direction: value.direction,
          percent: 0.0,
          withGesture: false,
        );
      }
    }

    if (slide.state == SlideState.doneDragging) {
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
        _updateState(nextPageIndex: value.currentIndex);
      }
      _state._animationController.forward(from: 0.0);
    }

    if (slide.state == SlideState.animating) {
      _updateState(
        slideDirection: slide.direction,
        slidePercent: slide.percent,
      );
    }

    if (slide.state == SlideState.doneAnimating) {
      _updateState(
        activeIndex: value.nextIndex,
        slideDirection: SlideDirection.none,
        slidePercent: 0.0,
      );
      _state._animationController.dispose();
    }
    //
  }

  ///
  void _updateState({
    int? activeIndex,
    int? nextPageIndex,
    SlideDirection? slideDirection,
    double? slidePercent,
  }) {
    value = value.copyWith(
      currentIndex: activeIndex,
      nextIndex: nextPageIndex,
      direction: slideDirection,
      slidePercent: slidePercent,
    );
  }

  ///
  void _addSlide(Slide slide) {
    _slideNotifier.value = slide;
  }

  /// Slide detail listenable
  ValueNotifier<Slide> get slideNotifier => _slideNotifier;

  /// Run animation from provided direction without scrolling
  void runAnimationFrom(SlideDirection direction) {
    _slideNotifier.value = Slide(
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
