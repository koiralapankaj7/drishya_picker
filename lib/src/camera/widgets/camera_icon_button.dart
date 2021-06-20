import 'package:camera/camera.dart';
import 'package:drishya_picker/src/camera/widgets/camera_builder.dart';
import 'package:flutter/material.dart';

import '../custom_icons.dart';
import 'camera_type.dart';

///
class CameraIconButton extends StatelessWidget {
  ///
  const CameraIconButton({
    Key? key,
    required this.controller,
    required this.cameraTypeNotifier,
    required this.onPressed,
  }) : super(key: key);

  ///
  final CameraController controller;

  ///
  final ValueNotifier<CameraType> cameraTypeNotifier;

  ///
  final void Function(CameraLensDirection direction) onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      width: 54.0,
      alignment: Alignment.center,
      child: CameraTypeBuilder(
        notifier: cameraTypeNotifier,
        builder: (context, type, child) {
          if (type == CameraType.text) return const SizedBox();
          return child!;
        },
        child: GestureDetector(
          onTap: () {
            final direction =
                controller.description.lensDirection == CameraLensDirection.back
                    ? CameraLensDirection.front
                    : CameraLensDirection.back;
            onPressed(direction);
          },
          child: CameraBuilder(
            controller: controller,
            builder: (context, value, child) {
              return const Icon(
                CustomIcons.cameraRotate,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}
