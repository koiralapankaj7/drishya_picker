import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/drishya_entity.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:drishya_picker/src/widgets/keyboard_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
class PhotoEditor extends StatefulWidget {
  ///
  const PhotoEditor({
    Key? key,
    this.controller,
    this.setting,
    this.hideOverlay = false,
  }) : super(key: key);

  ///
  final PhotoEditingController? controller;

  ///
  final EditorSetting? setting;

  ///
  final bool hideOverlay;

  /// Open playground
  static Future<DrishyaEntity?> open(
    BuildContext context, {
    PhotoEditingController? controller,
    EditorSetting? setting,
    bool hideOverlay = false,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: PhotoEditor(
          controller: controller,
          setting: setting,
          hideOverlay: hideOverlay,
        ),
      ),
    );
  }

  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  late PhotoEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? PhotoEditingController())
      ..init(context, setting: widget.setting);
  }

  @override
  void didUpdateWidget(covariant PhotoEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.setting != widget.setting) {
      _controller.dispose();
      _controller = (widget.controller ?? PhotoEditingController())
        ..init(context, setting: widget.setting);
    }
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
    return WillPopScope(
      onWillPop: () async {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        return true;
      },
      child: KeyboardVisibility(
        listener: (visible) {
          if (!visible) {
            FocusScope.of(context).unfocus();
            _controller.updateValue(
              hasFocus: false,
              isColorPickerVisible: false,
            );
          }
        },
        builder: (context, visible, child) => child!,
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
                          value.background?.build(context) ?? const SizedBox(),

                          // Stickers
                          Opacity(
                            opacity: value.isStickerPickerOpen ? 0.0 : 1.0,
                            child: StickersView(controller: _controller),
                          ),

                          //
                        ],
                      ),
                    ),

                    // Textfield
                    if (value.hasFocus)
                      EditorTextfield(controller: _controller),

                    // Overlay
                    if (!widget.hideOverlay)
                      EditorOverlay(controller: _controller),

                    // Color picker
                    if (((value.hasFocus &&
                                value.background is! GradientBackground) ||
                            value.isColorPickerVisible) &&
                        !value.isEditing)
                      ColorPicker(controller: _controller),

                    //
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
