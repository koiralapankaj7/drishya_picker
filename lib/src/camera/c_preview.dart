import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

///
class CPreview extends StatelessWidget {
  ///
  const CPreview({
    Key? key,
    required this.controller,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onTapDown,
  }) : super(key: key);

  ///
  final CameraController controller;

  ///
  final void Function(PointerDownEvent event) onPointerDown;

  ///
  final void Function(PointerUpEvent event) onPointerUp;

  ///
  final void Function(ScaleStartDetails detail) onScaleStart;

  ///
  final void Function(ScaleUpdateDetails detail) onScaleUpdate;

  ///
  final void Function(TapDownDetails detail, BoxConstraints constraints)
      onTapDown;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = 1 / (controller.value.aspectRatio * size.aspectRatio);

    return ClipRect(
      clipper: _Clipper(size),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: Listener(
          onPointerDown: onPointerDown,
          onPointerUp: onPointerUp,
          child: CameraPreview(
            controller,
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: onScaleStart,
                    onScaleUpdate: onScaleUpdate,
                    onTapDown: (details) => onTapDown(details, constraints),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  const _Clipper(this.size);

  final Size size;

  @override
  Rect getClip(Size s) => Rect.fromLTWH(0, 0, size.width, size.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
