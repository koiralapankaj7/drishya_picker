import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';
import 'playground_builder.dart';
import 'playground_sticker_picker.dart';

///
class PlaygroundButtonCollection extends StatelessWidget {
  ///
  PlaygroundButtonCollection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  final PageStorageBucket _bucket = PageStorageBucket();

  void _onStickerIconPressed(BuildContext context) {
    showModalBottomSheet<Sticker>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StickerPicker(
        initialIndex: 0,
        bucket: _bucket,
        onTabChanged: (index) {},
        onStickerSelected: (sticker) {
          controller.stickerController.addSticker(sticker);
          controller.updateValue(hasStickers: true);
          Navigator.of(context).pop();
        },
      ),
    );
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
      default:
        textAlign = TextAlign.center;
    }
    controller.updateValue(textAlign: textAlign);
  }

  void _textBackgroundButtonPressed() {
    final value = controller.value;
    controller.value = value.copyWith(
      fillColor: value.fillColor == Colors.transparent
          ? Colors.indigo
          : Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = controller.value.hasFocus;
    return PlaygroundBuilder(
      controller: controller,
      builder: (context, value, child) {
        if (value.isEditing) return const SizedBox();
        return child!;
        //
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
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
            onPressed: _textBackgroundButtonPressed,
            child: _TextBackgroundIcon(
              isSelected: controller.value.fillColor != Colors.transparent,
            ),
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
  }) : super(key: key);

  final bool isVisible;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox();

    return GestureDetector(
      onTap: onPressed,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 12.0),
        child: Text(
          'DONE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.0,
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
    this.margin = 8.0,
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
    if (!isVisible) return const SizedBox();

    final isText = label?.isNotEmpty ?? false;
    final isIcon = iconData != null;

    final text = Text(
      label ?? 'Aa',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: fontSize ?? 20.0,
        color: labelColor ?? Colors.white,
      ),
    );

    final icon = Icon(
      iconData ?? Icons.emoji_emotions,
      color: Colors.white,
      size: 24.0,
    );

    return InkWell(
      onTap: onPressed,
      child: Container(
        height: size ?? 48.0,
        width: size ?? 48.0,
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: margin),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background ?? Colors.black38,
        ),
        child: isText ? text : (isIcon ? icon : child),
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isLast = index == count - 1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 2.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.0),
            ),
            margin: isLast
                ? EdgeInsets.only(bottom: 0.0, left: left, right: right)
                : const EdgeInsets.only(bottom: 5.0),
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
      margin: const EdgeInsets.all(10.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: isSelected ? null : Border.all(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        'A',
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20.0,
        ),
      ),
    );
  }
}
