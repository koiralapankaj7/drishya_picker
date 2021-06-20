import 'package:camera/camera.dart';
import 'package:drishya_picker/src/camera/widgets/camera_icon_button.dart';
import 'package:drishya_picker/src/camera/widgets/camera_type_scroller.dart';
import 'package:drishya_picker/src/camera/widgets/capture_button.dart';
import 'package:drishya_picker/src/camera/widgets/close_icon_button.dart';
import 'package:drishya_picker/src/camera/widgets/flash_icon_button.dart';
import 'package:drishya_picker/src/camera/widgets/gallery_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'widgets/camera_type.dart';

///
class CameraAction extends StatelessWidget {
  ///
  const CameraAction({
    Key? key,
    required this.controller,
    required this.onFlashChange,
    required this.cameraTypeNotifier,
    required this.onCameraRotate,
    required this.onCapture,
  }) : super(key: key);

  ///
  final CameraController controller;

  ///
  final ValueNotifier<CameraType> cameraTypeNotifier;

  ///
  final void Function() onFlashChange;

  ///
  final void Function(CameraLensDirection direction) onCameraRotate;

  ///
  final void Function() onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),

        // Close and flash
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Close button
              const CloseIconButton(),

              const Expanded(child: SizedBox()),

              // Flash button
              FlashIconButton(
                controller: controller,
                onPressed: onFlashChange,
                cameraTypeNotifier: cameraTypeNotifier,
              ),
            ],
          ),
        ),

        // Expanded
        const Expanded(child: SizedBox()),

        // Capture button
        CaptureButton(
          onPressed: onCapture,
          cameraTypeNotifier: cameraTypeNotifier,
        ),

        const SizedBox(height: 4.0),

        // preview, input type page view and camera
        Container(
          height: 60.0,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Gallery preview
              GalleryPreview(cameraTypeNotifier: cameraTypeNotifier),

              // Margin
              const SizedBox(width: 8.0),

              // Camera type scroller
              Expanded(
                child: CameraTypeScroller(
                  controller: controller,
                  notifier: cameraTypeNotifier,
                  rotateCamera: onCameraRotate,
                ),
              ),

              // Switch camera
              CameraIconButton(
                controller: controller,
                cameraTypeNotifier: cameraTypeNotifier,
                onPressed: onCameraRotate,
              ),

              //
            ],
          ),
        ),

        //
      ],
    );
  }
}
