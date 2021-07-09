import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';

///
class RawCameraView extends StatelessWidget {
  ///
  const RawCameraView({
    Key? key,
    required this.action,
  }) : super(key: key);

  ///
  final CamController action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      final scale =
          1 / (action.controller.value.aspectRatio * size.aspectRatio);

      return ClipRect(
        clipper: _Clipper(size),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Listener(
            onPointerDown: action.zoom.addPointer,
            onPointerUp: action.zoom.removePointer,
            child: CameraPreview(
              action.controller,
              child: ConstrainedBox(
                constraints: const BoxConstraints.expand(),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: action.zoom.initZoom,
                  onScaleUpdate: action.zoom.startZooming,
                  onTapDown: (details) =>
                      action.exposure.setExposureAndFocus(details, constraints),
                ),
              ),
            ),
          ),
        ),
      );
    });
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
