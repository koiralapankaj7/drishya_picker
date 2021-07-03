import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';
import 'camera_builder.dart';
import 'camera_gallery_button.dart';
import 'camera_rotate_button.dart';
import 'camera_type_changer.dart';

///
class CameraFooter extends StatelessWidget {
  ///
  const CameraFooter({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final CamController controller;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: controller,
      builder: (value, child) {
        if (value.hideCameraFooter) {
          return const SizedBox();
        }
        return child!;
      },
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
            CameraGalleryButton(controller: controller),

            // Margin
            const SizedBox(width: 8.0),

            // Camera type scroller
            Expanded(child: CameraTypeChanger(controller: controller)),

            // Switch camera
            CameraRotateButton(controller: controller),

            //
          ],
        ),
      ),
    );
  }
}
