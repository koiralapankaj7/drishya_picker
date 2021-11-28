// ignore_for_file: always_use_package_imports

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

const _top = 16.0;

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
    return ValueListenableBuilder<PlaygroundValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            //
            // Add text button
            Align(
              child: PlaygroundAddTextButton(controller: controller),
            ),

            // Textfield
            PlaygroundTextfield(controller: controller),

            // Close button
            Positioned(
              left: 8,
              top: _top,
              child: PlaygroundCloseButton(controller: controller),
            ),

            // Background changer
            Positioned(
              left: 16,
              bottom: 16,
              child:
                  PlaygroundGradientBackgroundChanger(controller: controller),
            ),

            // Screenshot capture button
            Positioned(
              right: 16,
              bottom: 16,
              child: PlaygroundCaptureButton(controller: controller),
            ),

            // Sticker buttons
            Positioned(
              right: 16,
              top: controller.value.stickerPickerView ? 0.0 : _top,
              child: PlaygroundButtonCollection(controller: controller),
            ),

            //
          ],
        );
      },
    );
  }
}
