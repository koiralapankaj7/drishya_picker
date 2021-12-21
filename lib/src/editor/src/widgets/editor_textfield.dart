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

  @override
  void initState() {
    super.initState();
    _tfSizeKey = GlobalKey();
    _controller = widget.controller..addListener(_listener);
    _textController = _controller.textController;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          widget.controller.updateValue(hasFocus: false, hasStickers: true);
          _controller.currentAsset.value = null;
        }
      })
      ..forward();
    // ignore: prefer_int_literals
    _animation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
        // curve: Curves.easeOutBack,
        // reverseCurve: Curves.easeOut,
      ),
    );
  }

  void _listener() {
    if (!_controller.value.hasFocus && _textController.text.isNotEmpty) {
      _addSticker();
    }
  }

  Alignment _getAlignment({double? value}) {
    final asset = _controller.currentAsset.value;

    if (asset == null) return Alignment.center;
    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final xFactor = asset.position.dx < centerX ? -1 : 1;
    final yFactor = asset.position.dy < centerY ? -1 : 1;
    final x = asset.position.dx / size.width * xFactor;
    final y = asset.position.dy / size.height * yFactor;
    return value == null ? Alignment(x, y) : Alignment(x * value, y * value);
  }

  Offset _getOffset({double? value}) {
    final asset = _controller.currentAsset.value;

    if (asset == null) return Offset.zero;

    final size = MediaQuery.of(context).size;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final xFactor = asset.position.dx < centerX ? -1 : 1;
    final yFactor = asset.position.dy < centerY ? -1 : 1;

    // final dx = asset.position.dx * xFactor;
    // final dy = asset.position.dy * yFactor;
    final dx = (centerX - asset.position.dx - asset.size.width) * xFactor;
    final dy = (centerY - asset.position.dy - asset.size.height) * yFactor;

    log(
      '${asset.position.dx} : ${asset.position.dy} ||| $dx:$dy',
    );

    final toCenter = _animationController.status == AnimationStatus.dismissed;

    return Offset(
      lerpDouble(toCenter ? dx : 0, toCenter ? 0 : dx, value ?? 1.0) ?? 0.0,
      lerpDouble(toCenter ? dy : 0, toCenter ? 0 : dy, value ?? 1.0) ?? 0.0,
    );
  }

  Size? _getSize({double value = 1}) {
    final asset = _controller.currentAsset.value;
    final assetSize = (asset?.sticker as TextSticker?)?.originalSize;

    if (asset != null) {
      final maxHeight = asset.size.height;
      final maxWidth = asset.size.width;
      final clampedWidth = (maxWidth + (maxWidth * value)).clamp(
        assetSize?.width ?? 0.0,
        maxWidth,
      );
      final clampedHeight = (maxHeight + (maxHeight * value)).clamp(
        assetSize?.height ?? 0.0,
        maxHeight,
      );
      return Size(
        lerpDouble(assetSize?.width ?? 0.0, maxWidth, value) ?? 0.0,
        lerpDouble(assetSize?.height ?? 0.0, maxHeight, value) ?? 0.0,
      );
    }
    return null;
  }

  void _addSticker() {
    final box = _tfSizeKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      // final tc = TextEditingController(text: _textController.text);

      // final widgetSticker = WidgetSticker(
      //   size: asset.size.size ?? box.size,
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

      final asset = _controller.currentAsset.value;

      final sticker = TextSticker(
        // size: box.size, // This size will be the smallest one
        // size: asset?.size.size ?? box.size,
        size: box.size,
        originalSize: box.size,
        extra: {'text': _textController.text},
        // onPressed: (asset) {
        // final textSticker = asset.sticker as TextSticker;
        // _textController.text = textSticker.text;
        // },
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
      _controller.currentAsset.value = _controller.stickerController.addSticker(
        sticker,
        size: asset?.size,
        angle: asset?.angle,
        constraint: asset?.constraint,
        position: asset?.position,
        scale: asset?.scale,
      );
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

    return KeyboardVisibility(
      listener: (visible, size) {
        if (visible) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _controller.focusNode.unfocus();
          // if (_animationController.status == AnimationStatus.completed) {
          //   _animationController.reverse();
          // }
        },
        child: Container(
          color: value.hasFocus ? Colors.black54 : Colors.transparent,
          child: ValueListenableBuilder<StickerAsset?>(
            valueListenable: _controller.currentAsset,
            builder: (context, asset, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final size = MediaQuery.of(context).size;
                      final originalSize =
                          (asset?.sticker as TextSticker?)?.originalSize;

                      // final size = constraints.biggest;
                      // final centerX = size.width / 2;
                      final centerY = size.height / 2;

                      final centerTop = (size.height -
                              (originalSize?.height ?? 0) -
                              (centerY * 0.8)) /
                          2;

                      final centerLeft =
                          (size.width - (originalSize?.width ?? 0)) / 2;

                      // final scale = (asset?.size.height ?? 1) /
                      //     (originalSize?.height ?? 1);

                      // final width = lerpDouble(
                      //   originalSize?.width,
                      //   asset?.size.width,
                      //   _animation.value,
                      // );
                      // final height = lerpDouble(
                      //   originalSize?.height,
                      //   asset?.size.height,
                      //   _animation.value,
                      // );

                      final left = lerpDouble(
                        centerLeft,
                        asset?.position.dx,
                        _animation.value,
                      );

                      final top = lerpDouble(
                        centerTop,
                        asset?.position.dy,
                        _animation.value,
                      );

                      final scale =
                          lerpDouble(1, asset?.scale, _animation.value) ?? 1;

                      log('$scale');

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

                      return Positioned(
                        left: left,
                        top: top,
                        child: Transform.rotate(
                          angle: (asset?.angle ?? 0) * _animation.value,
                          child: Transform.scale(
                            scale: scale,
                            origin: Offset(-48, -48),
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: IntrinsicWidth(
                      key: _tfSizeKey,
                      child: StickerTextField(
                        controller: _controller,
                        textController: _textController,
                        focusNode: _controller.focusNode,
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

    // return Container(
    //   color: value.hasFocus ? Colors.black54 : Colors.transparent,
    //   child: GestureDetector(
    //     behavior: HitTestBehavior.opaque,
    //     onTap: () {
    //       _controller.focusNode.unfocus();
    //       if (_animationController.status == AnimationStatus.completed) {
    //         _animationController.reverse();
    //       }
    //     },
    //     child: KeyboardVisibility(
    //       listener: (visible) {
    //         // if (!visible) {
    //         //   _animationController.forward();
    //         // } else {
    //         //   _animationController.reverse();
    //         // }
    //       },
    //       builder: (context, visible, child) {
    //         return child!;
    //       },
    //       child: Container(
    //         margin: const EdgeInsets.symmetric(
    //           horizontal: 60,
    //           vertical: 30,
    //         ),
    //         child: AnimatedBuilder(
    //           animation: _animation,
    //           builder: (context, child) {
    //             final size = _getSize(value: _animation.value);
    //             log('$size : ${_animation.value}');
    //             return Container(
    //               alignment: Alignment.center,
    //               // alignment: _getAlignment(value: _animation.value),
    //               // height: size?.height,
    //               // width: size?.width,
    //               child: Transform.translate(
    //                 offset: _getOffset(value: _animation.value),
    //                 child: Transform.rotate(
    //                   angle: (_editingTextAsset?.angle ?? 0) * _animation.value,
    //                   child: child,
    //                 ),
    //               ),
    //             );
    //           },
    //           child: IntrinsicWidth(
    //             key: _tfSizeKey,
    //             child: _TextField(
    //               controller: _controller,
    //               textController: _textController,
    //               focusNode: _controller.focusNode,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}

///
class StickerTextField extends StatefulWidget {
  const StickerTextField({
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
  _StickerTextFieldState createState() => _StickerTextFieldState();
}

class _StickerTextFieldState extends State<StickerTextField> {
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
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        filled: true,
        fillColor: value.fillTextfield ? value.color : Colors.transparent,
      ),
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


