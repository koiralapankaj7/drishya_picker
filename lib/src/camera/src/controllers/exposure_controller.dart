import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class ExposureController extends ValueNotifier<ExposureValue> {
  ///
  ExposureController(CamController camController)
      : _camController = camController,
        super(ExposureValue());

  final CamController _camController;

  bool get _initialized => _camController.initialized;

  CameraController? get _controller => _camController.cameraController;

  //
  bool _hasCamera(ValueSetter<Exception>? onException) {
    if (!_initialized) {
      onException?.call(Exception("Couldn't find the camera!"));
      return false;
    }
    return true;
  }

  ///
  /// Set maximum exposure value
  ///
  void setMaxExposure(double offset) {
    value = value.copyWith(maxAvailableExposurer: offset);
  }

  ///
  /// Set minimum exposure value
  ///
  void setMinExposure(double offset) {
    value = value.copyWith(minAvailableExposure: offset);
  }

  ///
  /// Set exposure and focus point on the screen
  ///
  Future<void> setExposureAndFocus(
    TapDownDetails details,
    BoxConstraints constraints, {
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    try {
      await Future.wait([
        _controller!.setExposurePoint(offset),
        _controller!.setFocusPoint(offset),
      ]);
    } on CameraException catch (e) {
      onException?.call(e);
    } catch (e) {
      onException?.call(Exception(e));
    }
  }

  ///
  /// Set exposure mode
  ///
  Future<void> setExposureMode(
    ExposureMode mode, {
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;
    try {
      await _controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      onException?.call(e);
    } catch (e) {
      onException?.call(Exception(e));
    }
  }

  ///
  /// Set focus mode
  ///
  Future<void> setFocusMode(
    FocusMode mode, {
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;
    try {
      await _controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      onException?.call(e);
    } catch (e) {
      onException?.call(Exception(e));
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

  /// Current exposure  Offset
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
