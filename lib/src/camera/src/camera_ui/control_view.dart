import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'widgets/camera_type_changer.dart';
import 'widgets/capture_with_filter.dart';
import 'widgets/close_button.dart' as cb;
import 'widgets/flash_button.dart';
import 'widgets/gallery_button.dart';
import 'widgets/rotate_button.dart';

///
class ControlView extends StatelessWidget {
  ///
  const ControlView({
    Key? key,
    required this.videoDuration,
  }) : super(key: key);

  ///
  final Duration videoDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),

        // Close and flash
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: const [
              // Close button
              cb.CloseButton(),

              Expanded(child: SizedBox()),

              // Flash button
              FlashButton(),
            ],
          ),
        ),

        // Expanded
        const Expanded(child: SizedBox()),

        // Capture button
        CaptureWithFilter(videoDuration: videoDuration),

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
        ),

        //
      ],
    );
  }
}
