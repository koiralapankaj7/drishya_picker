import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../entities/camera_type.dart';
import '../../utils/custom_icons.dart';
import '../builders/action_detector.dart';

///
class FlashButton extends StatelessWidget {
  ///
  const FlashButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (value.cameraType == CameraType.text ||
            (value.cameraType == CameraType.selfi &&
                action.lensDirection != CameraLensDirection.back) ||
            action.lensDirection != CameraLensDirection.back ||
            value.isRecordingVideo) {
          return const SizedBox();
        }
        final isOn = action.value.flashMode != FlashMode.off;
        return GestureDetector(
          onTap: action.changeFlashMode,
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
    );
  }
}
