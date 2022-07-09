// ignore_for_file: unused_element

import 'dart:ui';

import 'package:drishya_picker/src/editor/editor.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
import 'package:drishya_picker/src/widgets/keyboard_visibility.dart';
import 'package:flutter/material.dart';

///
class EditorTextfield extends StatefulWidget {
  ///
  const EditorTextfield({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  @override
  State<EditorTextfield> createState() => _EditorTextfieldState();
}

class _EditorTextfieldState extends State<EditorTextfield>
    with SingleTickerProviderStateMixin {
  late final GlobalKey _tfSizeKey;
  late final DrishyaEditingController _controller;
  late final TextEditingController _textController;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  var _tfSize = const Size(24, 48);

  @override
  void initState() {
    super.initState();
    _tfSizeKey = GlobalKey();
    _controller = widget.controller;
    _textController = _controller.textController;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _finishTask();
        } else if (status == AnimationStatus.completed) {
          _controller.updateValue(isColorPickerOpen: true);
        }
      });
    // ignore: prefer_int_literals
    _animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _finishTask() {
    if (_textController.text.isNotEmpty) {
      _addSticker();
    }
    _textController.clear();
    _tfSize = const Size(20, 40);
    _controller.currentAsset.value = null;
    _controller.currentAssetState.value = null;
    _controller.updateValue(
      hasFocus: false,
      hasStickers: _controller.stickerController.value.assets.isNotEmpty,
    );
  }

  // TODO(koiralapankaj007): responsive textfield for long text
  void _addSticker() {
    if (_controller.textController.text.isEmpty) return;

    final asset = _controller.currentAsset.value;

    final sticker = TextSticker(
      size: _tfSize,
      // extra: {'text': _textController.text},
      text: _textController.text,
      style: TextStyle(
        textBaseline: TextBaseline.ideographic,
        color: _controller.textColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0,
      ),
      background: _controller.value.fillTextfield
          ? _controller.currentColor
          : Colors.transparent,
      textAlign: _controller.value.textAlign,
    );

    _controller.stickerController.addSticker(
      sticker,
      size: asset?.size,
      angle: asset?.angle,
      constraint: asset?.constraint,
      position: asset?.position,
      scale: asset?.scale,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditorBuilder(
      controller: _controller,
      builder: (context, value, child) {
        if (!value.hasFocus) return const SizedBox();

        return KeyboardVisibility(
          listener: (visible) {
            if (visible) {
              _animationController.forward();
            } else {
              final box =
                  _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                _tfSize = box.size;
              }
              _animationController.reverse();
            }
            _controller.updateValue(
              keyboardVisible: visible,
              isColorPickerOpen: false,
            );
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _controller.focusNode.unfocus,
            child: ColoredBox(
              color: _controller.value.keyboardVisible
                  ? Colors.black38
                  : Colors.transparent,
              child: ValueListenableBuilder<StickerAsset?>(
                valueListenable: _controller.currentAsset,
                builder: (context, asset, child) {
                  final deviceSize = MediaQuery.of(context).size;

                  // Center X position of the screen
                  final centerX = deviceSize.width / 2;

                  // Center Y position of the screen
                  final centerY = deviceSize.height / 2;

                  // Smallest width of the editing sticker or new text field
                  final smallestWidth = asset != null
                      ? asset.size.width / asset.scale
                      : _tfSize.width;

                  // Smallest height of the editing sticker or new text field
                  final smallestHeight = asset != null
                      ? asset.size.height / asset.scale
                      : _tfSize.height;

                  // Center position from the top excluding keyboard
                  // height (Assuming keyboard as 50% of device height)
                  final centerTop =
                      ((deviceSize.height * 0.5) - smallestHeight) / 2;

                  // Center position from the left
                  final centerLeft = (deviceSize.width - smallestWidth) / 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final animValue = _animation.value;

                          final left = lerpDouble(
                            centerLeft,
                            asset?.position.dx ?? centerX - (_tfSize.width / 2),
                            animValue,
                          );

                          final top = lerpDouble(
                            centerTop,
                            asset?.position.dy ??
                                centerY - (_tfSize.height / 2),
                            animValue,
                          );

                          final scale = asset == null
                              ? 1.0
                              : lerpDouble(1, asset.scale, animValue) ?? 1.0;

                          final angle =
                              asset == null ? 0.0 : asset.angle * animValue;

                          final textField = IntrinsicWidth(
                            key: _tfSizeKey,
                            child: _StickerTextField(
                              controller: _controller,
                              textController: _textController,
                              focusNode: _controller.focusNode,
                              scale: scale,
                            ),
                          );

                          if (_animationController.status ==
                              AnimationStatus.completed) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 30,
                              ),
                              child: textField,
                            );
                          }

                          return Positioned(
                            left: left,
                            top: top,
                            child: Transform.rotate(
                              angle: angle,
                              child: textField,
                            ),
                          );

                          //
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

///
class _StickerTextField extends StatefulWidget {
  ///
  const _StickerTextField({
    Key? key,
    required this.controller,
    this.textController,
    this.focusNode,
    this.editable = false,
    this.enabled = true,
    this.onChanged,
    this.scale,
  }) : super(key: key);

  final DrishyaEditingController controller;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final bool editable;
  final bool enabled;
  final ValueSetter<String>? onChanged;
  final double? scale;

  @override
  _StickerTextFieldState createState() => _StickerTextFieldState();
}

class _StickerTextFieldState extends State<_StickerTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (widget.editable) {
      widget.textController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    return ValueListenableBuilder<Color>(
      valueListenable: widget.controller.colorNotifier,
      builder: (context, color, child) {
        return TextField(
          enabled: widget.enabled,
          controller: widget.textController,
          focusNode: widget.focusNode,
          autofocus: true,
          textAlign: value.textAlign,
          autocorrect: false,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          // textInputAction: TextInputAction.newline,
          smartDashesType: SmartDashesType.disabled,
          style: TextStyle(
            textBaseline: TextBaseline.ideographic,
            color: widget.controller.textColor,
            fontSize: 28 * (widget.scale ?? 1.0),
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
            decorationColor: Colors.transparent,
            decorationThickness: 0,
            decorationStyle: TextDecorationStyle.dashed,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(8),
            filled: true,
            fillColor: value.fillTextfield ? color : Colors.transparent,
          ),
          cursorColor:
              value.fillTextfield ? widget.controller.textColor : color,
          onChanged: widget.onChanged,
        );
      },
    );
  }
}
