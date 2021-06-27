import 'package:drishya_picker/src/camera/src/utils/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';

///
class PlaygroundCaptureButton extends StatelessWidget {
  ///
  const PlaygroundCaptureButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.takeScreenshot,
      child: Container(
        width: 56.0,
        height: 56.0,
        padding: const EdgeInsets.only(left: 4.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: const Icon(
          CustomIcons.send,
          color: Colors.blue,
        ),
      ),
    );
  }
}
