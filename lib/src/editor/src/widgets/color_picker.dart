import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class ColorPicker extends StatelessWidget {
  ///
  const ColorPicker({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EditorValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final visible = !value.isEditing &&
            (value.isColorPickerOpen || value.keyboardVisible);

        if (!visible) return const SizedBox();

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: value.keyboardVisible ? 16 : 100,
            ),
            child: child,
          ),
        );
      },
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: controller.setting.colors
            .map(
              (color) => _ColorCircle(
                color: color,
                controller: controller,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    Key? key,
    required this.color,
    required this.controller,
  }) : super(key: key);

  final Color color;
  final DrishyaEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: controller.colorNotifier,
      builder: (context, c, child) {
        final isSelected = color == c;
        final size = isSelected ? 36.0 : 30.0;
        return InkWell(
          onTap: () {
            controller.colorNotifier.value = color;
            controller.updateValue(textColor: color);
          },
          child: SizedBox(
            height: 40,
            width: 40,
            child: Align(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: size,
                width: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(size),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: CircleAvatar(backgroundColor: color),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
