import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

///
class EditorShutterButton extends StatelessWidget {
  ///
  const EditorShutterButton({
    Key? key,
    required this.controller,
    this.onSuccess,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  ///
  final ValueSetter<DrishyaEntity>? onSuccess;

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
          firstChild: const SizedBox(),
          secondChild: IgnorePointer(
            ignoring: crossFadeState == CrossFadeState.showFirst,
            child: InkWell(
              onTap: () async {
                if (controller.value.isColorPickerOpen) {
                  controller.updateValue(isColorPickerOpen: false);
                  return;
                }
                final uiHandler = UIHandler.of(context);

                final entity = await controller.completeEditing();
                if (entity != null) {
                  UIHandler.transformFrom = TransitionFrom.topToBottom;
                  if (onSuccess != null) {
                    onSuccess!(entity);
                  } else {
                    uiHandler.pop(entity);
                  }
                } else {
                  uiHandler.showSnackBar(
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
