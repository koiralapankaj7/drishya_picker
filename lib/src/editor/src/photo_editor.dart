//

import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/drishya_entity.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

///
class PhotoEditor extends StatefulWidget {
  ///
  const PhotoEditor({
    Key? key,
    this.controller,
  }) : super(key: key);

  ///
  final PhotoEditingController? controller;

  /// Open playground
  static Future<DrishyaEntity?> open(
    BuildContext context, {
    PhotoEditingController? controller,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: PhotoEditor(
          controller: controller,
        ),
      ),
    );
  }

  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  late final PhotoEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? PhotoEditingController();
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
        body: PhotoEditingControllerProvider(
          controller: _controller,
          child: ValueListenableBuilder<PhotoValue>(
            valueListenable: _controller,
            builder: (context, value, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Captureable view that shows the background and stickers
                  RepaintBoundary(
                    key: _controller.editorKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Playground background
                        value.background.build(context),

                        // Stickers
                        Opacity(
                          opacity: value.stickerPickerView ? 0.0 : 1.0,
                          child: StickersView(controller: _controller),
                        ),

                        //
                      ],
                    ),
                  ),

                  // Textfield
                  if (!value.enableOverlay)
                    EditorTextfield(controller: _controller),

                  // Overlay
                  if (value.enableOverlay)
                    EditorOverlay(controller: _controller),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}