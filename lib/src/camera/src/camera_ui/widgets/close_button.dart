import 'package:drishya_picker/src/camera/src/camera_ui/builders/action_detector.dart';
import 'package:flutter/material.dart';

import '../../utils/custom_icons.dart';

///
class CloseButton extends StatelessWidget {
  ///
  const CloseButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (value.hasFocus) return const SizedBox();

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
