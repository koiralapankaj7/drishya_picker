// ignore_for_file: always_use_package_imports

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class ZoomController extends ValueNotifier<ZoomValue> {
  ///
  ZoomController(
    CamController controller,
  )   : _controller = controller,
        super(ZoomValue());

  final CamController _controller;

  //
  bool get _initialized => _controller.initialized;

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
  Future<void> startZooming(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (!_initialized || value.pointers != 2) {
      return;
    }

    value = value.copyWith(
      currentScale: (value.baseScale * details.scale)
          .clamp(value.minAvailableZoom, value.maxAvailableZoom),
    );
    await _controller.cameraController!.setZoomLevel(value.currentScale);
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