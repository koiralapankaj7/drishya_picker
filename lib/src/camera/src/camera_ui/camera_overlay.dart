import 'package:drishya_picker/src/camera/src/camera_ui/builders/action_detector.dart';
import 'package:drishya_picker/src/camera/src/controllers/camera_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'widgets/camera_type_changer.dart';
import 'widgets/close_button.dart' as cb;
import 'widgets/flash_button.dart';
import 'widgets/gallery_button.dart';
import 'widgets/rotate_button.dart';
import 'widgets/shutter_view.dart';

///
class CameraOverlay extends StatelessWidget {
  ///
  const CameraOverlay({
    Key? key,
    required this.videoDuration,
    required this.action,
  }) : super(key: key);

  ///
  final Duration videoDuration;

  ///
  final CameraAction action;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 4.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // preview, input type page view and camera
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: ActionBuilder(
            builder: (action, value, child) {
              if (action.hideCameraTypeScroller) {
                return const SizedBox();
              }
              return Container(
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
                  children: const [
                    // Gallery preview
                    GalleryButton(),

                    // Margin
                    SizedBox(width: 8.0),

                    // Camera type scroller
                    Expanded(child: CameraTypeChanger()),

                    // Switch camera
                    RotateButton(),

                    //
                  ],
                ),
              );
            },
          ),
        ),

        // Close button
        Positioned(
          left: 8.0,
          top: top,
          child: const cb.CloseButton(),
        ),

        // Flash Light
        Positioned(
          right: 8.0,
          top: top,
          child: const FlashButton(),
        ),

        // Shutter view
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 64.0,
          child: ShutterView(videoDuration: videoDuration),
        ),

        //
      ],
    );
  }
}
