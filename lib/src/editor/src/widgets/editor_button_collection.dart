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

  void _onTextAlignButtonPressed(BuildContext context) {
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

  void _onTextColorChangerPressed(BuildContext context) {
    controller.updateValue(
      fillTextfield: !controller.value.fillTextfield,
      isColorPickerOpen: !controller.value.fillTextfield &&
          controller.value.background is PhotoBackground,
    );
  }

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
          final background = controller.value.background is GradientBackground
              ? (controller.value.background as GradientBackground).lastColor
              : Colors.black54;

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
            onBackground: controller.value.generateForegroundColor(background),
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
          final value = !controller.value.hasFocus;
          controller.updateValue(
            hasFocus: value,
            isColorPickerOpen: value,
            keyboardVisible: value,
          );
        },
        items: [
          _EditingOption(
            id: 'text-align-setting',
            onPressed: _onTextAlignButtonPressed,
            disableOnpressed: true,
            child: _TextAlignmentIcon(align: controller.value.textAlign),
          ),
          _EditingOption(
            id: 'text-color-setting',
            onPressed: _onTextColorChangerPressed,
            disableOnpressed: true,
            child: _TextBackgroundIcon(
              isSelected: controller.value.fillTextfield,
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
          secondChild: _ButtonList(
            controller: controller,
            onStickerIconPressed: _onStickerIconPressed,
            options: _options,
          ),
          crossFadeState: crossFadeState,
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 200),
        );
      },
    );
  }
}

class _ButtonList extends StatefulWidget {
  const _ButtonList({
    Key? key,
    required this.options,
    required this.controller,
    required this.onStickerIconPressed,
  }) : super(key: key);

  ///
  final List<_EditingOption> options;

  ///
  final DrishyaEditingController controller;

  ///
  final ValueSetter<BuildContext> onStickerIconPressed;

  @override
  State<_ButtonList> createState() => _ButtonListState();
}

class _ButtonListState extends State<_ButtonList> {
  void _textAlignButtonPressed() {
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

  _EditingOption? _currentOption;

  @override
  Widget build(BuildContext context) {
    final hasFocus = widget.controller.value.hasFocus;

    return Container(
      color: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _DoneButton(
            onPressed: () {
              widget.controller.updateValue(
                hasFocus: false,
                isColorPickerOpen: false,
                keyboardVisible: false,
              );
            },
            isVisible: hasFocus,
          ),

          ...widget.options
              .map(
                (option) => _OptionView(
                  option: option,
                  isSelected: _currentOption?.id == option.id,
                  visible: _currentOption == null ||
                      _currentOption?.id == option.id ||
                      (_currentOption?.items.isEmpty ?? true),
                  onPressed: () {
                    setState(() {
                      _currentOption =
                          _currentOption?.id == option.id ? null : option;
                    });
                  },
                ),
              )
              .toList(),

          // _Button(
          //   label: 'Aa',
          //   size: hasFocus ? 48.0 : 44.0,
          //   fontSize: hasFocus ? 24.0 : 20.0,
          //   background: hasFocus ? Colors.white : Colors.black38,
          //   labelColor: hasFocus ? Colors.black : Colors.white,
          //   onPressed: () {
          //     controller.updateValue(
          //       hasFocus: !hasFocus,
          //       isColorPickerOpen: !hasFocus,
          //       keyboardVisible: !hasFocus,
          //     );
          //   },
          // ),
          // _Button(
          //   isVisible: hasFocus,
          //   onPressed: _textAlignButtonPressed,
          //   child: _TextAlignmentIcon(align: controller.value.textAlign),
          // ),
          // _Button(
          //   isVisible: hasFocus,
          //   onPressed: () {
          //     controller.updateValue(
          //       fillTextfield: !controller.value.fillTextfield,
          //       isColorPickerOpen: !controller.value.fillTextfield &&
          //           controller.value.background is PhotoBackground,
          //     );
          //   },
          //   child: _TextBackgroundIcon(
          //     isSelected: controller.value.fillTextfield,
          //   ),
          // ),
          // _Button(
          //   isVisible: !hasFocus,
          //   iconData: Icons.emoji_emotions,
          //   onPressed: () => onStickerIconPressed(context),
          // ),
        ],
      ),
    );
  }
}

class _OptionView extends StatefulWidget {
  const _OptionView({
    Key? key,
    required this.option,
    required this.onPressed,
    this.isSelected = false,
    this.visible = true,
  }) : super(key: key);

  final _EditingOption option;
  final VoidCallback onPressed;
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
        // Main button
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

        if (option.items.isNotEmpty && selected)
          // Child items
          Container(
            margin: const EdgeInsets.only(right: 16),
            color: Colors.cyan,
            child: Column(
              children: option.items
                  .map(
                    (e) => _OptionView(
                      option: e,
                      isSelected: _currentOption?.id == e.id,
                      visible: _currentOption == null ||
                          _currentOption?.id == e.id ||
                          (_currentOption?.items.isEmpty ?? true),
                      onPressed: () {
                        setState(() {
                          _currentOption =
                              _currentOption?.id == e.id ? null : e;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ),

        //
      ],
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
        // duration: const Duration(milliseconds: 100),
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
