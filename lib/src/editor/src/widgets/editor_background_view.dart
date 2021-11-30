import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

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
    return ColoredBox(
      color: Colors.black,
      child: Builder(
        builder: (_) {
          if (background.bytes != null) {
            return Image.memory(
              background.bytes!,
              fit: BoxFit.contain,
            );
          } else if (background.url != null) {
            return Image.network(
              background.url!,
              fit: BoxFit.cover,
            );
          }

          return const SizedBox();
        },
      ),
    );
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
  final PhotoEditingController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.value.background is PhotoBackground) {
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
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Builder(
        builder: (_) {
          final background = controller.value.background;
          final isGradient = background is GradientBackground;

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
                child: GradientBackgroundView(
                  background: isGradient
                      ? background as GradientBackground
                      : gradients[0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
