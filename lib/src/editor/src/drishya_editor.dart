import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
class DrishyaEditor extends StatefulWidget {
  ///
  const DrishyaEditor({
    Key? key,
    this.controller,
    this.hideOverlay = false,
  }) : super(key: key);

  ///
  final DrishyaEditingController? controller;

  ///
  final bool hideOverlay;

  /// Open drishya editor
  static Future<DrishyaEntity?> open(
    BuildContext context, {
    DrishyaEditingController? controller,
    bool hideOverlay = false,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: DrishyaEditor(
          controller: controller,
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = widget.controller ?? DrishyaEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          await SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
          return true;
        },
        child: PhotoEditingControllerProvider(
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
                          child: _controller.value.background.build(context),
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
      ),
    );
  }
}
