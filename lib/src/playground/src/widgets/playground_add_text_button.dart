import 'package:drishya_picker/src/animations/animations.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import 'playground_builder.dart';

///
class PlaygroundAddTextButton extends StatelessWidget {
  ///
  const PlaygroundAddTextButton({
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
            value.hasStickers || value.hasFocus || value.isEditing
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
        onTap: () {
          controller.updateValue(hasFocus: true);
        },
        child: const Text(
          'Tap to type...',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 30.0,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
