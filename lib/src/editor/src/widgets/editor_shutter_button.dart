import 'dart:async';

import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
class EditorShutterButton extends StatelessWidget {
  ///
  const EditorShutterButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  @override
  Widget build(BuildContext context) {
    return EditorBuilder(
      controller: controller,
      builder: (context, value, child) {
        final crossFadeState =
            (controller.currentBackground is GradientBackground &&
                        !value.hasStickers) ||
                    value.isEditing ||
                    value.hasFocus
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
                if (controller.value.isColorPickerOpen) {
                  controller.updateValue(isColorPickerOpen: false);
                  return;
                }
                final navigator = Navigator.of(context);

                final entity = await controller.completeEditing();
                if (entity != null) {
                  if (drishyaUIMode == SystemUiMode.manual) {
                    unawaited(
                      SystemChrome.setEnabledSystemUIMode(
                        drishyaUIMode,
                        overlays: SystemUiOverlay.values,
                      ),
                    );
                  }
                  if (!navigator.mounted) return;
                  navigator.pop(entity);
                } else {
                  if (!navigator.mounted) return;
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
