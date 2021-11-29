//
// ignore_for_file: always_use_package_imports

import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/drishya_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'controller/playground_controller.dart';
import 'entities/playground_value.dart';
import 'widgets/playground_controller_provider.dart';
import 'widgets/playground_overlay.dart';
import 'widgets/playground_stickers.dart';
import 'widgets/playground_textfield.dart';

///
class Playground extends StatefulWidget {
  ///
  const Playground({
    Key? key,
    this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController? controller;

  /// Open playground
  static Future<DrishyaEntity?> open(
    BuildContext context, {
    PlaygroundController? controller,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: Playground(
          controller: controller,
        ),
      ),
    );
  }

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  late final PlaygroundController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PlaygroundController();
    // if (widget.controller?.value.background != null) {
    //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: PlaygroundControllerProvider(
          controller: _controller,
          child: ValueListenableBuilder<PlaygroundValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Captureable view that shows the background and stickers
                  RepaintBoundary(
                    key: _controller.playgroundKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Playground background
                        value.background.build(context),

                        // Stickers
                        Opacity(
                          opacity: value.stickerPickerView ? 0.0 : 1.0,
                          child: PlaygroundStickers(controller: _controller),
                        ),

                        //
                      ],
                    ),
                  ),

                  // Textfield
                  if (!value.enableOverlay)
                    PlaygroundTextfield(controller: _controller),

                  // Overlay
                  if (value.enableOverlay)
                    PlaygroundOverlay(controller: _controller),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
