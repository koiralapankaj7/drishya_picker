import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'controller_notifier.dart';

///
class Zoom extends ValueNotifier<ZoomValue> {
  ///
  Zoom(
    ControllerNotifier controllerNotifier,
  )   : _controllerNotifier = controllerNotifier,
        super(ZoomValue());

  final ControllerNotifier _controllerNotifier;

  bool get _initialized => _controllerNotifier.initialized;

  /// Call this only when [_initialized] is true
  CameraController get _controller => _controllerNotifier.value.controller!;

  ///
  void addPointer(PointerDownEvent event) {
    value = value.copyWith(pointers: value.pointers + 1);
  }

  ///
  void removePointer(PointerUpEvent event) {
    value = value.copyWith(pointers: value.pointers - 1);
  }

  ///
  void setMaxZoom(double zoom) {
    value = value.copyWith(maxAvailableZoom: zoom);
  }

  ///
  void setMinZoom(double zoom) {
    value = value.copyWith(minAvailableZoom: zoom);
  }

  ///
  void initZoom(ScaleStartDetails details) {
    value = value.copyWith(baseScale: value.currentScale);
  }

  ///
  void startZooming(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (!_initialized || value.pointers != 2) {
      return;
    }

    value = value.copyWith(
      currentScale: (value.baseScale * details.scale)
          .clamp(value.minAvailableZoom, value.maxAvailableZoom),
    );
    await _controller.setZoomLevel(value.currentScale);
  }
}

///
class ZoomValue {
  ///
  ZoomValue({
    this.minAvailableZoom = 1.0,
    this.maxAvailableZoom = 1.0,
    this.currentScale = 1.0,
    this.baseScale = 1.0,
    this.pointers = 0,
  });

  ///
  final double minAvailableZoom;

  ///
  final double maxAvailableZoom;

  ///
  final double currentScale;

  ///
  final double baseScale;

  ///
  final int pointers;

  ///
  ZoomValue copyWith({
    double? minAvailableZoom,
    double? maxAvailableZoom,
    double? currentScale,
    double? baseScale,
    int? pointers,
  }) {
    return ZoomValue(
      minAvailableZoom: minAvailableZoom ?? this.minAvailableZoom,
      maxAvailableZoom: maxAvailableZoom ?? this.maxAvailableZoom,
      currentScale: currentScale ?? this.currentScale,
      baseScale: baseScale ?? this.baseScale,
      pointers: pointers ?? this.pointers,
    );
  }
}
