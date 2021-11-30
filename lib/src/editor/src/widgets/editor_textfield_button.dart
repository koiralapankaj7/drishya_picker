import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class EditorTextfieldButton extends StatelessWidget {
  ///
  const EditorTextfieldButton({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PhotoEditingController controller;

  @override
  Widget build(BuildContext context) {
    return EditorBuilder(
      controller: controller,
      builder: (context, value, child) {
        if (value.hasStickers || value.hasFocus || value.isEditing) {
          return const SizedBox();
        }
        return child!;
      },
      child: GestureDetector(
        onTap: () {
          controller.updateValue(hasFocus: true);
        },
        child: const Text(
          'Tap to type...',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
