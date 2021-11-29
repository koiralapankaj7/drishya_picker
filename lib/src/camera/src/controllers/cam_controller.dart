// ignore_for_file: always_use_package_imports

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:photo_manager/photo_manager.dart';

import '../entities/camera_type.dart';
import '../widgets/ui_handler.dart';
import 'exposure_controller.dart';
import 'zoom_controller.dart';

///
class CamController extends ValueNotifier<CamValue> {
  ///
  CamController({
    required BuildContext context,
    PlaygroundController? playgroundController,
    ResolutionPreset? resolutionPreset,
    ImageFormatGroup? imageFormatGroup,
    Duration? videoDuration,
    bool? editAfterCapture,
  })  : _uiHandler = UIHandler(context),
        _context = context,
        _playgroundController =
            playgroundController ?? PlaygroundController(enableOverlay: false),
        super(
          CamValue(
            resolutionPreset: resolutionPreset ?? ResolutionPreset.medium,
            imageFormatGroup: imageFormatGroup ?? ImageFormatGroup.jpeg,
            videoDuration: videoDuration ?? const Duration(seconds: 10),
            editAfterCapture: editAfterCapture ?? true,
          ),
        ) {
    _zoomController = ZoomController(this);
    _exposureController = ExposureController(this, _uiHandler);
  }

  //
  final BuildContext _context;

  //
  final UIHandler _uiHandler;

  // Text view editing controller
  final PlaygroundController _playgroundController;

  // Value will be set after creating camera
  CameraController? _cameraController;

  // Zoom controller
  late final ZoomController _zoomController;

  // Exposure controller
  late final ExposureController _exposureController;

  @override
  void dispose() {
    _zoomController.dispose();
    _exposureController.dispose();
    _playgroundController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  ///
  bool get initialized => _cameraController?.value.isInitialized ?? false;

  /// Call this only when [initialized] is true
  CameraController? get cameraController => _cameraController;

  /// Camera playground controller i,e. text view
  PlaygroundController get playgroundController => _playgroundController;

  /// Camera zoom controller
  ZoomController get zoomController => _zoomController;

  /// Camera exposure controller
  ExposureController get exposureController => _exposureController;

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
    _cameraController = CameraController(
      description,
      value.resolutionPreset,
      enableAudio: value.enableAudio,
      imageFormatGroup: value.imageFormatGroup,
    );

    final controller = _cameraController!;

    // listen controller
    controller.addListener(() {
      if (controller.value.hasError) {
        final error = 'Camera error ${controller.value.errorDescription}';
        _uiHandler.showSnackBar(error);
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
        // ignore: unawaited_futures
        controller.setFlashMode(value.flashMode);
      }
      // ignore: unawaited_futures
      Future.wait([
        controller
            .getMinExposureOffset()
            .then(_exposureController.setMinExposure),
        controller
            .getMaxExposureOffset()
            .then(_exposureController.setMaxExposure),
        controller.getMaxZoomLevel().then(_zoomController.setMaxZoom),
        controller.getMinZoomLevel().then(_zoomController.setMinZoom),
      ]);
    } on CameraException catch (e) {
      _uiHandler.showExceptionSnackbar(e);
    } catch (e) {
      _uiHandler.showSnackBar(e.toString());
    }

    return controller;

    //
  }

  //
  void _finishTakingPicture(DrishyaEntity? drishyaEntity) {
    if (!value.editAfterCapture) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
    _uiHandler.pop<DrishyaEntity>(drishyaEntity);
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
      final controller = _cameraController!;

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

      value = value.copyWith(isTakingPicture: false);

      if (entity != null) {
        DrishyaEntity? drishyaEntity = entity.toDrishya.copyWith(
          pickedThumbData: data,
          pickedFile: file,
        );

        if (value.editAfterCapture) {
          final pc = PlaygroundController(
            background: PhotoBackground(entity: drishyaEntity),
          );
          final route = SlideTransitionPageRoute<DrishyaEntity?>(
            builder: Playground(controller: pc),
            begainHorizontal: true,
          );
          // ignore: use_build_context_synchronously
          drishyaEntity = await Navigator.of(_context).pushReplacement(route);
          pc.dispose();
        }
        _finishTakingPicture(drishyaEntity);
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
      final controller = _cameraController!;

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
      final controller = _cameraController!;
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
        final controller = _cameraController!;

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
        final controller = _cameraController!;

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

    final controller = _cameraController!;

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
class CamValue {
  ///
  CamValue({
    required this.resolutionPreset,
    required this.imageFormatGroup,
    required this.videoDuration,
    this.editAfterCapture = true,
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

  /// Image resolution. Default value is [ResolutionPreset.medium]
  final ResolutionPreset resolutionPreset;

  /// Image format group. Default value is [ImageFormatGroup.jpeg]
  final ImageFormatGroup imageFormatGroup;

  /// Video duration. Default value is 10 seconds
  final Duration videoDuration;

  ///
  final bool editAfterCapture;

  /// Current active camera description e,g. Front camera or back camera
  final CameraDescription? cameraDescription;

  /// Available camera description list
  final List<CameraDescription> cameras;

  /// Type of the active camera
  final CameraType cameraType;

  /// Audio will be enabled if value is true
  final bool enableAudio;

  /// Camera flash mode
  final FlashMode flashMode;

  /// Return true if camera is taking picture
  final bool isTakingPicture;

  /// Return true if camera is recording video
  final bool isRecordingVideo;

  /// Return true if video recording is in pause state
  final bool isRecordingPaused;

  /// Return true if playground is active
  final bool isPlaygroundActive;

  ///
  CamValue copyWith({
    CameraDescription? cameraDescription,
    List<CameraDescription>? cameras,
    CameraType? cameraType,
    bool? enableAudio,
    FlashMode? flashMode,
    bool? isTakingPicture,
    bool? isRecordingVideo,
    bool? isRecordingPaused,
    bool? isPlaygroundActive,
    bool? editAfterCapture,
  }) {
    return CamValue(
      resolutionPreset: resolutionPreset,
      imageFormatGroup: imageFormatGroup,
      videoDuration: videoDuration,
      cameraDescription: cameraDescription ?? this.cameraDescription,
      cameras: cameras ?? this.cameras,
      cameraType: cameraType ?? this.cameraType,
      enableAudio: enableAudio ?? this.enableAudio,
      flashMode: flashMode ?? this.flashMode,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
      isRecordingPaused: isRecordingPaused ?? this.isRecordingPaused,
      isPlaygroundActive: isPlaygroundActive ?? this.isPlaygroundActive,
      editAfterCapture: editAfterCapture ?? this.editAfterCapture,
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
