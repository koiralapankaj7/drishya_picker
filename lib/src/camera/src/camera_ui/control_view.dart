import 'package:drishya_picker/src/camera/src/camera_ui/builders/action_detector.dart';
import 'package:drishya_picker/src/camera/src/entities/camera_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'builders/camera_action_provider.dart';
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
      context.action?.changeCameraTypeSliderVisibility(!_focusNode.hasFocus);
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
          child: const cb.CloseButton(),
        ),

        // Flash Light
        Positioned(
          right: 8.0,
          top: top,
          child: const FlashButton(),
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
          child: ActionBuilder(
            builder: (action, value, child) {
              if (!value.enableCameraTypeSlider) {
                return const SizedBox();
              }
              return Container(
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
              );
            },
          ),
        ),

        // Textfield
        _TextEditor(
          focusNotifier: _focusNotifier,
          focusNode: _focusNode,
        ),

        // Background changer
        const Positioned(
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

        //
      ],
    );
  }
}

class _BackgroundChanged extends StatelessWidget {
  const _BackgroundChanged({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (value.cameraType != CameraType.text) {
          return const SizedBox();
        }

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
      },
    );
  }
}

class _TextEditor extends StatelessWidget {
  const _TextEditor({
    Key? key,
    required this.focusNode,
    required this.focusNotifier,
  }) : super(key: key);

  final FocusNode focusNode;
  final ValueNotifier<bool> focusNotifier;

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (value.cameraType != CameraType.text) {
          return const SizedBox();
        }

        return ValueListenableBuilder<bool>(
          valueListenable: focusNotifier,
          builder: (context, hasFocus, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              color: hasFocus ? Colors.black38 : Colors.transparent,
              child: ColoredBox(
                color: Colors.transparent,
                child: TextField(
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
                ),
              ),
            );
          },
        );
      },
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
    return ActionBuilder(
      builder: (action, value, child) {
        if (value.cameraType != CameraType.text) {
          return const SizedBox();
        }
        return ValueListenableBuilder<bool>(
          valueListenable: focusNotifier,
          builder: (context, hasFocus, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _DoneButton(
                  onPressed: focusNode.unfocus,
                  isVisible: hasFocus,
                ),
                _StickerIconButton(
                  label: 'Aa',
                  sizeFactor: hasFocus ? 1.1 : 1.0,
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
                _StickerIconButton(
                  isVisible: hasFocus,
                  iconData: Icons.format_align_center,
                ),
                _StickerIconButton(
                  iconData: Icons.border_outer_outlined,
                  isVisible: hasFocus,
                ),
                _StickerIconButton(
                  isVisible: !hasFocus,
                  iconData: Icons.emoji_emotions,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StickerIconButton extends StatelessWidget {
  const _StickerIconButton({
    Key? key,
    this.sizeFactor = 1.0,
    this.isVisible = true,
    this.iconData,
    this.background,
    this.margin = 8.0,
    this.label,
    this.labelColor,
    this.onPressed,
  }) : super(key: key);

  final double sizeFactor;
  final bool isVisible;
  final IconData? iconData;
  final String? label;
  final Color? labelColor;
  final Color? background;
  final double margin;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox();

    final isText = label?.isNotEmpty ?? false;
    final isIcon = iconData != null;

    final text = Text(
      label ?? 'Aa',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 17.0 * sizeFactor,
        color: labelColor ?? Colors.white,
      ),
    );

    final icon = Icon(
      iconData ?? Icons.emoji_emotions,
      color: Colors.white,
      size: 22.0 * sizeFactor,
    );

    return InkWell(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 40.0 * sizeFactor,
        width: 40.0 * sizeFactor,
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: margin),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background ?? Colors.black38,
        ),
        child: isText
            ? text
            : isIcon
                ? icon
                : const SizedBox(),
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
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
