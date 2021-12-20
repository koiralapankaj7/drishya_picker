import 'dart:ui';

import 'package:flutter/material.dart';

/// {@template drag_update}
/// Drag update model which includes the position and size.
/// {@endtemplate}
class DragUpdate {
  /// {@macro drag_update}
  const DragUpdate({
    required this.angle,
    required this.position,
    required this.size,
    required this.constraints,
  });

  /// The angle of the draggable asset.
  final double angle;

  /// The position of the draggable asset.
  final Offset position;

  /// The size of the draggable asset.
  final Size size;

  /// The constraints of the parent view.
  final Size constraints;
}

/// {@template draggable_resizable}
/// A widget which allows a user to drag and resize the provided [child].
/// {@endtemplate}
class DraggableResizable extends StatefulWidget {
  /// {@macro draggable_resizable}
  DraggableResizable({
    Key? key,
    required this.child,
    required this.size,
    this.onTap,
    BoxConstraints? constraints,
    this.initialPosition,
    this.initialAngle,
    this.onUpdate,
    this.onScaleUpdate,
    this.onStart,
    this.onEnd,
    this.canTransform = false,
    this.controller,
  })  : constraints = constraints ?? BoxConstraints.loose(Size.infinite),
        super(key: key);

  /// The child which will be draggable/resizable.
  final Widget child;

  /// Drag/Resize end callback
  final VoidCallback? onTap;

  /// Drag/Resize start callback
  final VoidCallback? onStart;

  /// Drag/Resize value setter.
  final void Function(DragUpdate, GlobalKey)? onUpdate;

  ///
  final ValueSetter<ScaleUpdateDetails>? onScaleUpdate;

  /// Drag/Resize end callback
  final VoidCallback? onEnd;

  /// Whether or not the asset can be dragged or resized.
  /// Defaults to false.
  final bool canTransform;

  /// Initial position of widget
  final Offset? initialPosition;

  /// Initial angle of the widget
  final double? initialAngle;

  /// The child's original size.
  final Size size;

  /// The child's constraints.
  /// Defaults to [BoxConstraints.loose(Size.infinite)].
  final BoxConstraints constraints;

  ///
  final DraggableResizableController? controller;

  @override
  State<DraggableResizable> createState() => _DraggableResizableState();
}

class _DraggableResizableState extends State<DraggableResizable>
    with SingleTickerProviderStateMixin {
  late Size size;
  late BoxConstraints constraints;
  late double angle;
  late double angleDelta;
  late double baseAngle;

  bool get isTouchInputSupported => true;

  late Offset position;

  final key = GlobalKey();
  late final AnimationController _animationController;

  var _centerDX = 0.0;
  var _centerDY = 0.0;
  VoidCallback? _onCompleteMovingToCenter;

  var _initialSize = Size.zero;

  @override
  void initState() {
    super.initState();
    widget.controller?._init(this);
    _initAnim();
    position = widget.initialPosition ?? Offset.zero;
    size = widget.size;
    constraints = widget.constraints;
    angle = widget.initialAngle ?? 0;
    baseAngle = 0;
    angleDelta = 0;
    _initialSize = size;
  }

  void _initAnim() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )
      ..addListener(() {
        setState(() {
          angle = lerpDouble(angle, 0, _animationController.value) ?? 0.0;
          position = Offset(
            lerpDouble(position.dx, _centerDX, _animationController.value) ??
                0.0,
            lerpDouble(position.dy, _centerDY, _animationController.value) ??
                0.0,
          );
          if (_initialSize != Size.zero) {
            size = Size(
              lerpDouble(
                    size.width,
                    _initialSize.width,
                    _animationController.value,
                  ) ??
                  0,
              lerpDouble(
                    size.height,
                    _initialSize.height,
                    _animationController.value,
                  ) ??
                  0,
            );
          }
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reset();
          _onCompleteMovingToCenter?.call();
        }
      });
  }

  void _moveToCenter({VoidCallback? onComplete}) {
    _onCompleteMovingToCenter = onComplete;
    _animationController
      ..drive(
        Tween(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeIn)),
      )
      ..forward();
  }

  void onUpdate(double normalizedLeft, double normalizedTop) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final normalizedPosition = Offset(normalizedLeft, normalizedTop);
      widget.onUpdate?.call(
        DragUpdate(
          position: normalizedPosition,
          size: size,
          constraints: Size(constraints.maxWidth, constraints.maxHeight),
          angle: angle,
        ),
        key,
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final aspectRatio = widget.size.width / widget.size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = widget.size != Size.zero
            ? widget.size.width / widget.size.height
            : constraints.maxWidth / constraints.maxHeight;

        if (widget.size == Size.zero) {
          size = constraints.smallest;
        }

        _centerDX = (constraints.maxWidth - size.width) / 2;
        _centerDY = (constraints.maxHeight - size.height) / 2;
        position =
            position == Offset.zero ? Offset(_centerDX, _centerDY) : position;

        final normalizedWidth = size.width;
        final normalizedHeight = normalizedWidth / aspectRatio;
        final newSize = Size(normalizedWidth, normalizedHeight);

        if (widget.constraints.isSatisfiedBy(newSize)) {
          size = newSize;
        }

        final normalizedLeft = position.dx;
        final normalizedTop = position.dy;

        final decoratedChild = SizedBox(
          height: normalizedHeight,
          width: normalizedWidth,
          key: key,
          child: widget.child,
        );

        if (this.constraints != constraints) {
          this.constraints = constraints;
          onUpdate(normalizedLeft, normalizedTop);
        }

        return Stack(
          children: <Widget>[
            Positioned(
              top: normalizedTop,
              left: normalizedLeft,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(1.0)
                  ..rotateZ(angle),
                child: _DraggablePoint(
                  key: const Key('draggableResizable_child_draggablePoint'),
                  onScaleUpdate: widget.onScaleUpdate,
                  onTap: () {
                    widget.onTap?.call();
                    onUpdate(normalizedLeft, normalizedTop);
                  },
                  onStart: widget.onStart,
                  onEnd: widget.onEnd,
                  onDrag: (d) {
                    setState(() {
                      position = Offset(position.dx + d.dx, position.dy + d.dy);
                    });
                    onUpdate(normalizedLeft, normalizedTop);
                  },
                  onScale: (s) {
                    final updatedSize = Size(
                      widget.size.width * s,
                      widget.size.height * s,
                    );

                    if (!widget.constraints.isSatisfiedBy(updatedSize)) return;

                    final midX = position.dx + (size.width / 2);
                    final midY = position.dy + (size.height / 2);
                    final updatedPosition = Offset(
                      midX - (updatedSize.width / 2),
                      midY - (updatedSize.height / 2),
                    );

                    setState(() {
                      size = updatedSize;
                      position = updatedPosition;
                    });
                    onUpdate(normalizedLeft, normalizedTop);
                  },
                  onRotate: (a) {
                    setState(() => angle = a);
                    onUpdate(normalizedLeft, normalizedTop);
                  },
                  child: decoratedChild,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _PositionMode { local, global }

class _DraggablePoint extends StatefulWidget {
  const _DraggablePoint({
    Key? key,
    required this.child,
    this.onDrag,
    this.onScale,
    this.onRotate,
    this.onScaleUpdate,
    this.onTap,
    this.onStart,
    this.onEnd,
    this.mode = _PositionMode.global,
  }) : super(key: key);

  final Widget child;
  final _PositionMode mode;
  final ValueSetter<Offset>? onDrag;
  final ValueSetter<double>? onScale;
  final ValueSetter<double>? onRotate;
  final ValueSetter<ScaleUpdateDetails>? onScaleUpdate;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onEnd;

  @override
  _DraggablePointState createState() => _DraggablePointState();
}

class _DraggablePointState extends State<_DraggablePoint> {
  late Offset initPoint;
  var _baseScaleFactor = 1.0;
  var _scaleFactor = 1.0;
  var _baseAngle = 0.0;
  var _angle = 0.0;

  // var _isStartTriggered = false;
  // var _isEndTriggered = false;
  // var _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onScaleStart: (details) {
        widget.onStart?.call();
        switch (widget.mode) {
          case _PositionMode.global:
            initPoint = details.focalPoint;
            break;
          case _PositionMode.local:
            initPoint = details.localFocalPoint;
            break;
        }
        if (details.pointerCount > 1) {
          _baseAngle = _angle;
          _baseScaleFactor = _scaleFactor;
          widget.onRotate?.call(_baseAngle);
          widget.onScale?.call(_baseScaleFactor);
        }
      },
      onScaleUpdate: (details) {
        widget.onScaleUpdate?.call(details);
        // _isEndTriggered = false;
        // _isStartTriggered = false;
        switch (widget.mode) {
          case _PositionMode.global:
            final dx = details.focalPoint.dx - initPoint.dx;
            final dy = details.focalPoint.dy - initPoint.dy;
            initPoint = details.focalPoint;
            widget.onDrag?.call(Offset(dx, dy));
            break;
          case _PositionMode.local:
            final dx = details.localFocalPoint.dx - initPoint.dx;
            final dy = details.localFocalPoint.dy - initPoint.dy;
            initPoint = details.localFocalPoint;
            widget.onDrag?.call(Offset(dx, dy));
            break;
        }
        if (details.pointerCount > 1) {
          _scaleFactor = _baseScaleFactor * details.scale;
          widget.onScale?.call(_scaleFactor);
          _angle = _baseAngle + details.rotation;
          widget.onRotate?.call(_angle);
        }
      },
      onScaleEnd: (detail) {
        widget.onEnd?.call();
      },
      child: widget.child,
    );
  }
}

/// Controller for [DraggableResizableController] widget
class DraggableResizableController extends ChangeNotifier {
  _DraggableResizableState? _state;

  // ignore: use_setters_to_change_properties
  void _init(_DraggableResizableState state) {
    _state = state;
  }

  /// Move widget to center
  void moveToCenter({
    VoidCallback? onComplete,
  }) =>
      _state?._moveToCenter(onComplete: onComplete);
}
