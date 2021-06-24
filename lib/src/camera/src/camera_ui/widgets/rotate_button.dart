import 'package:flutter/material.dart';

import '../../entities/camera_type.dart';
import '../../utils/custom_icons.dart';
import '../builders/action_detector.dart';

///
class RotateButton extends StatelessWidget {
  ///
  const RotateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      width: 54.0,
      alignment: Alignment.center,
      child: ActionDetector(
        onPressed: (action) {
          action.switchCameraDirection(action.oppositeLensDirection);
        },
        builder: (action, constraints) {
          if (action.cameraType.value == CameraType.text) {
            return const SizedBox();
          }

          return const Icon(
            CustomIcons.cameraRotate,
            color: Colors.white,
          );
        },
      ),
    );
  }
}
