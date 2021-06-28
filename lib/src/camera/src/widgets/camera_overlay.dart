import 'package:drishya_picker/src/camera/src/entities/camera_type.dart';
import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../controllers/action_notifier.dart';
import 'camera_close_button.dart';
import 'camera_type_changer.dart';
import 'flash_button.dart';
import 'gallery_button.dart';
import 'rotate_button.dart';
import 'shutter_view.dart';

///
class CameraOverlay extends StatelessWidget {
  ///
  const CameraOverlay({
    Key? key,
    required this.videoDuration,
    required this.action,
    required this.playgroundCntroller,
  }) : super(key: key);

  ///
  final Duration videoDuration;

  ///
  final ActionNotifier action;

  ///
  final PlaygroundController playgroundCntroller;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 4.0;
    final showPGOverlay = action.value.cameraType == CameraType.text;

    return Stack(
      fit: StackFit.expand,
      children: [
        // preview, input type page view and camera
        if (action.showCameraTypeScroller)
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
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
                  GalleryButton(action: action),

                  // Margin
                  const SizedBox(width: 8.0),

                  // Camera type scroller
                  Expanded(child: CameraTypeChanger(action: action)),

                  // Switch camera
                  RotateButton(action: action),

                  //
                ],
              ),
            ),
          ),

        // Close button
        if (action.showCloseButton)
          Positioned(
            left: 8.0,
            top: top,
            child: CameraCloseButton(action: action),
          ),

        // Flash Light
        if (action.showFlashButton)
          Positioned(
            right: 8.0,
            top: top,
            child: FlashButton(action: action),
          ),

        // Shutter view
        if (action.showShutterView)
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 64.0,
            child: ShutterView(videoDuration: videoDuration, action: action),
          ),

        ///==================== PLAYGROUND CONTROLS ====================///
        // Add text button
        if (showPGOverlay)
          Align(
            alignment: Alignment.center,
            child: PlaygroundAddTextButton(controller: playgroundCntroller),
          ),

        // Close button
        if (showPGOverlay)
          Positioned(
            left: 8.0,
            top: top,
            child: PlaygroundCloseButton(controller: playgroundCntroller),
          ),

        // Background changer
        if (showPGOverlay)
          Positioned(
            left: 16.0,
            bottom: 16.0,
            child: GradientBackgroundChanger(controller: playgroundCntroller),
          ),

        // Screenshot capture button
        if (showPGOverlay)
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: PlaygroundCaptureButton(controller: playgroundCntroller),
          ),

        // Sticker buttons
        if (showPGOverlay)
          Positioned(
            right: 16.0,
            top: top,
            child: PlaygroundButtonCollection(controller: playgroundCntroller),
          ),

        //
      ],
    );
  }
}
