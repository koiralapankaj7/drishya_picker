// ignore_for_file: unused_element

import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

final PageStorageBucket _bucket = PageStorageBucket();
var _initialIndex = 0;

///
class EditorButtonCollection extends StatefulWidget {
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

  @override
  State<EditorButtonCollection> createState() => _EditorButtonCollectionState();
}

class _EditorButtonCollectionState extends State<EditorButtonCollection> {
  _EditingOption? _currentOption;

  void _onTextAlignButtonPressed(BuildContext context) {
    late TextAlign textAlign;
    switch (widget.controller.value.textAlign) {
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
    widget.controller.updateValue(textAlign: textAlign);
  }

  void _onTextColorChangerPressed(BuildContext context) {
    widget.controller.updateValue(
      fillTextfield: !widget.controller.value.fillTextfield,
    );
  }

  void _onStickerIconPressed(BuildContext context) {
    final controller = widget.controller;
    final setting = controller.setting;

    if (setting.stickers?.isEmpty ?? true) {
      UIHandler.of(context).showSnackBar('Stickers not available!');
      return;
    }

    assert(
      setting.backgrounds.isNotEmpty,
      'Backgrounds and Colors cannot be empty',
    );

    controller.updateValue(isEditing: true, isStickerPickerOpen: true);
    Navigator.of(context)
        .push<Sticker>(
      SwipeablePageRoute(
        notificationDepth: 1,
        builder: (context) {
          final background = controller.currentBackground is GradientBackground
              ? (controller.currentBackground as GradientBackground).lastColor
              : Colors.black.withOpacity(0.7);

          return StickerPicker(
            controller: controller,
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
            background: background,
            onBackground: controller.generateForegroundColor(background),
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

  ///
  List<_EditingOption> get _options {
    return [
      _EditingOption(
        id: 'text-setting',
        label: 'Aa',
        onPressed: (_) {
          if (widget.controller.value.hasFocus) {
            widget.controller.focusNode.unfocus();
          } else {
            widget.controller.updateValue(hasFocus: true);
          }
        },
        items: [
          _EditingOption(
            id: 'text-align-setting',
            onPressed: _onTextAlignButtonPressed,
            disableOnpressed: true,
            child: _TextAlignmentIcon(align: widget.controller.value.textAlign),
          ),
          _EditingOption(
            id: 'text-color-setting',
            onPressed: _onTextColorChangerPressed,
            disableOnpressed: true,
            child: _TextBackgroundIcon(
              isSelected: widget.controller.value.fillTextfield,
            ),
          ),
        ],
      ),
      _EditingOption(
        id: 'sticker-picker',
        icon: Icons.emoji_emotions,
        onPressed: _onStickerIconPressed,
        disableOnpressed: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return EditorBuilder(
      controller: widget.controller,
      builder: (context, value, child) {
        // Done button while sticker picker is open
        if (value.isStickerPickerOpen) {
          return Container(
            height: 70,
            alignment: Alignment.centerRight,
            child: const _DoneButton(padding: EdgeInsets.zero),
          );
        }

        if (value.isEditing) return const SizedBox();

        _currentOption = value.keyboardVisible ? _options[0] : null;

        // Button list
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...List.generate(_options.length, (index) {
              final option = _options[index];
              final isSelected = _currentOption?.id == option.id;
              final visible =
                  _currentOption == null || _currentOption?.id == option.id;

              return Padding(
                padding: index != 0
                    ? const EdgeInsets.only(top: 8)
                    : EdgeInsets.zero,
                child: _OptionView(
                  option: option,
                  isSelected: isSelected,
                  visible: visible,
                  onPressed: () {
                    setState(() {
                      _currentOption =
                          _currentOption?.id == option.id ? null : option;
                    });
                  },
                  onDonePressed: widget.controller.focusNode.unfocus,
                ),
              );
            })

            //
          ],
        );
      },
    );
  }
}

class _OptionView extends StatefulWidget {
  const _OptionView({
    Key? key,
    required this.option,
    required this.onPressed,
    this.onDonePressed,
    this.isSelected = false,
    this.visible = true,
  }) : super(key: key);

  final _EditingOption option;
  final VoidCallback onPressed;
  final VoidCallback? onDonePressed;
  final bool isSelected;
  final bool visible;

  @override
  _OptionViewState createState() => _OptionViewState();
}

class _OptionViewState extends State<_OptionView> {
  _EditingOption? _currentOption;

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox();

    final option = widget.option;
    final selected = widget.isSelected;
    final background = selected ? Colors.white : Colors.black38;
    final labelColor = selected ? Colors.black : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Done button
        _DoneButton(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          onPressed: () {
            widget.onDonePressed?.call();
            widget.onPressed();
          },
          isVisible: selected,
        ),

        // Main item
        _Button(
          iconData: option.icon,
          label: option.label,
          background: background,
          labelColor: labelColor,
          onPressed: () {
            option.onPressed?.call(context);
            if (!option.disableOnpressed) {
              widget.onPressed();
            }
          },
          child: option.child,
        ),

        // Sub items
        if (option.items.isNotEmpty && selected)
          Column(
            children: List.generate(option.items.length, (index) {
              final subOption = option.items[index];
              return Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: _OptionView(
                  option: subOption,
                  isSelected: _currentOption?.id == subOption.id,
                  visible: _currentOption == null ||
                      _currentOption?.id == subOption.id ||
                      (_currentOption?.items.isEmpty ?? true),
                  onPressed: () {
                    setState(() {
                      _currentOption =
                          _currentOption?.id == subOption.id ? null : subOption;
                    });
                  },
                ),
              );
            }),
          ),

        //
      ],
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({
    Key? key,
    this.isVisible = true,
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
        padding: padding ?? EdgeInsets.zero,
        child: const Text(
          'Done',
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
    this.iconData,
    this.child,
    this.background,
    this.label,
    this.labelColor,
    this.onPressed,
    this.size,
    this.fontSize,
  }) : super(key: key);

  final IconData? iconData;
  final String? label;
  final Widget? child;
  final Color? labelColor;
  final Color? background;
  final void Function()? onPressed;
  final double? size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
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
        height: size ?? 40.0,
        width: size ?? 40.0,
        alignment: Alignment.center,
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
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        border: isSelected ? null : Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'A',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _EditingOption {
  _EditingOption({
    required this.id,
    this.onPressed,
    this.disableOnpressed = false,
    this.icon,
    this.label,
    this.child,
    this.background,
    this.foreground,
    this.items = const [],
  });

  final String id;
  final ValueSetter<BuildContext>? onPressed;
  final bool disableOnpressed;
  final IconData? icon;
  final String? label;
  final Widget? child;
  final Color? background;
  final Color? foreground;
  final List<_EditingOption> items;
}
