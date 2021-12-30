import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

///
class DrishyaEditor extends StatefulWidget {
  ///
  const DrishyaEditor({
    Key? key,
    this.controller,
    this.setting,
    this.hideOverlay = false,
  }) : super(key: key);

  ///
  /// Drishya editing controller
  final DrishyaEditingController? controller;

  ///
  /// Setting for the editor
  final EditorSetting? setting;

  ///
  /// Hide editor overlay
  final bool hideOverlay;

  /// Open drishya editor
  static Future<DrishyaEntity?> open(
    BuildContext context, {
    DrishyaEditingController? controller,
    EditorSetting? setting,
    bool hideOverlay = false,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: DrishyaEditor(
          controller: controller,
          setting: setting,
          hideOverlay: hideOverlay,
        ),
      ),
    );
  }

  @override
  State<DrishyaEditor> createState() => _DrishyaEditorState();
}

class _DrishyaEditorState extends State<DrishyaEditor> {
  late DrishyaEditingController _controller;

  @override
  void initState() {
    super.initState();
    UIHandler.hideStatusBar();
    _controller = (widget.controller ?? DrishyaEditingController())
      ..init(setting: widget.setting);
  }

  @override
  void dispose() {
    UIHandler.transformFrom = null;
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      _controller.setting.backgrounds.isNotEmpty &&
          _controller.setting.colors.isNotEmpty,
      'Backgrounds and Colors cannot be empty',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoEditingControllerProvider(
        controller: _controller,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            // Captureable view that shows the background and stickers
            RepaintBoundary(
              key: _controller.editorKey,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // Playground background
                  Stack(
                    children: [
                      Positioned(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: ValueListenableBuilder<EditorBackground>(
                          valueListenable: _controller.backgroundNotifier,
                          builder: (context, bg, child) => bg.build(context),
                        ),
                      ),
                    ],
                  ),

                  // Stickers
                  StickersView(controller: _controller),

                  //
                ],
              ),
            ),

            //
            EditorTextfieldButton(controller: _controller),

            // Textfield
            EditorTextfield(controller: _controller),

            // Overlay
            if (!widget.hideOverlay) EditorOverlay(controller: _controller),

            // Color picker
            ColorPicker(controller: _controller),

            //
          ],
        ),
      ),
    );
  }
}
