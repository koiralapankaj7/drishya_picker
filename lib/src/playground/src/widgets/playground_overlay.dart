import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../controller/playground_controller.dart';
import '../entities/playground_value.dart';
import 'playground_add_text_button.dart';
import 'playground_background.dart';
import 'playground_button_collection.dart';
import 'playground_capture_button.dart';
import 'playground_close_button.dart';
import 'playground_textfield.dart';

///
class PlaygroundOverlay extends StatelessWidget {
  ///
  const PlaygroundOverlay({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 4.0;

    return ValueListenableBuilder<PlaygroundValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            //
            // Add text button
            Align(
              alignment: Alignment.center,
              child: PlaygroundAddTextButton(controller: controller),
            ),

            // Textfield
            PlaygroundTextfield(controller: controller),

            // Close button
            Positioned(
              left: 8.0,
              top: top,
              child: PlaygroundCloseButton(controller: controller),
            ),

            // Background changer
            Positioned(
              left: 16.0,
              bottom: 16.0,
              child:
                  PlaygroundGradientBackgroundChanger(controller: controller),
            ),

            // Screenshot capture button
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: PlaygroundCaptureButton(controller: controller),
            ),

            // Sticker buttons
            Positioned(
              right: 16.0,
              top: top,
              child: PlaygroundButtonCollection(controller: controller),
            ),

            //
          ],
        );
      },
    );
  }
}
