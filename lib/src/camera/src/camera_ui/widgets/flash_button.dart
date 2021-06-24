import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../entities/camera_type.dart';
import '../../utils/custom_icons.dart';
import '../builders/camera_type_builder.dart';

///
class FlashButton extends StatelessWidget {
  ///
  const FlashButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CameraTypeBuilder(
      builder: (action, type, child) {
        if (type == CameraType.text || type == CameraType.selfi) {
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
