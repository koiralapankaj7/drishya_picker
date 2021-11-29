// ignore_for_file: always_use_package_imports

import 'dart:typed_data';

import 'package:drishya_picker/src/animations/animations.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import '../entities/playground_background.dart';
import 'playground_builder.dart';

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
          if (background.entity != null) {
            return FutureBuilder<Uint8List?>(
              future: background.entity!.originBytes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.contain,
                  );
                }
                return const SizedBox();
              },
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
class PlaygroundGradientBackgroundChanger extends StatelessWidget {
  ///
  const PlaygroundGradientBackgroundChanger({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.value.background is PhotoBackground) {
      return const SizedBox();
    }

    return PlaygroundBuilder(
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
