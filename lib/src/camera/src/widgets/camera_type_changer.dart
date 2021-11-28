// ignore_for_file: always_use_package_imports

import 'dart:math';

import 'package:drishya_picker/assets/icons/custom_icons.dart';
import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';
import '../entities/camera_type.dart';
import 'camera_builder.dart';

///
class CameraTypeChanger extends StatelessWidget {
  ///
  const CameraTypeChanger({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final CamController controller;

  @override
  Widget build(BuildContext context) {
    return CameraBuilder(
      controller: controller,
      builder: (value, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Text scroller
            Expanded(
              child: _TypesPageView(
                initialType: controller.value.cameraType,
                onChanged: controller.changeCameraType,
              ),
            ),

            const SizedBox(height: 8),

            // Arrow indicator
            SizedBox(
              height: 12,
              width: 20,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Transform.rotate(
                  angle: -pi / 2,
                  child: const Icon(
                    CustomIcons.play,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            //
          ],
        );
      },
    );
  }
}

class _TypesPageView extends StatefulWidget {
  const _TypesPageView({
    Key? key,
    required this.initialType,
    required this.onChanged,
  }) : super(key: key);

  final void Function(CameraType type) onChanged;

  final CameraType initialType;

  @override
  _TypesPageViewState createState() => _TypesPageViewState();
}

class _TypesPageViewState extends State<_TypesPageView> {
  late final PageController pageController;
  double pageValue = 0;

  @override
  void initState() {
    super.initState();
    pageValue = widget.initialType.index.toDouble();
    pageController = PageController(
      initialPage: widget.initialType.index,
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
      itemCount: CameraType.values.length,
      controller: pageController,
      onPageChanged: (index) {
        final type = CameraType.values[index];
        widget.onChanged(type);
      },
      itemBuilder: (context, position) {
        final type = CameraType.values[position];
        var activePercent = 0.0;
        if (position == pageValue.floor()) {
          activePercent = 1 - (pageValue - position).clamp(0.0, 1.0);
        } else if (position == pageValue.floor() + 1) {
          activePercent = 1 - (position - pageValue).clamp(0.0, 1.0);
        } else {
          activePercent = 0.0;
        }
        return _CameraType(
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

class _CameraType extends StatelessWidget {
  ///
  const _CameraType({
    Key? key,
    required this.type,
    required this.activePercent,
    this.onPressed,
  }) : super(key: key);

  ///
  final CameraType type;

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
