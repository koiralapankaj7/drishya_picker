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
        final visible = !value.isEditing && value.isColorPickerOpen;

        if (!visible) return const SizedBox();

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              top: 16,
              bottom: value.keyboardVisible ? 16 : 100,
            ),
            child: child,
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          var colorCount = ((constraints.maxWidth - 32) / 50).floor();
          if (colorCount.isEven) {
            --colorCount;
          }
          final itemCount =
              (controller.setting.colors.length / colorCount).ceil();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 50,
                child: PageView.builder(
                  itemCount: itemCount,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final colors = controller.setting.colors
                        .skip(index * colorCount)
                        .take(colorCount);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: colors
                          .map(
                            (color) => _ColorCircle(
                              color: color,
                              controller: controller,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              if (itemCount > 1)
                Container(
                  height: 6,
                  width: 50,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
            ],
          );
        },
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
          },
          child: SizedBox(
            height: 50,
            width: 50,
            child: Align(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: size,
                width: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: isSelected ? 6 : 3,
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
