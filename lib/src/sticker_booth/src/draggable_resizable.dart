import 'package:flutter/gestures.dart';
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
    this.initialPosition = Offset.zero,
    this.onUpdate,
    this.onScaleUpdate,
    this.onStart,
    this.onEnd,
    this.canTransform = false,
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
  final Offset initialPosition;

  /// The child's original size.
  final Size size;

  /// The child's constraints.
  /// Defaults to [BoxConstraints.loose(Size.infinite)].
  final BoxConstraints constraints;

  @override
  _DraggableResizableState createState() => _DraggableResizableState();
}

class _DraggableResizableState extends State<DraggableResizable> {
  late Size size;
  late BoxConstraints constraints;
  late double angle;
  late double angleDelta;
  late double baseAngle;

  bool get isTouchInputSupported => true;

  late Offset position;

  final key = GlobalKey();

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
    size = widget.size;
    constraints = const BoxConstraints.expand(width: 1, height: 1);
    angle = 0;
    baseAngle = 0;
    angleDelta = 0;
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
  Widget build(BuildContext context) {
    final aspectRatio = widget.size.width / widget.size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        position = position == Offset.zero
            ? Offset(
                (constraints.maxWidth - size.width) / 2,
                (constraints.maxHeight - size.height) / 2,
              )
            : position;

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
  var baseScaleFactor = 1.0;
  var scaleFactor = 1.0;
  var baseAngle = 0.0;
  var angle = 0.0;

  var isStartTriggered = false;
  var isEndTriggered = false;
  var isUpdating = false;

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
          baseAngle = angle;
          baseScaleFactor = scaleFactor;
          widget.onRotate?.call(baseAngle);
          widget.onScale?.call(baseScaleFactor);
        }
      },
      onScaleUpdate: (details) {
        widget.onScaleUpdate?.call(details);
        isEndTriggered = false;
        isStartTriggered = false;
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
          scaleFactor = baseScaleFactor * details.scale;
          widget.onScale?.call(scaleFactor);
          angle = baseAngle + details.rotation;
          widget.onRotate?.call(angle);
        }
      },
      onScaleEnd: (detail) {
        widget.onEnd?.call();
      },
      child: widget.child,
    );
  }
}
