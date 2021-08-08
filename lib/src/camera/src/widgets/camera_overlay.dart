import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../controllers/cam_controller.dart';
import '../entities/camera_type.dart';
import 'camera_builder.dart';
import 'camera_close_button.dart';
import 'camera_flash_button.dart';
import 'camera_footer.dart';
import 'camera_shutter_button.dart';

// TODO : Disable button click on 0.0 opacity

///
const _top = 16.0;

///
class CameraOverlay extends StatelessWidget {
  ///
  const CameraOverlay({
    Key? key,
    required this.videoDuration,
    required this.controller,
    required this.playgroundCntroller,
  }) : super(key: key);

  ///
  final Duration videoDuration;

  ///
  final CamController controller;

  ///
  final PlaygroundController playgroundCntroller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // preview, input type page view and camera
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: CameraFooter(controller: controller),
        ),

        // Close button
        Positioned(
          left: 8.0,
          top: _top,
          child: CameraCloseButton(controller: controller),
        ),

        // Flash Light
        Positioned(
          right: 8.0,
          top: _top,
          child: CameraFlashButton(controller: controller),
        ),

        // Shutter view
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 64.0,
          child: CameraShutterButton(
            videoDuration: videoDuration,
            controller: controller,
          ),
        ),

        // Playground controls
        _PlaygroundOverlay(
          controller: controller,
          playgroundCntroller: playgroundCntroller,
        ),

        //
      ],
    );
  }
}

class _PlaygroundOverlay extends StatelessWidget {
  const _PlaygroundOverlay({
    Key? key,
    required this.controller,
    required this.playgroundCntroller,
  }) : super(key: key);

  final CamController controller;

  final PlaygroundController playgroundCntroller;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: controller,
      builder: (value, child) {
        if (value.cameraType != CameraType.text) {
          return const SizedBox();
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            // Add text button
            Align(
              alignment: Alignment.center,
              child: PlaygroundAddTextButton(controller: playgroundCntroller),
            ),

            // Close button
            Positioned(
              left: 8.0,
              top: _top,
              child: PlaygroundCloseButton(controller: playgroundCntroller),
            ),

            // Background changer
            Positioned(
              left: 16.0,
              bottom: 16.0,
              child: PlaygroundGradientBackgroundChanger(
                controller: playgroundCntroller,
              ),
            ),

            // Screenshot capture button
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: PlaygroundCaptureButton(controller: playgroundCntroller),
            ),

            // Sticker buttons
            Positioned(
              right: 16.0,
              top: playgroundCntroller.value.stickerPickerView ? 0.0 : _top,
              child:
                  PlaygroundButtonCollection(controller: playgroundCntroller),
            ),
          ],
        );
      },
    );
  }
}
