import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../widgets/ui_handler.dart';
import 'controller_notifier.dart';

///
class Exposure extends ValueNotifier<ExposureValue> {
  ///
  Exposure(
    ControllerNotifier controllerNotifier,
    UIHandler uiHandler,
  )   : _controllerNotifier = controllerNotifier,
        _uiHandler = uiHandler,
        super(ExposureValue());

  final ControllerNotifier _controllerNotifier;
  final UIHandler _uiHandler;

  bool get _initialized => _controllerNotifier.initialized;

  /// Call this only when [_initialized] is true
  CameraController get _controller => _controllerNotifier.value.controller!;

  ///
  void setMaxExposure(double offset) {
    value = value.copyWith(maxAvailableExposurer: offset);
  }

  ///
  void setMinExposure(double offset) {
    value = value.copyWith(minAvailableExposure: offset);
  }

  /// Set exposure and focus point on the screen
  void setExposureAndFocus(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    if (!_initialized) return;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    try {
      await Future.wait([
        _controller.setExposurePoint(offset),
        _controller.setFocusPoint(offset),
      ]);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
      rethrow;
    }
  }

  /// Set exposure mode
  Future<void> setExposureMode(ExposureMode mode) async {
    if (!_initialized) return;

    try {
      await _controller.setExposureMode(mode);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
      rethrow;
    }
  }

  /// Set focus mode
  Future<void> setFocusMode(FocusMode mode) async {
    if (!_initialized) return;

    try {
      await _controller.setFocusMode(mode);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
      rethrow;
    }
  }
}

///
class ExposureValue {
  ///
  ExposureValue({
    this.minAvailableExposure = 0.0,
    this.maxAvailableExposurer = 0.0,
    this.currentExposure = 0.0,
  });

  /// Min available Offset
  final double minAvailableExposure;

  /// Max available Offset
  final double maxAvailableExposurer;

  /// Current  Offset
  final double currentExposure;

  ///
  ExposureValue copyWith({
    double? minAvailableExposure,
    double? maxAvailableExposurer,
    double? currentExposure,
  }) {
    return ExposureValue(
      minAvailableExposure: minAvailableExposure ?? this.minAvailableExposure,
      maxAvailableExposurer:
          maxAvailableExposurer ?? this.maxAvailableExposurer,
      currentExposure: currentExposure ?? this.currentExposure,
    );
  }
}
