import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

StickerAsset? _editingTextAsset;

///
class EditorTextfield extends StatefulWidget {
  ///
  const EditorTextfield({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PhotoEditingController controller;

  @override
  State<EditorTextfield> createState() => _EditorTextfieldState();
}

class _EditorTextfieldState extends State<EditorTextfield> {
  late final GlobalKey _tfSizeKey;
  late final GlobalKey _widthKey;
  late final PhotoEditingController _controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _tfSizeKey = GlobalKey();
    _widthKey = GlobalKey();
    _controller = widget.controller..addListener(_listener);
    _textController = _controller.textController;
  }

  void _listener() {
    if (!_controller.value.hasFocus && _textController.text.isNotEmpty) {
      _addSticker();
    }
  }

  void _addSticker() {
    final box = _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      // _controller.removeListener(_listener);
      final sticker = TextSticker(
        // size: box.size, // This size will be the smallest one

        size: _editingTextAsset?.size.size ?? box.size,
        extra: {'text': _textController.text},
        onPressed: (asset) {
          _editingTextAsset = asset;
          _textController.text = (asset.sticker as TextSticker).text;
        },
        text: _textController.text,
        style: TextStyle(
          textBaseline: TextBaseline.ideographic,
          color: widget.controller.value.background is! GradientBackground &&
                  !widget.controller.value.fillTextfield
              ? widget.controller.value.textColor
              : Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),
        background: widget.controller.value.background is! GradientBackground &&
                widget.controller.value.fillTextfield
            ? widget.controller.value.textColor
            : Colors.white,
        textAlign: _controller.value.textAlign,
        withBackground: _controller.value.fillTextfield,
      );

      _textController.clear();
      _controller.stickerController.addSticker(
        sticker,
        size: _editingTextAsset?.size,
        angle: _editingTextAsset?.angle,
        constraint: _editingTextAsset?.constraint,
        position: _editingTextAsset?.position,
      );
      _editingTextAsset = null;
      _controller.updateValue(hasStickers: true);

      // Future.delayed(const Duration(milliseconds: 20), () {
      //   _controller.stickerController.addSticker(sticker);
      //   _controller.addListener(_listener);
      // });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;

    if (!value.hasFocus) return const SizedBox();

    return Scaffold(
      backgroundColor: value.hasFocus ? Colors.black54 : Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.controller.updateValue(hasFocus: false);
        },
        child: Center(
          child: IntrinsicWidth(
            key: _widthKey,
            stepWidth: 20,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20),
              margin: const EdgeInsets.symmetric(
                horizontal: 60,
                vertical: 30,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:
                    value.fillTextfield ? value.textColor : Colors.transparent,
              ),
              child: TextFormField(
                key: _tfSizeKey,
                controller: _textController,
                autofocus: true,
                textAlign: value.textAlign,
                autocorrect: false,
                minLines: 1,
                maxLines: null,
                // maxLines: value.convertedMaxLines,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                smartDashesType: SmartDashesType.disabled,
                style: TextStyle(
                  textBaseline: TextBaseline.ideographic,
                  color: widget.controller.value.background
                              is! GradientBackground &&
                          !widget.controller.value.fillTextfield
                      ? widget.controller.value.textColor
                      : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                  decorationThickness: 0,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                  // filled: value.fillColor,
                  // fillColor: value.textBackground.colors.first,
                  // focusedBorder: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(10.0),
                  //   borderSide: BorderSide.none,
                  // ),
                ),
                // onChanged: _onTextChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
