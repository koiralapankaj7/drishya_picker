import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

final PageStorageBucket _bucket = PageStorageBucket();
var _initialIndex = 0;

///
class EditorButtonCollection extends StatelessWidget {
  ///
  const EditorButtonCollection({
    Key? key,
    required this.controller,
    this.stickerViewBackground,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  ///
  final Color? stickerViewBackground;

  void _onStickerIconPressed(BuildContext context) {
    if (controller.setting.stickers?.isEmpty ?? true) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Stickers not available!')),
        );
      return;
    }
    controller.updateValue(isEditing: true, isStickerPickerOpen: true);
    Navigator.of(context)
        .push<Sticker>(
      SwipeablePageRoute(
        notificationDepth: 1,
        builder: (context) {
          return StickerPicker(
            setting: controller.setting,
            initialIndex: _initialIndex,
            bucket: _bucket,
            onTabChanged: (index) {
              _initialIndex = index;
            },
            onStickerSelected: (sticker) {
              controller.stickerController.addSticker(sticker);
              controller.updateValue(hasStickers: true);
              Navigator.of(context).pop();
            },
            background: controller.value.background is GradientBackground
                ? (controller.value.background as GradientBackground).lastColor
                : Colors.black54,
            onBackground: controller.value.textColor,
          );
        },
      ),
    )
        .then((value) {
      Future.delayed(const Duration(milliseconds: 300), () {
        controller.updateValue(isEditing: false, isStickerPickerOpen: false);
      });
    });
  }

  void _textAlignButtonPressed() {
    late TextAlign textAlign;
    switch (controller.value.textAlign) {
      case TextAlign.center:
        textAlign = TextAlign.end;
        break;
      case TextAlign.end:
        textAlign = TextAlign.start;
        break;
      // ignore: no_default_cases
      default:
        textAlign = TextAlign.center;
    }
    controller.updateValue(textAlign: textAlign);
  }

  // void _textBackgroundButtonPressed() {
  //   final value = controller.value;
  //   controller.value = value.copyWith(fillColor: !value.fillColor);
  // }

  @override
  Widget build(BuildContext context) {
    final hasFocus = controller.value.hasFocus;

    return EditorBuilder(
      controller: controller,
      builder: (context, value, child) {
        final firstChild = value.isStickerPickerOpen
            ? Container(
                height: 70,
                alignment: Alignment.centerRight,
                child: const _DoneButton(
                  isVisible: true,
                  padding: EdgeInsets.zero,
                ),
              )
            : const SizedBox();

        final crossFadeState = value.isStickerPickerOpen || value.isEditing
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond;

        return AppAnimatedCrossFade(
          firstChild: firstChild,
          secondChild: child!,
          crossFadeState: crossFadeState,
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 200),
        );

        //
      },
      child: Column(
        children: [
          _DoneButton(
            onPressed: () {
              controller.updateValue(hasFocus: false);
            },
            isVisible: hasFocus,
          ),
          _Button(
            label: 'Aa',
            size: hasFocus ? 48.0 : 44.0,
            fontSize: hasFocus ? 24.0 : 20.0,
            background: hasFocus ? Colors.white : Colors.black38,
            labelColor: hasFocus ? Colors.black : Colors.white,
            onPressed: () {
              controller.updateValue(hasFocus: !hasFocus);
            },
          ),
          _Button(
            isVisible: hasFocus,
            onPressed: _textAlignButtonPressed,
            child: _TextAlignmentIcon(align: controller.value.textAlign),
          ),
          _Button(
            isVisible: hasFocus,
            onPressed: () {
              controller.updateValue(
                fillTextfield: !controller.value.fillTextfield,
                isColorPickerVisible: !controller.value.fillTextfield &&
                    controller.value.background is! GradientBackground,
              );
            },
            child:
                _TextBackgroundIcon(isSelected: controller.value.fillTextfield),
          ),
          _Button(
            isVisible: !hasFocus,
            iconData: Icons.emoji_emotions,
            onPressed: () {
              _onStickerIconPressed(context);
            },
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({
    Key? key,
    this.isVisible = false,
    this.onPressed,
    this.padding,
  }) : super(key: key);

  final bool isVisible;
  final void Function()? onPressed;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox();

    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        child: const Text(
          'DONE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    this.isVisible = true,
    this.iconData,
    this.child,
    this.background,
    this.margin = 10.0,
    this.label,
    this.labelColor,
    this.onPressed,
    this.size,
    this.fontSize,
  }) : super(key: key);

  final bool isVisible;
  final IconData? iconData;
  final String? label;
  final Widget? child;
  final Color? labelColor;
  final Color? background;
  final double margin;
  final void Function()? onPressed;
  final double? size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox();
    }
    var widget = child ?? const SizedBox();

    if (label?.isNotEmpty ?? false) {
      widget = Text(
        label ?? 'Aa',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: fontSize ?? 20.0,
          color: labelColor ?? Colors.white,
        ),
      );
    }

    if (iconData != null) {
      widget = Icon(
        iconData ?? Icons.emoji_emotions,
        color: Colors.white,
        size: 24,
      );
    }

    return InkWell(
      onTap: onPressed,
      child: Container(
        height: size ?? 44.0,
        width: size ?? 44.0,
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: margin),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background ?? Colors.black38,
        ),
        child: widget,
      ),
    );
  }
}

class _TextAlignmentIcon extends StatelessWidget {
  const _TextAlignmentIcon({
    Key? key,
    this.align = TextAlign.center,
  }) : super(key: key);

  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    const count = 3;
    const sideMargin = 6.0;

    final center = align == TextAlign.center;
    final start = align == TextAlign.start;
    final end = align == TextAlign.end;

    final left = center ? sideMargin : (end ? sideMargin * 2 : 3.0);
    final right = center ? sideMargin : (start ? sideMargin * 2 : 3.0);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isLast = index == count - 1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 2.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: isLast
                ? EdgeInsets.only(left: left, right: right)
                : const EdgeInsets.only(bottom: 5),
          );
        }),
      ),
    );
  }
}

class _TextBackgroundIcon extends StatelessWidget {
  const _TextBackgroundIcon({
    Key? key,
    this.isSelected = false,
  }) : super(key: key);

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      margin: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: isSelected ? null : Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'A',
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }
}
