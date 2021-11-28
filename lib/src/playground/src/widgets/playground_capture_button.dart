// ignore_for_file: always_use_package_imports

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
          crossFadeState: crossFadeState,
          duration: const Duration(milliseconds: 300),
          firstChild: const SizedBox(),
          secondChild: IgnorePointer(
            ignoring: crossFadeState == CrossFadeState.showFirst,
            child: InkWell(
              onTap: () async {
                if (controller.value.colorPickerVisibility) {
                  controller.updateValue(colorPickerVisibility: false);
                  return;
                }
                final entity = await controller.takeScreenshot();
                if (entity != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(entity);
                } else {
                  // ignore: use_build_context_synchronously
                  UIHandler(context).showSnackBar(
                    'Something went wront! Please try again.',
                  );
                }
              },
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.only(left: 4),
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
          ),
        );
      },
    );
  }
}
