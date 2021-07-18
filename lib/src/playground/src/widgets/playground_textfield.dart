import 'dart:ui';

import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/playground_controller.dart';

///
class PlaygroundTextfield extends StatefulWidget {
  ///
  const PlaygroundTextfield({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  @override
  _PlaygroundTextfieldState createState() => _PlaygroundTextfieldState();
}

class _PlaygroundTextfieldState extends State<PlaygroundTextfield> {
  late final GlobalKey _tfSizeKey;
  late final GlobalKey _widthKey;
  late final PlaygroundController _controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _tfSizeKey = GlobalKey();
    _widthKey = GlobalKey();
    _controller = widget.controller;
    _textController = _controller.textController;
  }

  void _addSticker() {
    final box = _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final sticker = TextSticker(
        size: box.size,
        extra: {'text': _textController.text},
        onPressed: (s) {
          _textController.text = (s as TextSticker).text;
        },
        text: _textController.text,
        style: _textStickerStyle,
        textAlign: _controller.value.textAlign,
        withBackground: _controller.value.fillColor,
      );

      _controller.updateValue(hasStickers: true);
      _textController.clear();

      Future.delayed(const Duration(milliseconds: 20), () {
        _controller.stickerController.addSticker(sticker);
      });
    }
  }

  // void _onTextChanged(String text) {
  //   final box = _widthKey.currentContext?.findRenderObject() as RenderBox?;
  //   if (box != null) {
  //     final actualWidth = MediaQuery.of(context).size.width;
  //     final currentWidth = box.size.width;
  //     if (currentWidth == actualWidth) {
  //       log('Add new line...');
  //     }

  //     // widget.controller.value = widget.controller.value.copyWith(
  //     //   maxLines: currentWidth >= actualWidth ? -1 : 1,
  //     // );
  //   }
  // }

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
          if (_textController.text.isNotEmpty) {
            _addSticker();
          }
        },
        child: Center(
          child: IntrinsicWidth(
            key: _widthKey,
            stepWidth: 20.0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20.0),
              margin: const EdgeInsets.symmetric(
                horizontal: 60.0,
                vertical: 30.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: value.fillColor
                    ? value.textBackground.colors.first
                    : Colors.transparent,
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
                style: _textStickerStyle,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8.0),
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

///
const _textStickerStyle = TextStyle(
  textBaseline: TextBaseline.ideographic,
  color: Colors.white,
  fontSize: 32.0,
  fontWeight: FontWeight.w700,
  decoration: TextDecoration.none,
  decorationColor: Colors.transparent,
  decorationThickness: 0.0,
);
