//
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'controller/playground_controller.dart';
import 'entities/playground_background.dart';
import 'entities/playground_value.dart';
import 'widgets/playground_background.dart';
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
    this.background,
    this.enableOverlay = false,
  }) : super(key: key);

  ///
  final PlaygroundController? controller;

  ///
  final PlaygroundBackground? background;

  ///
  final bool enableOverlay;

  @override
  _PlaygroundState createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  late final PlaygroundController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        PlaygroundController(
          background: widget.background,
        );
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: PlaygroundControllerProvider(
        controller: _controller,
        child: ValueListenableBuilder<PlaygroundValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            final background = value.background is GradientBackground
                ? GradientBackgroundView(
                    background: value.background as GradientBackground,
                  )
                : PhotoBackgroundView(
                    background: value.background as PhotoBackground,
                  );
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
                      background,

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
                PlaygroundTextfield(controller: _controller),

                // Overlay
                if (widget.enableOverlay)
                  PlaygroundOverlay(controller: _controller),
              ],
            );
          },
        ),
      ),
    );
  }
}
