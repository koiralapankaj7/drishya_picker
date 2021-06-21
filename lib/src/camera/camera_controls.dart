import 'package:camera/camera.dart';
import 'package:drishya_picker/src/camera/widgets/camera_builder.dart';
import 'package:drishya_picker/src/camera/widgets/camera_icon_button.dart';
import 'package:drishya_picker/src/camera/widgets/camera_type_scroller.dart';
import 'package:drishya_picker/src/camera/widgets/capture_view.dart';
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
    required this.onImageCapture,
    required this.videoDuration,
    required this.onRecordingStart,
    required this.onRecordingStop,
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
  final void Function() onImageCapture;

  ///
  final Duration videoDuration;

  ///
  final void Function() onRecordingStart;

  ///
  final void Function() onRecordingStop;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: controller,
      builder: (context, value, child) {
        return Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),

            // Close and flash
            if (!value.isRecordingVideo)
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
            CaptureView(
              controller: controller,
              cameraTypeNotifier: cameraTypeNotifier,
              onImageCapture: onImageCapture,
              videoDuration: videoDuration,
              onRecordingStart: onRecordingStart,
              onRecordingStop: onRecordingStop,
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
                  if (!value.isRecordingVideo)
                    // Gallery preview
                    GalleryPreview(cameraTypeNotifier: cameraTypeNotifier),

                  // Margin
                  const SizedBox(width: 8.0),

                  // Camera type scroller
                  Expanded(
                    child: value.isRecordingVideo
                        ? const SizedBox()
                        : CameraTypeScroller(
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
      },
    );
  }
}
