import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// Camera controller

class CamController extends ValueNotifier<CamValue> {
  ///
  /// Dispose controller properly for better performance.
  ///
  /// Prefer using [CameraViewField] widget without controller,
  /// as much as possible.
  ///
  /// You can also directly use `[CameraView.pick(context)]` for capturing media
  CamController() : super(const CamValue()) {
    init();
    _zoomController = ZoomController(this);
    _exposureController = ExposureController(this);
    _drishyaEditingController = DrishyaEditingController();
    _pageController = PageController(initialPage: 1);
    _galleryController = GalleryController();
  }

  late final ZoomController _zoomController;
  late final ExposureController _exposureController;
  late final DrishyaEditingController _drishyaEditingController;
  late final PageController _pageController;
  late final GalleryController _galleryController;
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

  ///
  /// Open camera
  @internal
  void openCamera() => _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );

  ///
  /// Open gallery
  @internal
  void openGallery() => _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );

  /// Camera setting
  CameraSetting get setting => _setting;

  /// Text editor setting
  EditorSetting get editorSetting => _editorSetting;

  /// Photo editor setting
  EditorSetting get photoEditorSetting => _photoEditorSetting;

  //
  bool _hasCamera() {
    if (!initialized) {
      final exception = CameraException(
        'cameraUnavailable',
        "Couldn't find the camera!",
      );
      value = value.copyWith(error: exception);
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

  /// Pageview controller
  PageController get pageController => _pageController;

  /// Gallery controller
  GalleryController get galleryController => _galleryController;

  ///
  /// Change camera type
  void changeCameraType(CameraType type) {
    final canSwitch = type == CameraType.selfi &&
        value.lensDirection != CameraLensDirection.front;
    if (type == CameraType.video) {
      cameraController?.prepareForVideoRecording();
    }
    if (canSwitch) {
      switchCameraDirection(CameraLensDirection.front);
    }
    value = value.copyWith(cameraType: type);
  }

  ///
  /// Create new camera
  Future<CameraController?> createCamera({
    CameraDescription? cameraDescription,
  }) async {
    // if (cameraDescription == null) {
    //   _controllerNotifier.value = const ControllerValue();
    // }

    // Clear error first
    if (value.error != null) {
      value = value.copyWith();
    }

    var description = cameraDescription ?? value.cameraDescription;
    var cameras = value.cameras;

    // Fetch camera descriptions is description is not available
    if (description == null) {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        description = cameras[0];
      } else {
        description = const CameraDescription(
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
        final exception = CameraException('createCamera', error);
        value = value.copyWith(error: exception);
        return;
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
      value = value.copyWith(error: e);
      return null;
    } catch (e) {
      final exception = CameraException('createCamera', e.toString());
      value = value.copyWith(error: exception);
      return null;
    }
    return controller;
  }

  ///
  /// Take picture
  Future<DrishyaEntity?> takePicture(BuildContext context) async {
    if (!_hasCamera()) return null;

    if (value.isTakingPicture) return null;

    try {
      final navigator = Navigator.of(context);

      final controller = _cameraController!;

      // Update state
      value = value.copyWith(isTakingPicture: true);

      final xFile = await controller.takePicture();
      await controller.setFlashMode(FlashMode.off);

      final file = File(xFile.path);
      final bytes = await file.readAsBytes();

      if (_setting.editAfterCapture) {
        await controller.pausePreview();
        final route = SlideTransitionPageRoute<DrishyaEntity?>(
          builder: DrishyaEditor(
            setting: _photoEditorSetting.copyWith(
              backgrounds: [MemoryAssetBackground(bytes: bytes)],
            ),
          ),
          setting: const CustomRouteSetting(
            start: TransitionFrom.rightToLeft,
            reverse: TransitionFrom.leftToRight,
          ),
        );
        final de = await navigator.push(route);
        if (de != null && navigator.mounted) {
          navigator.pop([de]);
          return de;
        }
        await controller.resumePreview();
        value = value.copyWith(
          isTakingPicture: false,
          flashMode: FlashMode.off,
        );
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
            navigator.pop([drishyaEntity]);
          }
          return drishyaEntity;
        } else {
          final exception = CameraException(
            'takePictyre',
            'Something went wrong! Please try again',
          );
          value = value.copyWith(isTakingPicture: false, error: exception);

          return null;
        }
      }
    } on CameraException catch (e) {
      value = value.copyWith(isTakingPicture: false, error: e);
      return null;
    } catch (e) {
      final exception = CameraException('takePicture', e.toString());
      value = value.copyWith(isTakingPicture: false, error: exception);
      return null;
    }
  }

  ///
  /// Switch camera direction
  void switchCameraDirection(CameraLensDirection direction) {
    if (!_hasCamera()) return;

    try {
      final description = value.cameras.firstWhere(
        (element) => element.lensDirection == direction,
      );
      createCamera(cameraDescription: description);
    } on CameraException catch (e) {
      value = value.copyWith(error: e);
      return;
    } catch (e) {
      final exception = CameraException('switchingCameraLense', e.toString());
      value = value.copyWith(error: exception);
      return;
    }
  }

  ///
  /// Set flash mode
  Future<void> changeFlashMode() async {
    if (!_hasCamera()) return;

    try {
      final controller = _cameraController!;
      final mode = controller.value.flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;
      value = value.copyWith(flashMode: mode);
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      value = value.copyWith(error: e);
      return;
    } catch (e) {
      final exception = CameraException('flashMode', e.toString());
      value = value.copyWith(error: exception);
      return;
    }
  }

  ///
  /// Start video recording
  Future<void> startVideoRecording() async {
    if (!_hasCamera()) return;

    if (value.isRecordingVideo) return;

    try {
      final controller = _cameraController!;
      value = value.copyWith(
        isRecordingVideo: true,
        isRecordingPaused: false,
      );
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      value = value.copyWith(isRecordingVideo: false, error: e);
    } catch (e) {
      final exception = CameraException('startVideoRecording', e.toString());
      value = value.copyWith(isRecordingVideo: false, error: exception);
    }
  }

  ///
  /// Stop/Complete video recording
  Future<DrishyaEntity?> stopVideoRecording(
    BuildContext context, {
    bool createEntity = true,
  }) async {
    if (!_hasCamera()) return null;

    if (value.isRecordingVideo) {
      try {
        final navigator = Navigator.of(context);
        final controller = _cameraController!;
        final xfile = await controller.stopVideoRecording();
        value = value.copyWith(isRecordingVideo: false);

        if (createEntity) {
          final file = File(xfile.path);
          final entity = await PhotoManager.editor.saveVideo(
            file,
            title: path.basename(file.path),
          );
          if (file.existsSync()) {
            file.deleteSync();
          }

          if (entity != null) {
            final drishyaEntity = entity.toDrishya.copyWith(
              pickedFile: file,
            );
            if (navigator.mounted) {
              navigator.pop([drishyaEntity]);
            }
            return drishyaEntity;
          } else {
            final exception = CameraException(
              'stopVideoRecording',
              'Something went wrong! Please try again',
            );
            value = value.copyWith(error: exception);
            return null;
          }
        }
        return null;
      } on CameraException catch (e) {
        value = value.copyWith(isRecordingVideo: false, error: e);
      } catch (e) {
        final exception = CameraException('stopVideoRecording', e.toString());
        value = value.copyWith(isRecordingVideo: false, error: exception);
      }
    } else {
      final exception = CameraException(
        'stopVideoRecording',
        'Recording not found!',
      );
      value = value.copyWith(isRecordingVideo: false, error: exception);
    }
    return null;
  }

  ///
  /// Pause video recording
  Future<void> pauseVideoRecording() async {
    if (!_hasCamera()) return;

    if (value.isRecordingVideo) {
      try {
        final controller = _cameraController!;
        await controller.pauseVideoRecording();
        value = value.copyWith(isRecordingPaused: true);
      } on CameraException catch (e) {
        value = value.copyWith(error: e);
        return;
      } catch (e) {
        final exception = CameraException('pauseVideoRecording', e.toString());
        value = value.copyWith(error: exception);
        return;
      }
    } else {
      final exception = CameraException(
        'pauseVideoRecording',
        'Recording not found!',
      );
      value = value.copyWith(error: exception);
      return;
    }
  }

  ///
  /// Resume video recording
  Future<void> resumeVideoRecording() async {
    if (!_hasCamera()) return;

    if (value.isRecordingPaused) {
      try {
        final controller = _cameraController!;
        await controller.resumeVideoRecording();
        value = value.copyWith(isRecordingPaused: false);
      } on CameraException catch (e) {
        value = value.copyWith(error: e);
        return;
      } catch (e) {
        final exception = CameraException('resumeVideoRecording', e.toString());
        value = value.copyWith(error: exception);
        return;
      }
    } else {
      final exception = CameraException(
        'resumeVideoRecording',
        "Couldn't resume the video!",
      );
      value = value.copyWith(error: exception);
      return;
    }
  }

  ///
  /// Lock unlock capture orientation i,e. Portrait and Landscape
  Future<void> lockUnlockCaptureOrientation() async {
    if (!_hasCamera()) return;

    try {
      final controller = _cameraController!;
      if (controller.value.isCaptureOrientationLocked) {
        await controller.unlockCaptureOrientation();
      } else {
        await controller.lockCaptureOrientation();
      }
    } on CameraException catch (e) {
      value = value.copyWith(error: e);
      return;
    } catch (e) {
      final exception = CameraException(
        'orientationLockUnlock',
        "Couldn't change the orientation",
      );
      value = value.copyWith(error: exception);
      return;
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
    _pageController.dispose();
    _galleryController.dispose();
    _isDisposed = true;
    super.dispose();
  }

  //
}
