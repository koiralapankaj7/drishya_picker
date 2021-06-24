import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'widgets/camera_type_changer.dart';
import 'widgets/close_button.dart' as cb;
import 'widgets/flash_button.dart';
import 'widgets/gallery_button.dart';
import 'widgets/rotate_button.dart';
import 'widgets/shutter_view.dart';

///
class ControlView extends StatefulWidget {
  ///
  const ControlView({
    Key? key,
    required this.videoDuration,
  }) : super(key: key);

  ///
  final Duration videoDuration;

  @override
  _ControlViewState createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  late final FocusNode _focusNode;
  late final ValueNotifier<bool> _focusNotifier;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNotifier = ValueNotifier(false);
    _focusNode.addListener(() {
      _focusNotifier.value = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNotifier.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 4.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Close button
        Positioned(
          left: 8.0,
          top: top,
          child: cb.CloseButton(),
        ),

        // Flash Light
        Positioned(
          right: 8.0,
          top: top,
          child: FlashButton(),
        ),

        // Capture button
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 64.0,
          child: ShutterView(videoDuration: widget.videoDuration),
        ),

        // preview, input type page view and camera
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            height: 60.0,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Row(
              children: const [
                // Gallery preview
                GalleryButton(),

                // Margin
                SizedBox(width: 8.0),

                // Camera type scroller
                Expanded(child: CameraTypeChanger()),

                // Switch camera
                RotateButton(),

                //
              ],
            ),
          ),
        ),

        // Background changer
        Positioned(
          left: 16.0,
          bottom: 16.0,
          child: _BackgroundChanged(),
        ),

        // Sticker buttons
        Positioned(
          right: 16.0,
          top: top,
          child: _StickerButtons(
            focusNode: _focusNode,
            focusNotifier: _focusNotifier,
          ),
        ),

        // Textfield
        Align(
          alignment: Alignment.center,
          child: _TextEditor(
            focusNode: _focusNode,
          ),
        ),

        //
      ],
    );
  }
}

class _BackgroundChanged extends StatelessWidget {
  const _BackgroundChanged({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(
        side: BorderSide(
          color: Colors.white,
          width: 2.0,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Container(
        width: 54.0,
        height: 54.0,
        decoration: BoxDecoration(
          color: Colors.red,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlue.shade300,
              Colors.blue,
            ],
          ),
        ),
      ),
    );
  }
}

class _TextEditor extends StatelessWidget {
  const _TextEditor({
    Key? key,
    required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      textAlign: TextAlign.center,
      autocorrect: false,
      minLines: null,
      smartDashesType: SmartDashesType.disabled,
      style: const TextStyle(
        textBaseline: TextBaseline.ideographic,
        color: Colors.white,
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0.0,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Tap to type...',
        hintStyle: TextStyle(
          color: Colors.white70,
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StickerButtons extends StatelessWidget {
  const _StickerButtons({
    Key? key,
    required this.focusNotifier,
    required this.focusNode,
  }) : super(key: key);

  final ValueNotifier<bool> focusNotifier;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: focusNotifier,
      builder: (context, hasFocus, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasFocus) _DoneButton(focusNode: focusNode),
            if (hasFocus) const SizedBox(height: 12.0),
            _StickerTextButton(
              background: hasFocus ? Colors.white : Colors.black,
              labelColor: hasFocus ? Colors.black : Colors.white,
              onPressed: () {
                if (focusNode.hasFocus) {
                  focusNode.unfocus();
                } else {
                  focusNode.requestFocus();
                }
              },
            ),
            const SizedBox(height: 8.0),
            if (hasFocus)
              _StickerIconButton(iconData: Icons.format_align_center),
            if (hasFocus) const SizedBox(height: 8.0),
            if (hasFocus)
              _StickerIconButton(iconData: Icons.border_outer_outlined),
            if (hasFocus) const SizedBox(height: 8.0),
            if (!hasFocus) _StickerIconButton(),
          ],
        );
      },
    );
  }
}

class _StickerIconButton extends StatelessWidget {
  const _StickerIconButton({
    Key? key,
    this.iconData,
    this.background,
  }) : super(key: key);

  final IconData? iconData;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20.0,
      backgroundColor: background ?? Colors.black38,
      child: Icon(
        iconData ?? Icons.emoji_emotions,
        size: 22.0,
      ),
    );
  }
}

class _StickerTextButton extends StatelessWidget {
  const _StickerTextButton({
    Key? key,
    this.background,
    this.label,
    this.labelColor,
    this.onPressed,
  }) : super(key: key);

  final String? label;
  final Color? labelColor;
  final Color? background;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 20.0,
        backgroundColor: background ?? Colors.black38,
        child: Text(
          label ?? 'Aa',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17.0,
            color: labelColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({
    Key? key,
    required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: focusNode.unfocus,
      child: Text(
        'DONE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
