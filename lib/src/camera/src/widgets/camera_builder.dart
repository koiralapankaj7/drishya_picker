import 'package:flutter/material.dart';

import '../controllers/cam_controller.dart';

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
  final CamController controller;

  ///
  final Widget Function(ActionValue value, Widget? child) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ActionValue>(
      valueListenable: controller,
      builder: (context, v, c) => builder(v, c),
      child: child,
    );
  }
}
