import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

///
class ControllerNotifier extends ValueNotifier<ControllerValue> {
  ///
  ControllerNotifier() : super(const ControllerValue());

  /// Camera controller
  CameraController? get controller => value.controller;

  /// TRUE, if camera is ready to use.
  bool get isReady => value.isReady;

  /// TRUE, if controller is initialized
  bool get initialized => isReady && (controller?.value.isInitialized ?? false);

  ///
  bool get hasError => value.error?.isNotEmpty ?? false;

  ///
  void disposeCamera() {
    controller?.dispose();
  }

  @override
  void dispose() {
    disposeCamera();
    super.dispose();
  }
}

///
class ControllerValue {
  ///
  const ControllerValue({
    this.controller,
    this.isReady = false,
    this.error,
  });

  ///
  final CameraController? controller;

  ///
  final bool isReady;

  ///
  final String? error;

  ///
  ControllerValue copyWith({
    CameraController? controller,
    bool? isReady,
    String? error,
  }) {
    return ControllerValue(
      controller: controller ?? this.controller,
      isReady: isReady ?? this.isReady,
      error: error ?? this.error,
    );
  }
}
