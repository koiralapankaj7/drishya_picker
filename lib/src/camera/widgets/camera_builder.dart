import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

///
class CameraBuilder extends StatelessWidget {
  ///
  const CameraBuilder({
    Key? key,
    required this.controller,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final CameraController controller;

  ///
  final Widget Function(BuildContext, CameraValue, Widget?) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: builder,
      child: child,
    );
  }
}
