import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class BackgroundSwitcher extends StatelessWidget {
  ///
  const BackgroundSwitcher({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  @override
  Widget build(BuildContext context) {
    assert(
      controller.setting.backgrounds.isNotEmpty,
      'Backgrounds cannot be empty',
    );

    if (controller.value.background is! GradientBackground ||
        controller.value.keyboardVisible) {
      return const SizedBox();
    }

    return EditorBuilder(
      controller: controller,
      builder: (context, value, child) {
        final crossFadeState = value.isEditing
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond;
        return AppAnimatedCrossFade(
          firstChild: const SizedBox(),
          secondChild: child!,
          crossFadeState: crossFadeState,
          duration: const Duration(milliseconds: 200),
        );
      },
      child: GestureDetector(
        onTap: controller.changeBackground,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(
            side: BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: 54,
            height: 54,
            child: (controller.value.background ??
                    controller.setting.backgrounds.first)
                .build(context),
          ),
        ),
      ),
    );
  }
}
