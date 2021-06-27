import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controllers/action_notifier.dart';

///
class RotateButton extends StatelessWidget {
  ///
  const RotateButton({
    Key? key,
    required this.action,
  }) : super(key: key);

  ///
  final ActionNotifier action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
      width: 54.0,
      alignment: Alignment.center,
      child: action.hideCameraRotationButton
          ? const SizedBox()
          : GestureDetector(
              onTap: () {
                action.switchCameraDirection(action.oppositeLensDirection);
              },
              child: const Icon(
                CustomIcons.cameraRotate,
                color: Colors.white,
              ),
            ),
    );
  }
}
