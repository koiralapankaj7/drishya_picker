// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/camera/text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_manager/photo_manager.dart';

import 'camera_controls.dart';

// part 'camera_controls.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    Key? key,
  }) : super(key: key);

  static const String name = 'CameraView';

  @override
  _CameraViewState createState() {
    return _CameraViewState();
  }
}

void logError(String code, String? message) {
  if (message != null) {
    log('Error: $code\nError Message: $message');
  } else {
    log('Error: $code');
  }
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  // VideoPlayerController? videoController;
  bool enableAudio = true;
  List<CameraDescription> cameras = <CameraDescription>[];
  late final InputTypeController inputTypeController;
  AssetEntity? selectedItem;

  VoidCallback? videoPlayerListener;

  var _minAvailableExposureOffset = 0.0;
  var _maxAvailableExposureOffset = 0.0;
  final _currentExposureOffset = 0.0;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    inputTypeController = InputTypeController();
    _initCamera();
  }

  void _initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
      controller = CameraController(
        cameras[0],
        ResolutionPreset.veryHigh,
      );
      await controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }

  bool get _canProcess => controller?.value.isInitialized ?? false;

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = controller;
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _switchCameraDirection(cameraController.description.lensDirection);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: _canProcess
          ? Stack(
              children: [
                // Camera view
                InputTypeBuilder(
                  controller: inputTypeController,
                  builder: (context, type, child) {
                    if (type == InputType.text) return TextView();

                    if (_canProcess) {
                      return _CameraPreview(
                        controller: controller!,
                        onPointerDown: (_) => _pointers++,
                        onPointerUp: (_) => _pointers--,
                        onScaleStart: _handleScaleStart,
                        onScaleUpdate: _handleScaleUpdate,
                        onTapDown: _onViewFinderTap,
                      );
                    }

                    return const SizedBox();
                  },
                ),

                // Camera control
                if (controller != null)
                  CameraAction(
                    inputTypeController: inputTypeController,
                    controller: controller!,
                    onFalshIconPressed: _setFlashMode,
                    onCameraRotatePressed: _switchCameraDirection,
                    onCaptureImagePressed: _onTakePictureButtonPressed,
                    onInputTypeChanged: (type) {},
                    onPopRequest: () {},
                    onPreviewMediaPressed: () {},
                  ),
              ],
            )
          : Container(),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) return;
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  // Setup camera controller
  void _switchCameraDirection(CameraLensDirection direction) async {
    try {
      if (controller != null) {
        // todo disposing causing error
        // await controller!.dispose();
      }

      final cameraDescription = cameras
          .firstWhere((desc) => desc.lensDirection == direction, orElse: () {
        return CameraDescription(
          name: 'name',
          lensDirection: direction,
          sensorOrientation: 0,
        );
      });

      final cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.veryHigh,
        enableAudio: enableAudio,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController.initialize();
      controller = cameraController;

      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      // If the controller is updated then update the UI.
      cameraController.addListener(() {
        // if (mounted) setState(() {});
        if (cameraController.value.hasError) {
          showInSnackBar(
              'Camera error ${cameraController.value.errorDescription}');
        }
      });
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  ///
  void _onTakePictureButtonPressed() {
    _takePicture().then((AssetEntity? entity) {
      if (mounted) {
        // setState(() {
        //   videoController?.dispose();
        //   videoController = null;
        // });

        if (entity != null) {
          Navigator.of(context).pop(entity);
        }
        // showInSnackBar('Picture saved to ${entity.relativePath}');
      }
    });
  }

  /// Set flash mode
  Future<void> _setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }
    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  //
  Future<AssetEntity?> _takePicture() async {
    if (!_canProcess) {
      log('Error: No camera selected..');
      return null;
    }

    final ctrl = controller!;

    if (ctrl.value.isTakingPicture) {
      log('Capturing is currently running..');
      return null;
    }

    try {
      final file = await ctrl.takePicture();
      final data = await file.readAsBytes();
      final entity = await PhotoManager.editor.saveImage(data);
      return entity;
    } on CameraException catch (e) {
      log('Exception occured while capturing picture : $e');
      return null;
    }
  }

  ///
  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _onTakeImgButtonPressed() {
    // cameraController != null &&
    //         cameraController.value.isInitialized &&
    //         !cameraController.value.isRecordingVideo
    //     ? onTakePictureButtonPressed
    //     : null;
  }

  void _onRecordVideoButtonPressed() {
    // cameraController != null &&
    //               cameraController.value.isInitialized &&
    //               !cameraController.value.isRecordingVideo
    //           ? onVideoRecordButtonPressed
    //           : null,
  }

  void _onPauseResumeButtonPressed() {
    // cameraController != null &&
    //               cameraController.value.isInitialized &&
    //               cameraController.value.isRecordingVideo
    //           ? (cameraController.value.isRecordingPaused)
    //               ? onResumeButtonPressed
    //               : onPauseButtonPressed
    //           : null,
  }

  void _onStopRecordButtonPressed() {
    // cameraController != null &&
    //               cameraController.value.isInitialized &&
    //               cameraController.value.isRecordingVideo
    //           ? onStopButtonPressed
    //           : null,
  }

  void _onAudioModeButtonPressed() {
    // enableAudio = !enableAudio;
    // if (controller != null) {
    //   _onNewCameraSelected(controller!.description.lensDirection);
    // }
  }

  void _onCaptureOrientationLockButtonPressed() async {
    // if (controller != null) {
    //   final CameraController cameraController = controller!;
    //   if (cameraController.value.isCaptureOrientationLocked) {
    //     await cameraController.unlockCaptureOrientation();
    //     showInSnackBar('Capture orientation unlocked');
    //   } else {
    //     await cameraController.lockCaptureOrientation();
    //     showInSnackBar(
    //         'Capture orientation locked to ${cameraController.value.
    // lockedCaptureOrientation.toString().split('.').last}');
    //   }
    // }
  }

  void _onSetExposureModeButtonPressed(ExposureMode mode) {
    // setExposureMode(mode).then((_) {
    //   if (mounted) setState(() {});
    //   showInSnackBar('Exposure mode set to ${mode.toString()
    // .split('.').last}');
    // });
  }

  void _onSetFocusModeButtonPressed(FocusMode mode) {
    // _setFocusMode(mode).then((_) {
    //   if (mounted) setState(() {});
    //   showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    // });
  }

  void _onVideoRecordButtonPressed() {
    // _startVideoRecording().then((_) {
    //   if (mounted) setState(() {});
    // });
  }

  void _onStopButtonPressed() {
    // _stopVideoRecording().then((file) {
    //   if (mounted) setState(() {});
    //   if (file != null) {
    //     showInSnackBar('Video recorded to ${file.path}');
    //     // videoFile = file;
    //     _startVideoPlayer();
    //   }
    // });
  }

  void _onPauseButtonPressed() {
    // _pauseVideoRecording().then((_) {
    //   if (mounted) setState(() {});
    //   showInSnackBar('Video recording paused');
    // });
  }

  void _onResumeButtonPressed() {
    // _resumeVideoRecording().then((_) {
    //   if (mounted) setState(() {});
    //   showInSnackBar('Video recording resumed');
    // });
  }

  Future<void> _setExposureOffset(double offset) async {
    // if (controller == null) {
    //   return;
    // }

    // setState(() {
    //   _currentExposureOffset = offset;
    // });
    // try {
    //   offset = await controller!.setExposureOffset(offset);
    // } on CameraException catch (e) {
    //   _showCameraException(e);
    //   rethrow;
    // }
  }

  Future<void> _startVideoRecording() async {
    // final CameraController? cameraController = controller;

    // if (cameraController == null || !cameraController.value.isInitialized) {
    //   showInSnackBar('Error: select a camera first.');
    //   return;
    // }

    // if (cameraController.value.isRecordingVideo) {
    //   // A recording is already started, do nothing.
    //   return;
    // }

    // try {
    //   await cameraController.startVideoRecording();
    // } on CameraException catch (e) {
    //   _showCameraException(e);
    //   return;
    // }
  }

  Future<XFile?> _stopVideoRecording() async {
    // final CameraController? cameraController = controller;

    // if (cameraController == null || !cameraController.value.
    //isRecordingVideo) {
    //   return null;
    // }

    // try {
    //   return cameraController.stopVideoRecording();
    // } on CameraException catch (e) {
    //   _showCameraException(e);
    //   return null;
    // }
  }

  Future<void> _pauseVideoRecording() async {
    // final CameraController? cameraController = controller;

    // if (cameraController == null || !cameraController.value
    //.isRecordingVideo) {
    //   return null;
    // }

    // try {
    //   await cameraController.pauseVideoRecording();
    // } on CameraException catch (e) {
    //   _showCameraException(e);
    //   rethrow;
    // }
  }

  Future<void> _resumeVideoRecording() async {
    // final CameraController? cameraController = controller;

    // if (cameraController == null || !cameraController.value.
    //isRecordingVideo) {
    //   return null;
    // }

    // try {
    //   await cameraController.resumeVideoRecording();
    // } on CameraException catch (e) {
    //   _showCameraException(e);
    //   rethrow;
    // }
  }

  Future<void> _setFocusMode(FocusMode mode) async {
    // if (controller == null) {
    //   return;
    // }

    // try {
    //   await controller!.setFocusMode(mode);
    // } on CameraException catch (e) {
    //   _showCameraException(e);
    //   rethrow;
    // }
  }

  Future<void> _startVideoPlayer() async {
    // if (videoFile == null) {
    //   return;
    // }

    // final VideoPlayerController vController =
    //     VideoPlayerController.file(File(videoFile!.path));
    // videoPlayerListener = () {
    //   if (videoController != null && videoController!.value.size != null) {
    //     // Refreshing the state to update video player with the correct ratio.
    //     if (mounted) setState(() {});
    //     videoController!.removeListener(videoPlayerListener!);
    //   }
    // };
    // vController.addListener(videoPlayerListener!);
    // await vController.setLooping(true);
    // await vController.initialize();
    // await videoController?.dispose();
    // if (mounted) {
    //   setState(() {
    //     imageFile = null;
    //     videoController = vController;
    //   });
    // }
    // await vController.play();
  }

  /// Display the preview from the camera (or a message if
  /// the preview is not available).
  // Widget _cameraPreviewWidget() {
  //   final CameraController? cameraController = controller;

  //   if (cameraController == null || !cameraController.value.isInitialized) {
  //     return const Text(
  //       'Tap a camera',
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 24.0,
  //         fontWeight: FontWeight.w900,
  //       ),
  //     );
  //   } else {
  //     return Listener(
  //       onPointerDown: (_) => _pointers++,
  //       onPointerUp: (_) => _pointers--,
  //       child: CameraPreview(
  //         controller!,
  //         child: LayoutBuilder(
  //             builder: (BuildContext context, BoxConstraints constraints) {
  //           return GestureDetector(
  //             behavior: HitTestBehavior.opaque,
  //             onScaleStart: _handleScaleStart,
  //             onScaleUpdate: _handleScaleUpdate,
  //             onTapDown: (details) => _onViewFinderTap(details, constraints),
  //           );
  //         }),
  //       ),
  //     );
  //   }
  // }

//
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({
    Key? key,
    required this.controller,
    this.onPointerDown,
    this.onPointerUp,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onTapDown,
  }) : super(key: key);

  final CameraController controller;
  final void Function(PointerDownEvent event)? onPointerDown;
  final void Function(PointerUpEvent event)? onPointerUp;
  final void Function(ScaleStartDetails detail)? onScaleStart;
  final void Function(ScaleUpdateDetails detail)? onScaleUpdate;
  final void Function(TapDownDetails detail, BoxConstraints constraints)?
      onTapDown;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = 1 / (controller.value.aspectRatio * size.aspectRatio);

    return ClipRect(
      clipper: _Clipper(size),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: Listener(
          onPointerDown: onPointerDown,
          onPointerUp: onPointerUp,
          child: CameraPreview(
            controller,
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: onScaleStart,
                    onScaleUpdate: onScaleUpdate,
                    onTapDown: (details) =>
                        onTapDown?.call(details, constraints),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  const _Clipper(this.size);

  final Size size;

  @override
  Rect getClip(Size s) => Rect.fromLTWH(0, 0, size.width, size.height);

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
