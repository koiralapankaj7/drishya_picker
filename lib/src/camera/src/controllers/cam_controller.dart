import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// Camera controller

class CamController extends ValueNotifier<CamValue> {
  ///
  ///
  /// Dispose controller properly for better performance.
  ///
  /// Prefer using [CameraViewField] widget without controller,
  /// as much as possible.
  ///
  /// You can also directly use `[CameraView.pick(context)]` for capturing media
  ///
  CamController() : super(CamValue()) {
    init();
    _zoomController = ZoomController(this);
    _exposureController = ExposureController(this);
    _drishyaEditingController = DrishyaEditingController();
  }

  late final ZoomController _zoomController;
  late final ExposureController _exposureController;
  late final DrishyaEditingController _drishyaEditingController;
  late CameraSetting _setting;
  late EditorSetting _editorSetting;
  late EditorSetting _photoEditorSetting;
  // Value will be set after creating camera
  CameraController? _cameraController;
  var _isDisposed = false;

  /// Initialize controller settings
  @internal
  void init({
    CameraSetting? setting,
    EditorSetting? editorSetting,
    EditorSetting? photoEditorSetting,
  }) {
    _setting = setting ?? const CameraSetting();
    _editorSetting = editorSetting ?? const EditorSetting();
    _photoEditorSetting = photoEditorSetting ?? _editorSetting;
  }

  ///
  @internal
  void update({bool? isPlaygroundActive}) {
    value = value.copyWith(isPlaygroundActive: isPlaygroundActive);
  }

  /// Camera setting
  CameraSetting get setting => _setting;

  /// Text editor setting
  EditorSetting get editorSetting => _editorSetting;

  /// Photo editor setting
  EditorSetting get photoEditorSetting => _photoEditorSetting;

  //
  bool _hasCamera(ValueSetter<Exception>? onException) {
    if (!initialized) {
      onException?.call(Exception("Couldn't find the camera!"));
      return false;
    }
    return true;
  }

  /// Check if camera has been initialized or not
  bool get initialized => _cameraController?.value.isInitialized ?? false;

  /// Flutter Camera controller
  CameraController? get cameraController => _cameraController;

  /// Photo editing controller
  DrishyaEditingController get drishyaEditingController =>
      _drishyaEditingController;

  /// Camera zoom controller
  ZoomController get zoomController => _zoomController;

  /// Camera exposure controller
  ExposureController get exposureController => _exposureController;

  ///
  /// Change camera type
  ///
  void changeCameraType(
    CameraType type, {
    ValueSetter<Exception>? onException,
  }) {
    final canSwitch = type == CameraType.selfi &&
        value.lensDirection != CameraLensDirection.front;
    if (canSwitch) {
      switchCameraDirection(
        CameraLensDirection.front,
        onException: onException,
      );
    }
    value = value.copyWith(cameraType: type);
  }

  ///
  /// Create new camera
  ///
  Future<CameraController?> createCamera({
    CameraDescription? cameraDescription,
    ValueSetter<Exception>? onException,
  }) async {
    // if (cameraDescription == null) {
    //   _controllerNotifier.value = const ControllerValue();
    // }

    var description = cameraDescription ?? value.cameraDescription;
    var cameras = value.cameras;

    // Fetch camera descriptions is description is not available
    if (description == null) {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        description = cameras[0];
      } else {
        description = CameraDescription(
          name: 'Simulator',
          lensDirection: CameraLensDirection.front,
          sensorOrientation: 0,
        );
      }
    }

    // create camera controller
    _cameraController = CameraController(
      description,
      setting.resolutionPreset,
      enableAudio: value.enableAudio,
      imageFormatGroup: _setting.imageFormatGroup,
    );

    final controller = _cameraController!;

    // listen controller
    controller.addListener(() {
      if (controller.value.hasError) {
        final error = 'Camera error ${controller.value.errorDescription}';
        onException?.call(Exception(error));
        // _controllerNotifier.value =
        //     _controllerNotifier.value.copyWith(error: error);
      }
    });

    try {
      await controller.initialize();
      // _controllerNotifier.value = ControllerValue(
      //   controller: controller,
      //   isReady: true,
      // );
      value = value.copyWith(
        cameraDescription: description,
        cameras: cameras,
      );

      if (controller.description.lensDirection == CameraLensDirection.back) {
        unawaited(controller.setFlashMode(value.flashMode));
      }
      unawaited(
        Future.wait([
          controller
              .getMinExposureOffset()
              .then(_exposureController.setMinExposure),
          controller
              .getMaxExposureOffset()
              .then(_exposureController.setMaxExposure),
          controller.getMaxZoomLevel().then(_zoomController.setMaxZoom),
          controller.getMinZoomLevel().then(_zoomController.setMinZoom),
        ]),
      );
    } on CameraException catch (e) {
      onException?.call(e);
    } catch (e) {
      onException?.call(Exception(e));
    }
    return controller;
  }

  ///
  /// Take picture
  ///
  Future<DrishyaEntity?> takePicture(
    BuildContext context, {
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return null;

    if (value.isTakingPicture) {
      onException?.call(Exception('Capturing is currently running..'));
      return null;
    }

    try {
      final navigator = Navigator.of(context);

      final controller = _cameraController!;

      // Update state
      value = value.copyWith(isTakingPicture: true);

      final xFile = await controller.takePicture();
      final file = File(xFile.path);
      final bytes = await file.readAsBytes();

      if (_setting.editAfterCapture) {
        final route = SlideTransitionPageRoute<DrishyaEntity?>(
          builder: DrishyaEditor(
            setting: _photoEditorSetting.copyWith(
              backgrounds: [PhotoBackground(bytes: bytes)],
            ),
          ),
          begainHorizontal: true,
          endHorizontal: true,
        );
        final de = await navigator.push(route);
        Future.delayed(const Duration(milliseconds: 400), controller.dispose);
        if (de != null && navigator.mounted) {
          navigator.pop(de);
        }
        value = value.copyWith(isTakingPicture: false);
        return de;
      } else {
        final entity = await PhotoManager.editor.saveImage(
          bytes,
          title: path.basename(file.path),
        );

        if (file.existsSync()) {
          file.deleteSync();
        }

        if (entity != null) {
          final drishyaEntity = entity.toDrishya.copyWith(
            pickedThumbData: bytes,
            pickedFile: file,
          );
          if (navigator.mounted) {
            navigator.pop(drishyaEntity);
          }
          return drishyaEntity;
        } else {
          onException?.call(
            Exception('Something went wrong! Please try again'),
          );
          value = value.copyWith(isTakingPicture: false);
          return null;
        }
      }
    } on CameraException catch (e) {
      onException?.call(e);
      value = value.copyWith(isTakingPicture: false);
      return null;
    } catch (e) {
      onException?.call(Exception(e));
      return null;
    }
  }

  ///
  /// Switch camera direction
  ///
  void switchCameraDirection(
    CameraLensDirection direction, {
    ValueSetter<Exception>? onException,
  }) {
    if (!_hasCamera(onException)) return;
    try {
      final description = value.cameras.firstWhere(
        (element) => element.lensDirection == direction,
      );
      createCamera(cameraDescription: description);
    } on CameraException catch (e) {
      onException?.call(e);
    } catch (e) {
      onException?.call(Exception(e));
    }
  }

  ///
  /// Set flash mode
  ///
  Future<void> changeFlashMode({ValueSetter<Exception>? onException}) async {
    if (!_hasCamera(onException)) return;
    try {
      final controller = _cameraController!;
      final mode = controller.value.flashMode == FlashMode.off
          ? FlashMode.always
          : FlashMode.off;
      value = value.copyWith(flashMode: mode);
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      onException?.call(e);
      rethrow;
    } catch (e) {
      onException?.call(Exception(e));
    }
  }

  ///
  /// Start video recording
  ///
  Future<void> startVideoRecording({
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;

    if (value.isRecordingVideo) {
      onException?.call(Exception('Recording is already started!'));
      return;
    }

    try {
      final controller = _cameraController!;
      await controller.startVideoRecording();
      value = value.copyWith(
        isRecordingVideo: true,
        isRecordingPaused: false,
      );
    } on CameraException catch (e) {
      onException?.call(e);
      value = value.copyWith(isRecordingVideo: false);
    } catch (e) {
      onException?.call(Exception(e));
    }
  }

  ///
  /// Stop/Complete video recording
  ///
  Future<void> stopVideoRecording(
    BuildContext context, {
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;

    if (value.isRecordingVideo) {
      try {
        final navigator = Navigator.of(context);

        final controller = _cameraController!;

        final xfile = await controller.stopVideoRecording();
        final file = File(xfile.path);
        final entity = await PhotoManager.editor.saveVideo(
          file,
          title: path.basename(file.path),
        );
        if (file.existsSync()) {
          file.deleteSync();
        }
        // Update state
        value = value.copyWith(isRecordingVideo: false);

        if (entity != null) {
          final drishyaEntity = entity.toDrishya.copyWith(
            pickedFile: file,
          );
          await SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
          if (navigator.mounted) {
            navigator.pop(drishyaEntity);
          }
        } else {
          onException?.call(
            Exception('Something went wrong! Please try again'),
          );
        }
      } on CameraException catch (e) {
        onException?.call(Exception(e));
        // Update state
        value = value.copyWith(isRecordingVideo: false);
      } catch (e) {
        onException?.call(Exception(e));
      }
    } else {
      onException?.call(Exception('Recording not found!'));
    }
  }

  ///
  /// Pause video recording
  ///
  Future<void> pauseVideoRecording({
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;

    if (value.isRecordingVideo) {
      try {
        final controller = _cameraController!;
        await controller.pauseVideoRecording();
        // Update state
        value = value.copyWith(isRecordingPaused: true);
      } on CameraException catch (e) {
        onException?.call(e);
      } catch (e) {
        onException?.call(Exception(e));
      }
    } else {
      onException?.call(Exception('Recording not found!'));
    }
  }

  ///
  /// Resume video recording
  ///
  Future<void> resumeVideoRecording({
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;

    if (value.isRecordingPaused) {
      try {
        final controller = _cameraController!;
        await controller.resumeVideoRecording();
        value = value.copyWith(isRecordingPaused: false);
      } on CameraException catch (e) {
        onException?.call(e);
      } catch (e) {
        onException?.call(Exception(e));
      }
    } else {
      onException?.call(Exception("Couldn't resume the video!"));
    }
  }

  ///
  /// Lock unlock capture orientation i,e. Portrait and Landscape
  ///
  Future<void> lockUnlockCaptureOrientation({
    ValueSetter<Exception>? onException,
  }) async {
    if (!_hasCamera(onException)) return;
    final controller = _cameraController!;
    if (controller.value.isCaptureOrientationLocked) {
      await controller.unlockCaptureOrientation();
    } else {
      await controller.lockCaptureOrientation();
    }
  }

  @override
  set value(CamValue newValue) {
    if (_isDisposed) return;
    super.value = newValue;
  }

  @override
  void dispose() {
    _zoomController.dispose();
    _exposureController.dispose();
    _drishyaEditingController.dispose();
    _cameraController?.dispose();
    _isDisposed = true;
    super.dispose();
  }

  //
}
