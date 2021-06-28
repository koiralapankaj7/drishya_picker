import 'package:camera/camera.dart';
import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controllers/action_notifier.dart';

///
class FlashButton extends StatelessWidget {
  ///
  const FlashButton({
    Key? key,
    required this.action,
  }) : super(key: key);

  ///
  final ActionNotifier action;

  @override
  Widget build(BuildContext context) {
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
  }
}
