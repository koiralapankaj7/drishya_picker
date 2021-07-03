import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';
import 'camera_builder.dart';

///
class CameraCloseButton extends StatelessWidget {
  ///
  const CameraCloseButton({
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
        if (value.hideCameraCloseButton) {
          return const SizedBox();
        }
        return child!;
      },
      child: InkWell(
        onTap: Navigator.of(context).pop,
        child: Container(
          height: 36.0,
          width: 36.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black26,
          ),
          child: const Icon(
            CustomIcons.close,
            color: Colors.white,
            size: 16.0,
          ),
        ),
      ),
    );
  }
}
