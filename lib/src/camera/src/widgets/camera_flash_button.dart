// ignore_for_file: always_use_package_imports

import 'package:camera/camera.dart';
import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';
import 'camera_builder.dart';

///
class CameraFlashButton extends StatelessWidget {
  ///
  const CameraFlashButton({
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
        if (value.hideCameraFlashButton) {
          return const SizedBox();
        }
        final isOn = value.flashMode != FlashMode.off;
        return InkWell(
          onTap: controller.changeFlashMode,
          child: Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black26,
            ),
            child: Padding(
              padding: EdgeInsets.only(left: isOn ? 8.0 : 0.0),
              child: Icon(
                isOn ? CustomIcons.flashon : CustomIcons.flashoff,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
