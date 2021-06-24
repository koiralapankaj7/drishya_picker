import 'package:flutter/material.dart';

import '../../controllers/camera_action.dart';
import '../../entities/camera_type.dart';
import 'action_detector.dart';

///
class CameraTypeBuilder extends StatelessWidget {
  ///
  const CameraTypeBuilder({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final Widget Function(CameraAction, CameraType, Widget?) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ActionDetector(
      builder: (action, constraints) {
        return ValueListenableBuilder<CameraType>(
          valueListenable: action.cameraType,
          builder: (_, t, c) => builder(action, t, c),
          child: child,
        );
      },
    );
  }
}
