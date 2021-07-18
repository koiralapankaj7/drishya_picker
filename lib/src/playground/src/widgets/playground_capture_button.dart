import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
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
        final crossFadeState =
            !value.hasStickers || value.isEditing || value.hasFocus
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond;
        return AppAnimatedCrossFade(
          firstChild: const SizedBox(),
          secondChild: child!,
          crossFadeState: crossFadeState,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: GestureDetector(
        onTap: () async {
          final entity = await controller.takeScreenshot();
          if (entity != null) {
            Navigator.of(context).pop(entity);
          } else {
            UIHandler(context).showSnackBar(
              'Something went wront! Please try again.',
            );
          }
        },
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
