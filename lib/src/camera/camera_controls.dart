// part of 'camera_view.dart';

import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:drishya_picker/src/entities/custom_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CameraAction extends StatefulWidget {
  const CameraAction({
    Key? key,
    required this.controller,
    this.onFalshIconPressed,
    this.onCameraRotatePressed,
    this.onCaptureImagePressed,
    this.onPreviewMediaPressed,
    this.onInputTypeChanged,
    this.onPopRequest,
    this.inputTypeController,
  }) : super(key: key);

  final CameraController controller;
  final void Function(FlashMode mode)? onFalshIconPressed;
  final void Function(CameraLensDirection direction)? onCameraRotatePressed;
  final void Function()? onCaptureImagePressed;
  final void Function()? onPreviewMediaPressed;
  final void Function(_InputItem type)? onInputTypeChanged;
  final void Function()? onPopRequest;
  final InputTypeController? inputTypeController;

  @override
  _CameraActionState createState() => _CameraActionState();
}

class _CameraActionState extends State<CameraAction> {
  late final InputTypeController inputTypeController;

  @override
  void initState() {
    super.initState();
    inputTypeController = widget.inputTypeController ?? InputTypeController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),

        // Close and flash
        Row(
          children: [
            IconButton(
              icon: const Icon(
                CustomIcons.close,
                color: Colors.white,
                size: 16.0,
              ),
              onPressed: Navigator.of(context).pop,
            ),
            const Expanded(child: SizedBox()),

            // Flash button
            InputTypeBuilder(
              controller: inputTypeController,
              builder: (context, type, child) {
                if (type == InputType.text || type == InputType.selfi) {
                  return const SizedBox();
                }
                return child!;
              },
              child: IconButton(
                icon: Icon(
                  widget.controller.value.flashMode == FlashMode.off
                      ? CustomIcons.flashoff
                      : CustomIcons.flashon,
                  color: Colors.white,
                ),
                onPressed: () {
                  widget.onFalshIconPressed?.call(
                    widget.controller.value.flashMode == FlashMode.off
                        ? FlashMode.always
                        : FlashMode.off,
                  );
                },
              ),
            ),

            //
          ],
        ),

        // Expanded
        const Expanded(child: SizedBox()),

        // Filters and capture
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InputTypeBuilder(
              controller: inputTypeController,
              builder: (context, type, child) {
                return GestureDetector(
                  onTap: widget.onCaptureImagePressed,
                  child: Container(
                    height: 60.0,
                    width: 60.0,
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.0),
                      border: Border.all(
                        color: Colors.white,
                        width: 3.0,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white60,
                      child: Builder(builder: (context) {
                        switch (type) {
                          case InputType.selfi:
                            return Icon(CupertinoIcons.person_fill);
                          case InputType.video:
                            return Icon(Icons.circle);
                          default:
                            return const SizedBox();
                        }
                      }),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 4.0),

        // preview, input type page view and camera
        Container(
          height: 60.0,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Gallery
              Container(
                padding: const EdgeInsets.all(4.0),
                width: 54.0,
                height: 54.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: InputTypeBuilder(
                    controller: inputTypeController,
                    builder: (context, type, child) {
                      if (type == InputType.text) return const SizedBox();
                      return child!;
                    },
                    child: Container(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(width: 8.0),

              // Expanded
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Text scroller
                    Expanded(
                      child: _ItemsPageView(
                        inputTypeController: inputTypeController,
                        onInputTypeChanged: (type) {
                          if (type == InputType.selfi &&
                              widget.controller.description.lensDirection !=
                                  CameraLensDirection.front) {
                            widget.onCameraRotatePressed
                                ?.call(CameraLensDirection.front);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    //
                    Container(
                      height: 12.0,
                      width: 20.0,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Transform.rotate(
                          angle: -pi / 2,
                          child: Icon(CustomIcons.play, color: Colors.white),
                        ),
                      ),
                    ),

                    //
                  ],
                ),
              ),

              // Switch camera
              Container(
                padding: const EdgeInsets.only(top: 10.0),
                width: 54.0,
                alignment: Alignment.center,
                child: InputTypeBuilder(
                  controller: inputTypeController,
                  builder: (context, type, child) {
                    if (type == InputType.text) return const SizedBox();
                    return child!;
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (widget.controller.value.isRecordingVideo) return;
                      final direction =
                          widget.controller.description.lensDirection ==
                                  CameraLensDirection.back
                              ? CameraLensDirection.front
                              : CameraLensDirection.back;
                      widget.onCameraRotatePressed?.call(direction);
                    },
                    child: const Icon(
                      CustomIcons.cameraRotate,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              //
            ],
          ),
        ),

        //
      ],
    );
  }
}

class _ItemsPageView extends StatefulWidget {
  const _ItemsPageView({
    Key? key,
    required this.inputTypeController,
    this.onInputTypeChanged,
  }) : super(key: key);

  final InputTypeController inputTypeController;
  final void Function(InputType type)? onInputTypeChanged;

  @override
  __ItemsPageViewState createState() => __ItemsPageViewState();
}

class __ItemsPageViewState extends State<_ItemsPageView> {
  late final PageController pageController;
  double pageValue = 0.0;

  @override
  void initState() {
    super.initState();
    pageValue = widget.inputTypeController.value.index.toDouble();
    pageController = PageController(
      initialPage: widget.inputTypeController.value.index,
      viewportFraction: 0.25,
    )..addListener(() {
        setState(() {
          pageValue = pageController.page ?? 0.0;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: InputType.values.length,
      controller: pageController,
      onPageChanged: (index) {
        final type = InputType.values[index];
        widget.onInputTypeChanged?.call(type);
        widget.inputTypeController.value = type;
      },
      itemBuilder: (context, position) {
        final type = InputType.values[position];
        double activePercent = 0.0;
        if (position == pageValue.floor()) {
          activePercent = 1 - (pageValue - position).clamp(0.0, 1.0);
        } else if (position == pageValue.floor() + 1) {
          activePercent = 1 - (position - pageValue).clamp(0.0, 1.0);
        } else {
          activePercent = 0.0;
        }

        return _InputItem(
          type: type,
          activePercent: activePercent,
          onPressed: () {
            pageController.animateToPage(
              type.index,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn,
            );
          },
        );
      },
    );
  }
}

class _InputItem extends StatelessWidget {
  ///
  const _InputItem({
    Key? key,
    required this.type,
    required this.activePercent,
    this.onPressed,
  }) : super(key: key);

  ///
  final InputType type;

  ///
  final double activePercent;

  ///
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.translucent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Text(
          type.value.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: (14.0 * activePercent).clamp(12.0, 14.0),
            color: Colors.white
                .withAlpha((0xFF * activePercent.clamp(0.5, 1.0)).round()),
          ),
        ),
      ),
    );
  }
}

class InputType {
  const InputType._internal(this.value, this.index);

  ///
  final String value;

  ///
  final int index;

  ///
  static const InputType text = InputType._internal('Text', 0);

  ///
  static const InputType normal = InputType._internal('Normal', 1);

  ///
  static const InputType video = InputType._internal('Video', 2);

  ///
  // static const _InputType boomerang = _InputType._internal('Boomerang', 3);

  ///
  static const InputType selfi = InputType._internal('Selfi', 4);

  ///
  static List<InputType> get values => [text, normal, video, selfi];
}

class InputTypeBuilder extends StatelessWidget {
  const InputTypeBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.child,
  }) : super(key: key);

  final InputTypeController controller;
  final Widget Function(BuildContext, InputType, Widget?) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<InputType>(
      valueListenable: controller,
      builder: builder,
      child: child,
    );
  }
}

class InputTypeController extends ValueNotifier<InputType> {
  InputTypeController({InputType? initialType})
      : super(initialType ?? InputType.normal);
}
// class _CameraListener extends StatelessWidget {
//   const _CameraListener({
//     Key? key,
//     required this.controller,
//     required this.builder,
//   }) : super(key: key);

//   final CameraController controller;
//   final Widget Function(CameraValue value) builder;

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<CameraValue>(
//       valueListenable: controller,
//       builder: (context, cameraValue, child) {
//         return builder(cameraValue);
//       },
//     );
//   }
// }
