import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import 'playground_builder.dart';

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
    return PlaygroundBuilder(
      controller: controller,
      builder: (context, value, child) {
        if (!value.hasStickers || value.isEditing) return const SizedBox();
        return child!;
      },
      child: GestureDetector(
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
      ),
    );
  }
}
