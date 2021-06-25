import 'package:drishya_picker/src/camera/src/camera_ui/builders/action_detector.dart';
import 'package:flutter/material.dart';

///
class GradientBackground extends StatelessWidget {
  ///
  const GradientBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: value.background.colors,
            ),
          ),
        );
      },
    );
  }
}

///
class GradientBackgroundChanger extends StatelessWidget {
  ///
  const GradientBackgroundChanger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (action.hideBackgroundChangerButton) {
          return const SizedBox();
        }
        return GestureDetector(
          onTap: action.changeBackground,
          child: const Material(
            color: Colors.transparent,
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: 54.0,
              height: 54.0,
              child: GradientBackground(),
            ),
          ),
        );
      },
    );
  }
}
