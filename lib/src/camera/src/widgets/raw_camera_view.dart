import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class RawCameraView extends StatelessWidget {
  ///
  const RawCameraView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final CamController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final scale = 1 /
            (controller.cameraController!.value.aspectRatio * size.aspectRatio);

        return ClipRect(
          clipper: _Clipper(size),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Listener(
              onPointerDown: controller.zoomController.addPointer,
              onPointerUp: controller.zoomController.removePointer,
              child: CameraPreview(
                controller.cameraController!,
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: controller.zoomController.initZoom,
                    onScaleUpdate: controller.zoomController.startZooming,
                    onTapDown: (details) => controller.exposureController
                        .setExposureAndFocus(details, constraints),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
