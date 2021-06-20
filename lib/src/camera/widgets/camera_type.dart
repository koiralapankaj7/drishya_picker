import 'package:flutter/material.dart';

///
class CameraType {
  const CameraType._internal(this.value, this.index);

  ///
  final String value;

  ///
  final int index;

  ///
  static const CameraType text = CameraType._internal('Text', 0);

  ///
  static const CameraType normal = CameraType._internal('Normal', 1);

  ///
  static const CameraType video = CameraType._internal('Video', 2);

  ///
  // static const _InputType boomerang = _InputType._internal('Boomerang', 3);

  ///
  static const CameraType selfi = CameraType._internal('Selfi', 4);

  ///
  static List<CameraType> get values => [text, normal, video, selfi];
}

///
class CameraTypeBuilder extends StatelessWidget {
  ///
  const CameraTypeBuilder({
    Key? key,
    required this.notifier,
    required this.builder,
    this.child,
  }) : super(key: key);

  ///
  final ValueNotifier<CameraType> notifier;

  ///
  final Widget Function(BuildContext, CameraType, Widget?) builder;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraType>(
      valueListenable: notifier,
      builder: builder,
      child: child,
    );
  }
}
