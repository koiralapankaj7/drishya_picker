//
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'entities/playground_background.dart';
import 'widgets/playground_background.dart';
import 'widgets/playground_builder.dart';
import 'widgets/playground_stickers.dart';

///
class Playground extends StatefulWidget {
  ///
  const Playground({
    Key? key,
  }) : super(key: key);

  @override
  _PlaygroundState createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  @override
  Widget build(BuildContext context) {
    return PlaygroundBuilder(
      builder: (controller, value, child) {
        final background = value.background is GradientBackground
            ? GradientBackgroundView(
                background: value.background as GradientBackground,
              )
            : PhotoBackgroundView(
                background: value.background as PhotoBackground,
              );
        return RepaintBoundary(
          key: controller.playgroundKey,
          child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                // background
                background,

                //
                PlaygroundStickers(controller: controller),

                //
              ],
            ),
          ),
        );
      },
    );
  }
}
