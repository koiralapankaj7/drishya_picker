import 'package:drishya_picker/src/camera/src/camera_ui/builders/action_detector.dart';
import 'package:drishya_picker/src/camera/src/camera_ui/widgets/gradient_background.dart';
import 'package:drishya_picker/src/camera/src/entities/camera_type.dart';
import 'package:drishya_picker/src/camera/src/utils/custom_icons.dart';
import 'package:drishya_picker/src/draggable_resizable/src/entities/sticker_asset.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'builders/camera_action_provider.dart';
import 'sticker/sticker_picker.dart';
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

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      context.action?.updateValue(hasFocus: _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextSubmit(String value) {}

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 4.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Textfield open button
        const Align(
          alignment: Alignment.center,
          child: _TextInputModeTextButton(),
        ),

        // _TextEditor(
        //   focusNode: _focusNode,
        //   onSubmitted: _onTextSubmit,
        // ),

        // preview, input type page view and camera
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: ActionBuilder(
            builder: (action, value, child) {
              if (action.hideCameraTypeScroller) {
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

        // Shutter view
        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 64.0,
          child: ShutterView(videoDuration: widget.videoDuration),
        ),

        // Background changer
        const Positioned(
          left: 16.0,
          bottom: 16.0,
          child: GradientBackgroundChanger(),
        ),

        // Screenshot capture button
        const Positioned(
          right: 16.0,
          bottom: 16.0,
          child: _ScreenshotCaptureButton(),
        ),

        // Sticker buttons
        Positioned(
          right: 16.0,
          top: top,
          child: _StickerButtons(focusNode: _focusNode),
        ),

        //
      ],
    );
  }
}

class _TextInputModeTextButton extends StatelessWidget {
  const _TextInputModeTextButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (action.hideEditingTextButton) {
          return const SizedBox();
        }

        return GestureDetector(
          onTap: () {},
          child: const Text(
            'Tap to type...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 28.0,
              fontWeight: FontWeight.w600,
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
    this.onSubmitted,
  }) : super(key: key);

  final FocusNode focusNode;
  final void Function(String value)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (value.cameraType != CameraType.text) {
          return const SizedBox();
        }

        return GestureDetector(
          onTap: focusNode.unfocus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            color: value.hasFocus ? Colors.black38 : Colors.transparent,
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
                onSubmitted: onSubmitted,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StickerButtons extends StatelessWidget {
  _StickerButtons({
    Key? key,
    required this.focusNode,
  }) : super(key: key);

  final FocusNode focusNode;

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (action.hideStickerEditingButton) {
          return const SizedBox();
        }

        final hasFocus = value.hasFocus;
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
              size: hasFocus ? 48.0 : 44.0,
              fontSize: hasFocus ? 24.0 : 20.0,
              background: hasFocus ? Colors.white : Colors.black38,
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
              onPressed: () {
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
                      action.stickerController.addSticker(sticker);
                      action.updateValue(hasStickers: true);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _StickerIconButton extends StatelessWidget {
  const _StickerIconButton({
    Key? key,
    this.isVisible = true,
    this.iconData,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: size ?? 44.0,
        width: size ?? 44.0,
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
            fontSize: 17.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ScreenshotCaptureButton extends StatelessWidget {
  const _ScreenshotCaptureButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        if (action.hideScreenshotCaptureView) {
          return const SizedBox();
        }

        return GestureDetector(
          onTap: action.captureScreenshot,
          child: Container(
            width: 56.0,
            height: 56.0,
            padding: const EdgeInsets.only(left: 4.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              CustomIcons.send,
              color: Colors.blue,
            ),
          ),
        );
      },
    );
  }
}
