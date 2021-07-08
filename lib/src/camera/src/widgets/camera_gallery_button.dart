import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';
import 'camera_builder.dart';

///
class CameraGalleryButton extends StatelessWidget {
  ///
  const CameraGalleryButton({
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
        return Container(
          padding: const EdgeInsets.all(4.0),
          width: 54.0,
          height: 54.0,
          child: const SizedBox(),
          // child: value.hideCameraGalleryButton
          //     ? const SizedBox()
          //     : GalleryViewField(
          //       onChanged: (entity, _){
          //         //
          //       },
          //     ),
        );
      },
    );
  }
}
