import 'dart:developer';
import 'dart:ui';

import 'package:drishya_picker/src/editor/editor.dart';
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

  var _tfSize = const Size(20, 40);

  @override
  void initState() {
    super.initState();
    _tfSizeKey = GlobalKey();
    _controller = widget.controller;
    _textController = _controller.textController;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          _finishTask();
        }
      })
      ..forward();
    // ignore: prefer_int_literals
    _animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        // curve: Curves.linear,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );
  }

  void _finishTask() {
    _controller.updateValue(
      hasFocus: false,
      hasStickers: _controller.stickerController.value.assets.isNotEmpty,
    );
    _textController.clear();
    _controller.currentAsset.value = null;
    _tfSize = const Size(20, 40);
  }

  void _addSticker() {
    if (_controller.textController.text.isEmpty) return;

    final box = _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final asset = _controller.currentAsset.value;

      final sticker = TextSticker(
        size: box.size,
        originalSize: box.size,
        extra: {'text': _textController.text},
        text: _textController.text,
        style: TextStyle(
          textBaseline: TextBaseline.ideographic,
          color: widget.controller.value.textColor,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
          decorationThickness: 0,
        ),
        background: widget.controller.value.fillTextfield
            ? widget.controller.value.color
            : Colors.transparent,
        textAlign: _controller.value.textAlign,
        withBackground: _controller.value.fillTextfield,
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;

    if (!value.hasFocus) {
      return Center(
        child: GestureDetector(
          onTap: () {
            _controller.updateValue(hasFocus: true);
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

    return KeyboardVisibility(
      listener: (visible) {
        // TODO: Remove this
        log('Keyboard visible > $visible');
        _controller.updateValue(
          keyboardVisible: visible,
          isColorPickerOpen: visible,
        );
        if (visible) {
          _animationController.forward();
        } else {
          if (_textController.text.isNotEmpty) {
            _addSticker();
          }
          _animationController.reverse();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _controller.focusNode.unfocus,
        child: ColoredBox(
          color: value.keyboardVisible ? Colors.black54 : Colors.transparent,
          child: ValueListenableBuilder<StickerAsset?>(
            valueListenable: _controller.currentAsset,
            builder: (context, asset, child) {
              final size = MediaQuery.of(context).size;
              final originalSize =
                  (asset?.sticker as TextSticker?)?.originalSize;

              final centerX = size.width / 2;
              final centerY = size.height / 2;

              final centerTop = (size.height -
                      (originalSize?.height ?? _tfSize.height) -
                      (centerY * 0.92)) /
                  2;

              final centerLeft =
                  (size.width - (originalSize?.width ?? _tfSize.width)) / 2;

              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      if (_animationController.status ==
                          AnimationStatus.completed) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 30,
                          ),
                          child: child,
                        );
                      }

                      final animValue = _animation.value;

                      final left = lerpDouble(
                        centerLeft,
                        asset?.position.dx ?? centerX - (_tfSize.width / 2),
                        animValue,
                      );

                      final top = lerpDouble(
                        centerTop,
                        asset?.position.dy ?? centerY - (_tfSize.height / 2),
                        animValue,
                      );

                      final scale = asset == null
                          ? 1.0
                          : lerpDouble(1, asset.scale, animValue) ?? 1.0;

                      final angle =
                          asset == null ? 0.0 : asset.angle * animValue;

                      return Positioned(
                        left: left,
                        top: top,
                        child: Transform.rotate(
                          angle: angle,
                          child: Transform.scale(
                            scale: scale,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: IntrinsicWidth(
                      key: _tfSizeKey,
                      child: _StickerTextField(
                        controller: _controller,
                        textController: _textController,
                        focusNode: _controller.focusNode,
                        onChanged: (t) {
                          final box = _tfSizeKey.currentContext
                              ?.findRenderObject() as RenderBox?;
                          if (box != null) {
                            setState(() {
                              _tfSize = box.size;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
  }) : super(key: key);

  final DrishyaEditingController controller;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final bool editable;
  final bool enabled;
  final ValueSetter<String>? onChanged;

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
      textInputAction: TextInputAction.newline,
      smartDashesType: SmartDashesType.disabled,
      style: TextStyle(
        textBaseline: TextBaseline.ideographic,
        color: widget.controller.value.textColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0,
        decorationStyle: TextDecorationStyle.dashed,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        filled: true,
        fillColor: value.fillTextfield ? value.color : Colors.transparent,
      ),
      cursorColor: value.fillTextfield ? value.textColor : value.color,
      onChanged: widget.onChanged,
    );
  }
}
