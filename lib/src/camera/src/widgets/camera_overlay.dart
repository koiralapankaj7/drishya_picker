import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_builder.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_close_button.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_flash_button.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_footer.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_shutter_button.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Stack(
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
          left: 16,
          top: _top,
          child: CameraCloseButton(controller: controller),
        ),

        // Flash Light
        Positioned(
          right: 16,
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
    final deController = controller.drishyaEditingController;

    return CameraBuilder(
      controller: controller,
      builder: (value, child) {
        if (value.cameraType != CameraType.text) {
          return const SizedBox();
        }
        return child!;
      },
      child: EditorBuilder(
        controller: deController,
        builder: (context, value, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Close button
              Positioned(
                left: 16,
                top: _top,
                child: EditorCloseButton(
                  controller: deController,
                ),
              ),

              // Background changer
              Positioned(
                left: 16,
                bottom: 16,
                child: BackgroundSwitcher(
                  controller: deController,
                ),
              ),

              // Screenshot capture button
              Positioned(
                right: 16,
                bottom: 16,
                child: EditorShutterButton(
                  controller: deController,
                  onSuccess: (entity) {
                    UIHandler.of(context).pop([entity]);
                  },
                ),
              ),

              // Sticker buttons
              Positioned(
                right: 16,
                top: _top,
                child: EditorButtonCollection(
                  controller: deController,
                ),
              ),

              //
            ],
          );
        },
      ),
    );
  }
}
