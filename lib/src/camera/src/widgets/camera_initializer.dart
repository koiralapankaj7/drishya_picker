import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../controllers/controller_notifier.dart';

///
class CameraInitializer extends StatelessWidget {
  ///
  const CameraInitializer({
    Key? key,
    required this.controllerNotifier,
    required this.builder,
  }) : super(key: key);

  ///
  final ControllerNotifier controllerNotifier;

  ///
  final Widget Function(CameraController controller) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ControllerValue>(
      valueListenable: controllerNotifier,
      builder: (context, value, child) {
        if (controllerNotifier.initialized) {
          return builder(value.controller!);
        }
        return child!;
      },
      child: const SizedBox(),
    );
  }
}
