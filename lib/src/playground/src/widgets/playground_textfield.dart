import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';

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

  Widget get _sticker {
    return Container(
      decoration: BoxDecoration(
        color: _controller.value.fillColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          _textController.text,
          style: _textStickerStyle,
          textAlign: _controller.value.textAlign,
        ),
      ),
    );
  }

  void _addSticker() {
    final box = _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final sticker = Sticker(
        name: '',
        size: box.size,
        extra: {'text': _textController.text},
        onPressed: (s) {
          _textController.text = s.extra['text'] ?? '';
        },
        widget: _sticker,
      );

      _controller.updateValue(hasStickers: true);
      _textController.clear();

      Future.delayed(const Duration(milliseconds: 20), () {
        _controller.stickerController.addSticker(sticker);
      });
    }
  }

  void _onTextChanged(String text) {
    final box = _widthKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final actualWidth = MediaQuery.of(context).size.width;
      final currentWidth = box.size.width;
      widget.controller.value = widget.controller.value.copyWith(
        maxLines: currentWidth >= actualWidth ? -1 : 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;

    if (!value.hasFocus) return const SizedBox();

    return GestureDetector(
      onTap: () {
        widget.controller.updateValue(hasFocus: false);
        if (_textController.text.isNotEmpty) {
          _addSticker();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        color: value.hasFocus ? Colors.black54 : Colors.transparent,
        child: IntrinsicWidth(
          key: _widthKey,
          child: TextStickerWrapper(
            color: value.fillColor,
            child: TextField(
              key: _tfSizeKey,
              controller: _textController,
              autofocus: true,
              textAlign: value.textAlign,
              autocorrect: false,
              minLines: null,
              maxLines: value.convertedMaxLines,
              keyboardType: TextInputType.multiline,
              smartDashesType: SmartDashesType.disabled,
              style: _textStickerStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.all(8.0),
              ),
              onChanged: _onTextChanged,
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
  fontSize: 28.0,
  fontWeight: FontWeight.w600,
  decoration: TextDecoration.none,
  decorationColor: Colors.transparent,
  decorationThickness: 0.0,
);

///
class TextStickerWrapper extends StatelessWidget {
  ///
  const TextStickerWrapper({
    Key? key,
    required this.child,
    required this.color,
    this.alignment,
  }) : super(key: key);

  ///
  final Widget child;

  ///
  final Color color;

  ///
  final Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20.0),
      margin: const EdgeInsets.symmetric(
        horizontal: 60.0,
        vertical: 30.0,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      alignment: alignment,
      child: child,
    );
  }
}
