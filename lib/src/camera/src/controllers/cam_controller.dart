// ignore_for_file: always_use_package_imports

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
// import 'package:pedantic/pedantic.dart';
import 'package:photo_manager/photo_manager.dart';

import '../entities/camera_type.dart';
import '../widgets/ui_handler.dart';
import 'controller_notifier.dart';
import 'exposure.dart';
import 'zoom.dart';

///
class CamController extends ValueNotifier<ActionValue> {
  ///
  CamController({
    required ControllerNotifier controllerNotifier,
    required BuildContext context,
    ResolutionPreset? resolutionPreset,
    ImageFormatGroup? imageFormatGroup,
  })  : _controllerNotifier = controllerNotifier,
        _uiHandler = UIHandler(context),
        zoom = Zoom(controllerNotifier),
        exposure = Exposure(controllerNotifier, UIHandler(context)),
        super(
          ActionValue(
            resolutionPreset: resolutionPreset ?? ResolutionPreset.medium,
            imageFormatGroup: imageFormatGroup ?? ImageFormatGroup.jpeg,
          ),
        );

  ///
  final ControllerNotifier _controllerNotifier;

  ///
  final UIHandler _uiHandler;

  ///
  final Zoom zoom;

  ///
  final Exposure exposure;

  @override
  void dispose() {
    zoom.dispose();
    exposure.dispose();
    super.dispose();
  }

  ///
  bool get initialized => _controllerNotifier.initialized;

  /// Call this only when [initialized] is true
  CameraController get controller => _controllerNotifier.value.controller!;

  ///
  void update({bool? isPlaygroundActive}) {
    value = value.copyWith(isPlaygroundActive: isPlaygroundActive);
  }

  ///
  void changeCameraType(CameraType type) {
    final canSwitch = type == CameraType.selfi &&
        value.lensDirection != CameraLensDirection.front;
    if (canSwitch) {
      switchCameraDirection(CameraLensDirection.front);
    }
    value = value.copyWith(cameraType: type);
  }

  /// Create new camera
  Future<CameraController?> createCamera({
    CameraDescription? cameraDescription,
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
    final controller = CameraController(
      description,
      value.resolutionPreset,
      enableAudio: value.enableAudio,
      imageFormatGroup: value.imageFormatGroup,
    );

    // listen controller
    controller.addListener(() {
      if (controller.value.hasError) {
        final error = 'Camera error ${controller.value.errorDescription}';
        _uiHandler.showSnackBar(error);
        _controllerNotifier.value =
            _controllerNotifier.value.copyWith(error: error);
      }
    });

    try {
      await controller.initialize();
      _controllerNotifier.value = ControllerValue(
        controller: controller,
        isReady: true,
      );
      value = value.copyWith(
        cameraDescription: description,
        cameras: cameras,
      );

      if (controller.description.lensDirection == CameraLensDirection.back) {
        // ignore: unawaited_futures
        controller.setFlashMode(value.flashMode);
      }
      // ignore: unawaited_futures
      Future.wait([
        controller.getMinExposureOffset().then(exposure.setMinExposure),
        controller.getMaxExposureOffset().then(exposure.setMaxExposure),
        controller.getMaxZoomLevel().then(zoom.setMaxZoom),
        controller.getMinZoomLevel().then(zoom.setMinZoom),
      ]);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
    } catch (e) {
      _uiHandler.showSnackBar(e.toString());
    }

    return controller;

    //
  }

  /// Take picture
  Future<DrishyaEntity?> takePicture() async {
    if (!initialized) {
      _uiHandler.showSnackBar("Couldn't find the camera!");
      return null;
    }

    if (value.isTakingPicture) {
      _uiHandler.showSnackBar('Capturing is currently running..');
      return null;
    }

    try {
      // Update state
      value = value.copyWith(isTakingPicture: true);

      final xFile = await controller.takePicture();
      final file = File(xFile.path);
      final data = await file.readAsBytes();
      final entity = await PhotoManager.editor.saveImage(
        data,
        title: path.basename(file.path),
      );

      if (file.existsSync()) {
        file.deleteSync();
      }

      // Update state
      value = value.copyWith(isTakingPicture: false);

      if (entity != null) {
        final drishyaEntity = entity.toDrishya.copyWith(
          pickedThumbData: data,
          pickedFile: file,
        );
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        _uiHandler.pop<DrishyaEntity>(drishyaEntity);
        return drishyaEntity;
      } else {
        _uiHandler.showSnackBar('Something went wrong! Please try again');
        value = value.copyWith(isTakingPicture: false);
        return null;
      }
    } on CameraException catch (e) {
      _uiHandler.showSnackBar('Exception occured while capturing picture : $e');
      value = value.copyWith(isTakingPicture: false);
      return null;
    } catch (e) {
      _uiHandler.showSnackBar('Exception occured while capturing picture : $e');
      return null;
    }
  }

  /// Switch camera direction
  void switchCameraDirection(CameraLensDirection direction) {
    try {
      final description = value.cameras.firstWhere(
        (element) => element.lensDirection == direction,
      );
      createCamera(cameraDescription: description);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
    }
  }

  /// Set flash mode
  Future<void> changeFlashMode() async {
    if (!initialized) {
      _uiHandler.showSnackBar("Couldn't find the camera!");
      return;
    }

    try {
      final mode = controller.value.flashMode == FlashMode.off
          ? FlashMode.always
          : FlashMode.off;
      value = value.copyWith(flashMode: mode);
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
      rethrow;
    }
  }

  /// Start video recording
  Future<void> startVideoRecording() async {
    if (!initialized) {
      _uiHandler.showSnackBar("Couldn't find the camera!");
      return;
    }

    if (value.isRecordingVideo) {
      _uiHandler.showSnackBar('Recording is already started!');
      return;
    }

    try {
      await controller.startVideoRecording();
      value = value.copyWith(
        isRecordingVideo: true,
        isRecordingPaused: false,
      );
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
      value = value.copyWith(isRecordingVideo: false);
      return;
    }
  }

  /// Stop/Complete video recording
  Future<void> stopVideoRecording() async {
    if (!initialized) {
      _uiHandler.showSnackBar("Couldn't find the camera!");
      return;
    }

    if (value.isRecordingVideo) {
      try {
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
          _uiHandler.pop<DrishyaEntity>(drishyaEntity);
          return;
        } else {
          _uiHandler.showSnackBar('Something went wrong! Please try again');
          return;
        }
      } on CameraException catch (e) {
        _uiHandler.showExceptionSnackbar(e);
        // Update state
        value = value.copyWith(isRecordingVideo: false);
        rethrow;
      }
    } else {
      _uiHandler.showSnackBar('Recording not found!');
      return;
    }
  }

  /// Pause video recording
  Future<void> pauseVideoRecording() async {
    if (!initialized) {
      _uiHandler.showSnackBar("Couldn't find the camera!");
      return;
    }

    if (value.isRecordingVideo) {
      try {
        await controller.pauseVideoRecording();
        // Update state
        value = value.copyWith(isRecordingPaused: true);
      } on CameraException catch (e) {
        // Update state
        _uiHandler.showExceptionSnackbar(e);
        rethrow;
      }
    } else {
      _uiHandler.showSnackBar('Recording not found!');
      return;
    }
  }

  /// Resume video recording
  Future<void> resumeVideoRecording() async {
    if (!initialized) {
      _uiHandler.showSnackBar("Couldn't find the camera!");
      return;
    }

    if (value.isRecordingPaused) {
      try {
        await controller.resumeVideoRecording();
        // Update state
        value = value.copyWith(isRecordingPaused: false);
      } on CameraException catch (e) {
        _uiHandler.showExceptionSnackbar(e);
        rethrow;
      }
    } else {
      _uiHandler.showSnackBar("Couldn't resume the video!");
      return;
    }
  }

  /// Lock unlock capture orientation i,e. Portrait and Landscape
  Future<void> lockUnlockCaptureOrientation() async {
    if (!initialized) {
      _uiHandler.showSnackBar("Couldn't find the camera!");
      return;
    }

    if (controller.value.isCaptureOrientationLocked) {
      await controller.unlockCaptureOrientation();
      _uiHandler.showSnackBar('Capture orientation unlocked');
    } else {
      await controller.lockCaptureOrientation();
      _uiHandler.showSnackBar(
        '''Capture orientation locked to ${controller.value.lockedCaptureOrientation.toString().split('.').last}''',
      );
    }
  }

  //
}

///
class ActionValue {
  ///
  ActionValue({
    required this.resolutionPreset,
    required this.imageFormatGroup,
    this.cameraDescription,
    this.cameras = const [],
    this.enableAudio = true,
    this.cameraType = CameraType.normal,
    this.flashMode = FlashMode.off,
    this.isTakingPicture = false,
    this.isRecordingVideo = false,
    this.isRecordingPaused = false,
    this.isPlaygroundActive = false,
  });

  ///
  final CameraDescription? cameraDescription;

  ///
  final List<CameraDescription> cameras;

  ///
  final CameraType cameraType;

  ///
  final bool enableAudio;

  ///
  final FlashMode flashMode;

  ///
  final ResolutionPreset resolutionPreset;

  ///
  final ImageFormatGroup imageFormatGroup;

  ///
  final bool isTakingPicture;

  ///
  final bool isRecordingVideo;

  ///
  final bool isRecordingPaused;

  ///
  final bool isPlaygroundActive;

  ///
  ActionValue copyWith({
    CameraDescription? cameraDescription,
    List<CameraDescription>? cameras,
    CameraType? cameraType,
    bool? enableAudio,
    FlashMode? flashMode,
    bool? isTakingPicture,
    bool? isRecordingVideo,
    bool? isRecordingPaused,
    bool? isPlaygroundActive,
  }) {
    return ActionValue(
      resolutionPreset: resolutionPreset,
      imageFormatGroup: imageFormatGroup,
      cameraDescription: cameraDescription ?? this.cameraDescription,
      cameras: cameras ?? this.cameras,
      cameraType: cameraType ?? this.cameraType,
      enableAudio: enableAudio ?? this.enableAudio,
      flashMode: flashMode ?? this.flashMode,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
      isRecordingPaused: isRecordingPaused ?? this.isRecordingPaused,
      isPlaygroundActive: isPlaygroundActive ?? this.isPlaygroundActive,
    );
  }

  //========================== GETTERS ==================================

  ///
  /// Current lense direction
  ///
  CameraLensDirection get lensDirection =>
      cameraDescription?.lensDirection ?? CameraLensDirection.back;

  ///
  /// Opposite lense direction of current [lensDirection]
  ///
  CameraLensDirection get oppositeLensDirection =>
      lensDirection == CameraLensDirection.back
          ? CameraLensDirection.front
          : CameraLensDirection.back;

  ///
  /// Hide camera close button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraCloseButton =>
      cameraType == CameraType.text || isRecordingVideo;

  ///
  /// Hide camera flash button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Camera lense direction is front
  /// 3. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraFlashButton =>
      cameraType == CameraType.text ||
      lensDirection == CameraLensDirection.front ||
      isRecordingVideo;

  ///
  /// Hide camera shutter button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  ///
  bool get hideCameraShutterButton => cameraType == CameraType.text;

  ///
  /// Hide camera footer if :-
  ///
  /// 1. Video recoring is active [isRecordingVideo]
  /// 2. When [CameraType.text] playground is in editing mode
  ///
  bool get hideCameraFooter => isRecordingVideo || isPlaygroundActive;

  ///
  /// Hide camera gallery  button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraGalleryButton =>
      cameraType == CameraType.text || isRecordingVideo;

  ///
  /// Hide camera rotation button if :-
  ///
  /// 1. Camera type is [CameraType.text]
  /// 2. Video recoring is active [isRecordingVideo]
  ///
  bool get hideCameraRotationButton =>
      cameraType == CameraType.text || isRecordingVideo;
}
