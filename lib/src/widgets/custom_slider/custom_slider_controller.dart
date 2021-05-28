///
class SliderValue {
  ///
  SliderValue({
    this.currentIndex = 0,
    this.nextIndex = 0,
    this.direction = SlideDirection.none,
    this.slidePercent = 0.0,
  });

  ///
  final int currentIndex;

  ///
  final int nextIndex;

  ///
  final SlideDirection direction;

  ///
  final double slidePercent;

  ///
  SliderValue copyWith({
    int? currentIndex,
    int? nextIndex,
    SlideDirection? direction,
    double? slidePercent,
  }) =>
      SliderValue(
        currentIndex: currentIndex ?? this.currentIndex,
        nextIndex: nextIndex ?? this.nextIndex,
        direction: direction ?? this.direction,
        slidePercent: slidePercent ?? this.slidePercent,
      );
}

///
class Slide {
  ///
  Slide({
    this.state = SlideState.none,
    this.direction = SlideDirection.none,
    this.percent = 0.0,
    this.withGesture = true,
  });

  ///
  final SlideState state;

  ///
  final SlideDirection direction;

  ///
  final double percent;

  ///
  final bool withGesture;
}

///
enum SlideGoal {
  ///
  open,

  ///
  close,
}

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
enum SlideDirection {
  ///
  leftToRight,

  ///
  rightToLeft,

  ///
  none,
}
