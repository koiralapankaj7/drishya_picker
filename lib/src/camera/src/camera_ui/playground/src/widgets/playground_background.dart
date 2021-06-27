import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import '../entities/playground_background.dart';

///
class GradientBackgroundView extends StatelessWidget {
  ///
  const GradientBackgroundView({
    Key? key,
    required this.background,
  }) : super(key: key);

  ///
  final GradientBackground background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: background.colors,
        ),
      ),
    );
  }
}

///
class PhotoBackgroundView extends StatelessWidget {
  ///
  const PhotoBackgroundView({
    Key? key,
    required this.background,
  }) : super(key: key);

  ///
  final PhotoBackground background;

  @override
  Widget build(BuildContext context) {
    if (background.bytes != null) {
      return Image.memory(
        background.bytes!,
        fit: BoxFit.cover,
      );
    } else if (background.url != null) {
      return Image.network(
        background.url!,
        fit: BoxFit.cover,
      );
    }

    return const SizedBox();
  }
}

///
class GradientBackgroundChanger extends StatelessWidget {
  ///
  const GradientBackgroundChanger({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  @override
  Widget build(BuildContext context) {
    final background = controller.value.background;
    final isGradient = background is GradientBackground;
    return GestureDetector(
      onTap: controller.changeBackground,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(
          side: BorderSide(
            color: Colors.white,
            width: 2.0,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 54.0,
          height: 54.0,
          child: GradientBackgroundView(
            background:
                isGradient ? background as GradientBackground : gradients[0],
          ),
        ),
      ),
    );
  }
}
