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
  StickerAsset? _editingTextAsset;
  Size? _originalSize;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tfSizeKey = GlobalKey();
    _controller = widget.controller..addListener(_listener);
    _textController = _controller.textController;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          widget.controller.updateValue(hasFocus: false, hasStickers: true);
        }
      });
    // ignore: prefer_int_literals
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _listener() {
    if (!_controller.value.hasFocus && _textController.text.isNotEmpty) {
      _addSticker();
    }
  }

  Alignment _getAlignment({double? value}) {
    if (_editingTextAsset == null) return Alignment.center;
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final xFactor = _editingTextAsset!.position.dx < centerX ? -1 : 1;
    final yFactor = _editingTextAsset!.position.dy < centerY ? -1 : 1;
    final x = _editingTextAsset!.position.dx / size.width * xFactor;
    final y = _editingTextAsset!.position.dy / size.height * yFactor;
    return value == null ? Alignment(x, y) : Alignment(x * value, y * value);
  }

  Size? _getSize({double value = 1}) {
    if (_editingTextAsset != null) {
      final height = _editingTextAsset!.size.height;
      final width = _editingTextAsset!.size.width;
      final clampedWidth = (width * value).clamp(
        _originalSize?.width ?? 0.0,
        width,
      );
      final clampedHeight = (height * value).clamp(
        _originalSize?.height ?? 0.0,
        height,
      );
      return Size(clampedWidth, clampedHeight);
    }
    return null;
  }

  void _addSticker() {
    final box = _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      // final tc = TextEditingController(text: _textController.text);

      // final widgetSticker = WidgetSticker(
      //   size: _editingTextAsset?.size.size ?? box.size,
      //   extra: {'text': _textController.text},
      //   child: _TextField(
      //     controller: _controller,
      //     textController: tc,
      //     editable: true,
      //     enabled: false,
      //   ),
      //   onPressed: (asset) {
      //     _editingTextAsset = asset;
      //     // _textController.text = tc.text;
      //   },
      // );

      // _textController.clear();
      // _controller.stickerController.addSticker(
      //   widgetSticker,
      //   size: _editingTextAsset?.size,
      //   angle: _editingTextAsset?.angle,
      //   constraint: _editingTextAsset?.constraint,
      //   position: _editingTextAsset?.position,
      // );
      // _editingTextAsset = null;
      // _controller.updateValue(hasStickers: true);

      final sticker = TextSticker(
        // size: box.size, // This size will be the smallest one
        size: _editingTextAsset?.size.size ?? box.size,
        originalSize: box.size,
        extra: {'text': _textController.text},
        onPressed: (asset) {
          _editingTextAsset = asset;
          final textSticker = asset.sticker as TextSticker;
          _textController.text = textSticker.text;
          _originalSize = textSticker.originalSize;
        },
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
            : Colors.white,
        textAlign: _controller.value.textAlign,
        withBackground: _controller.value.fillTextfield,
      );

      _textController.clear();
      _controller.stickerController.addSticker(
        sticker,
        size: _editingTextAsset?.size,
        angle: _editingTextAsset?.angle,
        constraint: _editingTextAsset?.constraint,
        position: _editingTextAsset?.position,
      );
      _editingTextAsset = null;
      // _controller.updateValue(hasStickers: true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;

    if (!value.hasFocus) return const SizedBox();

    return Container(
      color: value.hasFocus ? Colors.black54 : Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _controller.focusNode.unfocus();
        },
        child: KeyboardVisibility(
          listener: (visible) {
            if (visible) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
          },
          builder: (context, visible, child) {
            return child!;
            // return TweenAnimationBuilder<double>(
            //   tween: Tween(begin: 0.0, end: 1.0),
            //   duration: const Duration(milliseconds: 900),
            //   builder: (context, value, child) {
            //     return Container(
            //       alignment: _getAlignment(lerp: value),
            //       child: child,
            //     );
            //   },
            //   child: child,
            // );
            // return AnimatedContainer(
            //   duration: const Duration(milliseconds: 400),
            //   curve: visible ? Curves.easeOutBack : Curves.decelerate,
            //   alignment: visible ? Alignment.center : alignment,
            //   child: Transform(
            //     alignment: Alignment.center,
            //     transform: Matrix4.identity()
            //       // ..translate(1)
            //       ..rotateZ(visible ? 0 : _editingTextAsset?.angle ?? 0),
            //     // ..translate(10),
            //     child: child,
            //   ),
            // );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 60,
              vertical: 30,
            ),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final size = _getSize(value: 1 - _animation.value);
                log('$size : ${_animation.value}');
                return Container(
                  alignment: _getAlignment(value: 1 - _animation.value),
                  height: size?.height,
                  width: size?.width,
                  child: Transform.rotate(
                    angle: (_editingTextAsset?.angle ?? 0) *
                        (1 - _animation.value),
                    child: child,
                  ),
                );
              },
              child: IntrinsicWidth(
                key: _tfSizeKey,
                child: _TextField(
                  controller: _controller,
                  textController: _textController,
                  focusNode: _controller.focusNode,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  const _TextField({
    Key? key,
    required this.controller,
    this.textController,
    this.focusNode,
    this.editable = false,
    this.enabled = true,
  }) : super(key: key);

  final DrishyaEditingController controller;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final bool editable;
  final bool enabled;

  @override
  _TextFieldState createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
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
      enabled: _enabled,
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
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        filled: true,
        fillColor: value.fillTextfield ? value.color : Colors.transparent,
      ),
      onTap: () {
        log('Pressed.....');
        if (widget.editable && !_enabled) {
          setState(() {
            _enabled = true;
          });
        }
      },
    );
  }
}




// 1. Initial state
      // Animate sticker from bottom of the widget to center
// 2. On done animate to center of the screen
// 3. Edit
      // Animate to center 
      // Done => Animate back to its initial position


// Sticker as textfield
// Editing ? enable : disable




// import 'package:drishya_picker/src/editor/editor.dart';
// import 'package:flutter/material.dart';

// StickerAsset? _editingTextAsset;

// ///
// class EditorTextfield extends StatefulWidget {
//   ///
//   const EditorTextfield({
//     Key? key,
//     required this.controller,
//   }) : super(key: key);

//   ///
//   final DrishyaEditingController controller;

//   @override
//   State<EditorTextfield> createState() => _EditorTextfieldState();
// }

// class _EditorTextfieldState extends State<EditorTextfield> {
//   late final GlobalKey _tfSizeKey;
//   late final GlobalKey _widthKey;
//   late final DrishyaEditingController _controller;
//   late final TextEditingController _textController;

//   @override
//   void initState() {
//     super.initState();
//     _tfSizeKey = GlobalKey();
//     _widthKey = GlobalKey();
//     _controller = widget.controller..addListener(_listener);
//     _textController = _controller.textController;
//   }

//   void _listener() {
//     if (!_controller.value.hasFocus && _textController.text.isNotEmpty) {
//       _addSticker();
//     }
//   }

//   void _addSticker() {
//     final box = _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
//     if (box != null) {
//       // _controller.removeListener(_listener);
//       final sticker = TextSticker(
//         // size: box.size, // This size will be the smallest one
//         size: _editingTextAsset?.size.size ?? box.size,
//         extra: {'text': _textController.text},
//         onPressed: (asset) {
//           _editingTextAsset = asset;
//           _textController.text = (asset.sticker as TextSticker).text;
//         },
//         text: _textController.text,
//         style: TextStyle(
//           textBaseline: TextBaseline.ideographic,
//           color: widget.controller.value.textColor,
//           fontSize: 32,
//           fontWeight: FontWeight.w700,
//           decoration: TextDecoration.none,
//           decorationColor: Colors.transparent,
//           decorationThickness: 0,
//         ),
//         background: widget.controller.value.fillTextfield
//             ? widget.controller.value.color
//             : Colors.white,
//         textAlign: _controller.value.textAlign,
//         withBackground: _controller.value.fillTextfield,
//       );

//       _textController.clear();
//       _controller.stickerController.addSticker(
//         sticker,
//         size: _editingTextAsset?.size,
//         angle: _editingTextAsset?.angle,
//         constraint: _editingTextAsset?.constraint,
//         position: _editingTextAsset?.position,
//       );
//       _editingTextAsset = null;
//       _controller.updateValue(hasStickers: true);

//       // Future.delayed(const Duration(milliseconds: 20), () {
//       //   _controller.stickerController.addSticker(sticker);
//       //   _controller.addListener(_listener);
//       // });
//     }
//   }

//   @override
//   void dispose() {
//     _controller.removeListener(_listener);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final value = widget.controller.value;

//     if (!value.hasFocus) return const SizedBox();

//     return Scaffold(
//       backgroundColor: value.hasFocus ? Colors.black54 : Colors.transparent,
//       body: GestureDetector(
//         behavior: HitTestBehavior.opaque,
//         onTap: () {
//           widget.controller.updateValue(hasFocus: false);
//         },
//         child: Center(
//           child: IntrinsicWidth(
//             key: _widthKey,
//             stepWidth: 20,
//             child: Container(
//               constraints: const BoxConstraints(minWidth: 20),
//               margin: const EdgeInsets.symmetric(
//                 horizontal: 60,
//                 vertical: 30,
//               ),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: value.fillTextfield ? value.color : Colors.transparent,
//               ),
//               child: TextFormField(
//                 key: _tfSizeKey,
//                 controller: _textController,
//                 focusNode: _controller.focusNode,
//                 autofocus: true,
//                 textAlign: value.textAlign,
//                 autocorrect: false,
//                 minLines: 1,
//                 maxLines: null,
//                 keyboardType: TextInputType.multiline,
//                 textInputAction: TextInputAction.newline,
//                 smartDashesType: SmartDashesType.disabled,
//                 style: TextStyle(
//                   textBaseline: TextBaseline.ideographic,
//                   color: widget.controller.value.textColor,
//                   fontSize: 32,
//                   fontWeight: FontWeight.w700,
//                   decoration: TextDecoration.none,
//                   decorationColor: Colors.transparent,
//                   decorationThickness: 0,
//                 ),
//                 decoration: const InputDecoration(
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.all(8),
//                   // filled: value.fillColor,
//                   // fillColor: value.textBackground.colors.first,
//                   // focusedBorder: OutlineInputBorder(
//                   //   borderRadius: BorderRadius.circular(10.0),
//                   //   borderSide: BorderSide.none,
//                   // ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// // 1. Initial state
//       // Animate sticker from bottom of the widget to center
// // 2. On done animate to center of the screen
// // 3. Edit
//       // Animate to center 
//       // Done => Animate back to its initial position


// // Sticker as textfield
// // Editing ? enable : disable


