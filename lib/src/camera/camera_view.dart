import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import 'c_preview.dart';
import 'camera_controls.dart';
import 'text_view.dart';
import 'widgets/camera_type.dart';

///
class CameraDetail {
  ///
  CameraDetail({
    this.cameras = const [],
    this.controller,
    this.isReady = false,
  });

  ///
  final List<CameraDescription> cameras;

  ///
  final CameraController? controller;

  ///
  final bool isReady;

  ///
  bool get initialized => controller?.value.isInitialized ?? false;
}

///
class CameraView extends StatefulWidget {
  ///
  const CameraView({
    Key? key,
  }) : super(key: key);

  ///
  static const String name = 'CameraView';

  @override
  _CameraViewState createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final ValueNotifier<CameraType> cameraTypeNotifier;
  late final ValueNotifier<CameraDetail> cameraNotifier;
  // Update this value on AppLifecycleState.inactive
  // Use this description on AppLifecycleState.resumed
  CameraDescription? _cameraDescription;
  var enableAudio = true;
  var _flashMode = FlashMode.off;
  var _minAvailableZoom = 1.0;
  var _maxAvailableZoom = 1.0;
  var _currentScale = 1.0;
  var _baseScale = 1.0;
  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  // var _minAvailableExposureOffset = 0.0;
  // var _maxAvailableExposureOffset = 0.0;
  // var _currentExposureOffset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _hideSB();
    cameraNotifier = ValueNotifier(CameraDetail());
    cameraTypeNotifier = ValueNotifier(CameraType.normal);
    _createNewCamera();
  }

  // Handle app life cycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (!cameraNotifier.value.initialized) return;

    if (state == AppLifecycleState.inactive) {
      final controller = cameraNotifier.value.controller!;
      _cameraDescription = controller.description;
      _flashMode = controller.value.flashMode;
      _showSB();
      controller.dispose();
    }
    if (state == AppLifecycleState.resumed) {
      _hideSB();
      cameraNotifier.value = CameraDetail(
        cameras: cameraNotifier.value.cameras,
      );
      _createNewCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _showSB();
    cameraTypeNotifier.dispose();
    cameraNotifier.value.controller?.dispose();
    cameraNotifier.dispose();
    super.dispose();
  }

  // Hide status bar
  void _hideSB() {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  // Show status bar
  void _showSB() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  // Snackbar for error
  void _showErrorSnackbar(CameraException e) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
  }

  // Snackbar for normal mesages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Create new camera
  Future<void> _createNewCamera({
    CameraDescription? cameraDescription,
  }) async {
    late final CameraDescription description;
    List<CameraDescription>? cameras;

    if (cameraDescription != null) {
      description = cameraDescription;
    } else if (_cameraDescription != null) {
      description = _cameraDescription!;
    } else {
      cameras = await availableCameras();
      description = cameras[0];
    }

    final cameraController = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    if (cameraController.value.hasError) {
      _showSnackBar(
        'Camera error ${cameraController.value.errorDescription}',
      );
    }

    try {
      await cameraController.initialize();
      if (cameraController.description.lensDirection ==
          CameraLensDirection.back) {
        await cameraController.setFlashMode(_flashMode);
      }
      // await cameraController.setFlashMode(FlashMode.off);
      await Future.wait([
        cameraController.getMinExposureOffset(),
        // .then((value) => _minAvailableExposureOffset = value),
        cameraController.getMaxExposureOffset(),
        // .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      _showErrorSnackbar(e);
    }
    cameraNotifier.value = CameraDetail(
      cameras: cameras ?? cameraNotifier.value.cameras,
      controller: cameraController,
      isReady: true,
    );

    //
  }

  // Take picture
  void _takePicture() async {
    if (!cameraNotifier.value.initialized) {
      _showSnackBar('Couldn\'t find the camera!');
      return null;
    }

    final ctrl = cameraNotifier.value.controller!;

    if (ctrl.value.isTakingPicture) {
      _showSnackBar('Capturing is currently running..');
      return null;
    }

    try {
      final file = await ctrl.takePicture();
      final data = await file.readAsBytes();
      final entity = await PhotoManager.editor.saveImage(data);
      if (entity != null) {
        Navigator.of(context).pop(entity);
      } else {
        _showSnackBar('Something went wrong! Please try again');
      }
    } on CameraException catch (e) {
      _showSnackBar('Exception occured while capturing picture : $e');
      return null;
    }
  }

  // Start video recording
  Future<void> _startVideoRecording() async {
    if (!cameraNotifier.value.initialized) {
      _showSnackBar('Couldn\'t find the camera!');
      return;
    }

    final controller = cameraNotifier.value.controller!;

    if (controller.value.isRecordingVideo) {
      _showSnackBar('Recording is already started!');
      return;
    }

    try {
      await controller.startVideoRecording();
    } on CameraException catch (e) {
      _showErrorSnackbar(e);
      return;
    }
  }

  // Stop/Complete video recording
  void _stopVideoRecording() async {
    final controller = cameraNotifier.value.controller;

    if (cameraNotifier.value.initialized &&
        controller!.value.isRecordingVideo) {
      try {
        final xfile = await controller.stopVideoRecording();
        final file = File(xfile.path);
        final entity = await PhotoManager.editor.saveVideo(file);
        if (entity != null) {
          Navigator.of(context).pop(entity);
        } else {
          _showSnackBar('Something went wrong! Please try again');
        }
      } on CameraException catch (e) {
        _showErrorSnackbar(e);
        rethrow;
      }
    } else {
      _showSnackBar('Couldn\'t stop the video!');
      return;
    }
  }

  // Switch camera direction
  void _switchCameraDirection(CameraLensDirection direction) async {
    try {
      final description = cameraNotifier.value.cameras.firstWhere(
        (element) => element.lensDirection == direction,
      );
      await _createNewCamera(cameraDescription: description);
    } on CameraException catch (e) {
      _showErrorSnackbar(e);
    }
  }

  /// Set flash mode
  void _setFlashMode() async {
    final controller = cameraNotifier.value.controller;
    if (controller == null) return;

    try {
      final mode = controller.value.flashMode == FlashMode.off
          ? FlashMode.always
          : FlashMode.off;
      await controller.setFlashMode(mode);
    } on CameraException catch (e) {
      _showErrorSnackbar(e);
      rethrow;
    }
  }

  // Zoom start
  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  // Zoom update
  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (cameraNotifier.value.controller == null || _pointers != 2) {
      return;
    }
    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    await cameraNotifier.value.controller!.setZoomLevel(_currentScale);
  }

  // Set exposure and focus point on the screen
  void _setExposureAndFocus(
    TapDownDetails details,
    BoxConstraints constraints,
  ) {
    final controller = cameraNotifier.value.controller;
    if (controller == null) return;
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller
      ..setExposurePoint(offset)
      ..setFocusPoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ValueListenableBuilder<CameraDetail>(
        valueListenable: cameraNotifier,
        builder: (context, detail, child) {
          if (detail.isReady) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Camera view
                CameraTypeBuilder(
                  notifier: cameraTypeNotifier,
                  builder: (context, type, child) {
                    if (type == CameraType.text) return const TextView();

                    return CPreview(
                      controller: detail.controller!,
                      onPointerDown: (_) => _pointers++,
                      onPointerUp: (_) => _pointers--,
                      onScaleStart: _handleScaleStart,
                      onScaleUpdate: _handleScaleUpdate,
                      onTapDown: _setExposureAndFocus,
                    );
                  },
                ),

                // Camera control
                CameraAction(
                  controller: detail.controller!,
                  cameraTypeNotifier: cameraTypeNotifier,
                  onFlashChange: _setFlashMode,
                  onCameraRotate: _switchCameraDirection,
                  onImageCapture: _takePicture,
                  videoDuration: const Duration(seconds: 10),
                  onRecordingStart: _startVideoRecording,
                  onRecordingStop: _stopVideoRecording,
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // // Pause video recording
  // void _pauseVideoRecording() async {
  //   final controller = cameraNotifier.value.controller;

  //   if (cameraNotifier.value.initialized &&
  //       controller!.value.isRecordingVideo) {
  //     try {
  //       await controller.pauseVideoRecording();
  //     } on CameraException catch (e) {
  //       _showErrorSnackbar(e);
  //       rethrow;
  //     }
  //   } else {
  //     _showSnackBar('Couldn\'t paused the video!');
  //     return;
  //   }
  // }

  // // Resume video recording
  // void _resumeVideoRecording() async {
  //   final controller = cameraNotifier.value.controller;

  //   if (cameraNotifier.value.initialized &&
  //       controller!.value.isRecordingPaused) {
  //     try {
  //       await controller.resumeVideoRecording();
  //     } on CameraException catch (e) {
  //       _showErrorSnackbar(e);
  //       rethrow;
  //     }
  //   } else {
  //     _showSnackBar('Couldn\'t resume the video!');
  //     return;
  //   }
  // }

  // // Set exposure mode
  // Future<void> _setExposureMode(ExposureMode mode) async {
  //   final controller = cameraNotifier.value.controller;
  //   if (controller == null) return;
  //   try {
  //     await controller.setExposureMode(mode);
  //   } on CameraException catch (e) {
  //     _showErrorSnackbar(e);
  //     rethrow;
  //   }
  // }

  // // Lock unlock capture orientation i,e. Portrait and Landscape
  // void _lockUnlockCaptureOrientation() async {
  //   final controller = cameraNotifier.value.controller;
  //   if (controller != null) {
  //     if (controller.value.isCaptureOrientationLocked) {
  //       await controller.unlockCaptureOrientation();
  //       _showSnackBar('Capture orientation unlocked');
  //     } else {
  //       await controller.lockCaptureOrientation();
  //       _showSnackBar(
  //         '''Capture orientation locked to ${controller.value.
  // lockedCaptureOrientation.toString().split('.').last}''',
  //       );
  //     }
  //   }
  // }

  // // Set focus mode
  // Future<void> _setFocusMode(FocusMode mode) async {
  //   final controller = cameraNotifier.value.controller;
  //   if (controller == null) return;
  //   try {
  //     await controller.setFocusMode(mode);
  //   } on CameraException catch (e) {
  //     _showErrorSnackbar(e);
  //     rethrow;
  //   }
  // }

//
}
