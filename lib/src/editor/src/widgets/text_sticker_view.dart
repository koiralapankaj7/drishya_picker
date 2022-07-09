import 'package:flutter/material.dart';

///
class TextStickerView extends StatelessWidget {
  ///
  const TextStickerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // constraints: const BoxConstraints(minWidth: 20),
      // margin: const EdgeInsets.symmetric(
      //   horizontal: 60,
      //   vertical: 30,
      // ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amber,
      ),
      child: TextFormField(
        // key: _tfSizeKey,
        // controller: _textController,
        // focusNode: _controller.focusNode,
        autofocus: true,
        // textAlign: value.textAlign,
        autocorrect: false,
        minLines: 1,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        smartDashesType: SmartDashesType.disabled,
        style: const TextStyle(
          textBaseline: TextBaseline.ideographic,
          color: Colors.black,
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
      ),
    );
  }
}
