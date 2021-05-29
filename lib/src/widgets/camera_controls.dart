// part of 'camera_view.dart';

import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:drishya_picker/src/utils/custom_icons.dart';
import 'package:drishya_picker/src/utils/custom_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CameraAction extends StatefulWidget {
  const CameraAction({
    Key? key,
    // required this.controller,
  }) : super(key: key);

  // final CameraController controller;

  @override
  _CameraActionState createState() => _CameraActionState();
}

class _CameraActionState extends State<CameraAction> {
  XFile? imageFile;

  ///
  // void _displayThumbnail(XFile file) {
  //   setState(() {
  //     imageFile = file;
  //   });
  // }

  // final _slideController = SlideController(length: _InputType.values.length);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Close and flash
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Expanded(child: SizedBox()),
              // _CameraListener(
              //   controller: widget.controller,
              //   builder: (value) {
              //     return IconButton(
              //       icon: Icon(
              //         value.flashMode == FlashMode.off
              //             ? Icons.flash_on
              //             : Icons.flash_off,
              //         color: Colors.white,
              //       ),
              //       onPressed: () {},
              //     );
              //   },
              // ),
            ],
          ),

          // Expanded
          const Expanded(child: SizedBox()),

          // Filters and capture
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
                ),
              ),
            ],
          ),

          const SizedBox(height: 4.0),

          // preview, mode and camera
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
                // Preview
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      color: Colors.white,
                      height: 48.0,
                      width: 48.0,
                      child: imageFile == null
                          ? SizedBox()
                          : Image.file(File(imageFile!.path)),
                    ),
                  ),
                ),

                // Expanded
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Text scroller
                      Expanded(child: _ItemsPageView()),

                      const SizedBox(height: 8.0),

                      // _InputItem
                      Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: Radius.circular(2.0),
                            bottomRight: Radius.circular(2.0),
                          ),
                        ),
                      ),

                      //
                    ],
                  ),
                ),

                // Camera
                IconButton(
                  icon: const Icon(
                    CustomIcons.camera,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),

                //
              ],
            ),
          ),

          //
        ],
      ),
    );
  }
}

class _ItemsPageView extends StatefulWidget {
  const _ItemsPageView({
    Key? key,
    this.onPageChanged,
  }) : super(key: key);

  final void Function(int)? onPageChanged;

  @override
  __ItemsPageViewState createState() => __ItemsPageViewState();
}

class __ItemsPageViewState extends State<_ItemsPageView> {
  late final PageController pageController;
  double pageValue = 0.0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
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
      itemCount: _InputType.values.length,
      controller: pageController,
      onPageChanged: (index) {},
      itemBuilder: (context, position) {
        final type = _InputType.values[position];
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
  final _InputType type;

  ///
  final double activePercent;

  ///
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
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

class _CameraListener extends StatelessWidget {
  const _CameraListener({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final CameraController controller;
  final Widget Function(CameraValue value) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (context, cameraValue, child) {
        return builder(cameraValue);
      },
    );
  }
}

// class _InputController extends ValueNotifier<_InputValue> {
//   _InputController() : super(_InputValue());
// }

// class _InputValue {
//   _InputValue({
//     this.type = _InputType.normal,
//   });

//   final _InputType type;
// }

class _InputType {
  const _InputType._internal(this.value, this.index);

  ///
  final String value;

  ///
  final int index;

  ///
  static const _InputType text = _InputType._internal('Text', 0);

  ///
  static const _InputType normal = _InputType._internal('Normal', 1);

  ///
  static const _InputType video = _InputType._internal('Video', 2);

  ///
  // static const _InputType boomerang = _InputType._internal('Boomerang', 3);

  ///
  static const _InputType selfi = _InputType._internal('Selfi', 4);

  ///
  static List<_InputType> get values => [text, normal, video, selfi];
}

class ScrollDetail {
  ///
  ScrollDetail({
    this.currentIndex = 0,
    this.nextIndex = 0,
    this.direction = ScrollDirection.idle,
    this.slidePercent = 0.0,
  });

  ///
  final int currentIndex;

  ///
  final int nextIndex;

  ///
  final ScrollDirection direction;

  ///
  final double slidePercent;

  ///
  ScrollDetail _copyWith({
    int? currentIndex,
    int? nextIndex,
    ScrollDirection? direction,
    double? slidePercent,
  }) =>
      ScrollDetail(
        currentIndex: currentIndex ?? this.currentIndex,
        nextIndex: nextIndex ?? this.nextIndex,
        direction: direction ?? this.direction,
        slidePercent: slidePercent ?? this.slidePercent,
      );
}
