import 'package:camera/camera.dart';
import 'package:drishya_picker/src/camera/widgets/camera_builder.dart';
import 'package:flutter/material.dart';

import '../custom_icons.dart';
import 'camera_type.dart';

///
class FlashIconButton extends StatelessWidget {
  ///
  const FlashIconButton({
    Key? key,
    required this.controller,
    required this.onPressed,
    required this.cameraTypeNotifier,
  }) : super(key: key);

  ///
  final ValueNotifier<CameraType> cameraTypeNotifier;

  ///
  final CameraController controller;

  ///
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return CameraTypeBuilder(
      notifier: cameraTypeNotifier,
      builder: (context, type, child) {
        if (type == CameraType.text || type == CameraType.selfi) {
          return const SizedBox();
        }
        return child!;
      },
      child: CameraBuilder(
        controller: controller,
        builder: (context, value, child) {
          final isOn = value.flashMode != FlashMode.off;
          return InkWell(
            onTap: onPressed,
            child: Container(
              height: 36.0,
              width: 36.0,
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
      ),
    );
  }
}
