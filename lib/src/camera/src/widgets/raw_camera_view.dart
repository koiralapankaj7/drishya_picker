// ignore_for_file: always_use_package_imports

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final scale =
            1 / (action.cameraController!.value.aspectRatio * size.aspectRatio);

        return ClipRect(
          clipper: _Clipper(size),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: Listener(
              onPointerDown: action.zoomController.addPointer,
              onPointerUp: action.zoomController.removePointer,
              child: CameraPreview(
                action.cameraController!,
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: action.zoomController.initZoom,
                    onScaleUpdate: action.zoomController.startZooming,
                    onTapDown: (details) => action.exposureController
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
