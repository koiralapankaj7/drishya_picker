import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';

///
class PlaygroundTextfield extends StatelessWidget {
  ///
  const PlaygroundTextfield({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  void _addSticker(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final sticker = Sticker(
        name: '',
        size: box.size,
        widget: key.currentWidget,
      );
      controller.stickerController.addSticker(sticker);
    }
  }

  void _onTextChanged(BuildContext context, GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final actualWidth = MediaQuery.of(context).size.width;
      final currentWidth = box.size.width;
      controller.value = controller.value.copyWith(
        maxLines: currentWidth >= actualWidth ? null : 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return TextSticker(
      hasFocus: value.hasFocus,
      fillColor: value.fillColor,
      textAlign: value.textAlign,
      maxLines: value.maxLines.isNegative ? null : value.maxLines,
      onChanged: _onTextChanged,
      onPressedOutside: (createSticker, ctx, key) {
        controller.updateValue(hasFocus: false);
        if (createSticker) {
          _addSticker(key);
        }
      },
    );
  }
}

///
class TextSticker extends StatefulWidget {
  ///
  const TextSticker({
    Key? key,
    required this.hasFocus,
    required this.fillColor,
    required this.textAlign,
    required this.maxLines,
    required this.onChanged,
    required this.onPressedOutside,
  }) : super(key: key);

  ///
  final bool hasFocus;

  ///
  final Color fillColor;

  ///
  final TextAlign textAlign;

  ///
  final int? maxLines;

  ///
  final void Function(BuildContext context, GlobalKey key) onChanged;

  ///
  final void Function(bool createSticker, BuildContext context, GlobalKey key)
      onPressedOutside;

  @override
  _TextStickerState createState() => _TextStickerState();
}

class _TextStickerState extends State<TextSticker> {
  late final TextEditingController _controller;
  late final GlobalKey _key;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressedOutside(_controller.text.isNotEmpty, context, _key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        color: widget.hasFocus ? Colors.black54 : Colors.transparent,
        child: IntrinsicWidth(
          key: _key,
          child: Container(
            constraints: const BoxConstraints(minWidth: 20.0),
            margin: const EdgeInsets.symmetric(
              horizontal: 60.0,
              vertical: 30.0,
            ),
            decoration: BoxDecoration(
              color: widget.fillColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              controller: _controller,
              autofocus: false,
              textAlign: widget.textAlign,
              autocorrect: false,
              minLines: null,
              maxLines: widget.maxLines,
              keyboardType: TextInputType.multiline,
              smartDashesType: SmartDashesType.disabled,
              style: const TextStyle(
                textBaseline: TextBaseline.ideographic,
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
                decorationThickness: 0.0,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.all(8.0),
              ),
              onChanged: (text) {
                widget.onChanged(context, _key);
              },
            ),
          ),
        ),
      ),
    );
  }
}
