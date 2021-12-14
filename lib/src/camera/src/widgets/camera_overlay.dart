// ignore_for_file: always_use_package_imports

import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';
import '../entities/camera_type.dart';
import 'camera_builder.dart';
import 'camera_close_button.dart';
import 'camera_flash_button.dart';
import 'camera_footer.dart';
import 'camera_shutter_button.dart';

///
const _top = 16.0;

///
class CameraOverlay extends StatelessWidget {
  ///
  const CameraOverlay({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final CamController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // preview, input type page view and camera
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CameraFooter(controller: controller),
          ),

          // Close button
          Positioned(
            left: 8,
            top: _top,
            child: CameraCloseButton(controller: controller),
          ),

          // Flash Light
          Positioned(
            right: 8,
            top: _top,
            child: CameraFlashButton(controller: controller),
          ),

          // Shutter view
          Positioned(
            left: 0,
            right: 0,
            bottom: 64,
            child: CameraShutterButton(controller: controller),
          ),

          // Playground controls
          _PlaygroundOverlay(controller: controller),

          //
        ],
      ),
    );
  }
}

class _PlaygroundOverlay extends StatelessWidget {
  const _PlaygroundOverlay({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final CamController controller;

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
              child: EditorTextfieldButton(
                controller: controller.photoEditingController,
              ),
            ),

            // Close button
            Positioned(
              left: 8,
              top: _top,
              child: EditorCloseButton(
                controller: controller.photoEditingController,
              ),
            ),

            // Background changer
            Positioned(
              left: 16,
              bottom: 16,
              child: BackgroundSwitcher(
                controller: controller.photoEditingController,
              ),
            ),

            // Screenshot capture button
            Positioned(
              right: 16,
              bottom: 16,
              child: EditorShutterButton(
                controller: controller.photoEditingController,
              ),
            ),

            // Sticker buttons
            Positioned(
              right: 16,
              top: controller.photoEditingController.value.isStickerPickerOpen
                  ? 0.0
                  : _top,
              child: EditorButtonCollection(
                controller: controller.photoEditingController,
              ),
            ),
          ],
        );
      },
    );
  }
}
