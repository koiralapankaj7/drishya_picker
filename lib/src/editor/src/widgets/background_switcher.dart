import 'package:drishya_picker/src/editor/editor.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
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

    return EditorBuilder(
      controller: controller,
      builder: (context, value, child) {
        return ValueListenableBuilder<EditorBackground>(
          valueListenable: controller.backgroundNotifier,
          builder: (context, background, child) {
            if (background is! GradientBackground ||
                value.keyboardVisible ||
                value.isEditing) {
              return const SizedBox();
            }

            return GestureDetector(
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
                  child: background.build(context),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
