import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_builder.dart';
import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'controllers/cam_controller.dart';
import 'controllers/controller_notifier.dart';
import 'entities/camera_type.dart';
import 'widgets/cam_controller_provider.dart';
import 'widgets/camera_overlay.dart';
import 'widgets/raw_camera_view.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);
const Duration _defaultVideoDuration = Duration(seconds: 10);

///
class CameraView extends StatefulWidget {
  ///
  const CameraView({
    Key? key,
    this.videoDuration,
    this.resolutionPreset,
    this.imageFormatGroup,
  }) : super(key: key);

  ///
  /// Vide duration. Default is 10 seconds.
  ///
  final Duration? videoDuration;

  ///
  /// Camera resolution. Default to [ResolutionPreset.medium]
  ///
  final ResolutionPreset? resolutionPreset;

  ///
  /// Camera image format. Default to [ImageFormatGroup.jpeg]
  ///
  final ImageFormatGroup? imageFormatGroup;

  /// Camera view route name
  static const String name = 'CameraView';

  /// Open camera view for picking.
  static Future<DrishyaEntity?> pick(
    BuildContext context, {
    Duration? videoDuration,
    ResolutionPreset? resolutionPreset,
    ImageFormatGroup? imageFormatGroup,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: CameraView(
          videoDuration: videoDuration,
          resolutionPreset: resolutionPreset,
          imageFormatGroup: imageFormatGroup,
        ),
        transitionCurve: Curves.easeIn,
        transitionDuration: _kRouteDuration,
        reverseTransitionDuration: _kRouteDuration,
        settings: const RouteSettings(name: name),
      ),
    );
  }

  @override
  _CameraViewState createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final ControllerNotifier _controllerNotifier;
  late final PlaygroundController _playgroundController;
  late final CamController _camController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _controllerNotifier = ControllerNotifier();
    _camController = CamController(
      controllerNotifier: _controllerNotifier,
      context: context,
      imageFormatGroup: widget.imageFormatGroup,
      resolutionPreset: widget.resolutionPreset,
    );
    _playgroundController = PlaygroundController()
      ..addListener(_playgroundListener);
    Future<void>.delayed(_kRouteDuration, () {
      _hideSB();
      _camController.createCamera();
    });
  }

  void _playgroundListener() {
    final value = _playgroundController.value;
    final isPlaygroundActive =
        value.hasFocus || value.isEditing || value.hasStickers;
    _camController.update(isPlaygroundActive: isPlaygroundActive);
  }

  // Handle app life cycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _controllerNotifier.controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _showSB();
      _controllerNotifier.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _hideSB();
      _camController.createCamera();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    SystemChrome.restoreSystemUIOverlays();
  }

  @override
  void dispose() {
    _showSB();
    WidgetsBinding.instance?.removeObserver(this);
    _controllerNotifier.dispose();
    _camController.dispose();
    _playgroundController
      ..removeListener(_playgroundListener)
      ..dispose();
    super.dispose();
  }

  ///
  void _hideSB() {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  ///
  void _showSB() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  Future<bool> _onWillPop() async {
    _hideSB();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ValueListenableBuilder<ControllerValue>(
          valueListenable: _controllerNotifier,
          builder: (context, value, child) {
            if (_controllerNotifier.initialized) {
              return child!;
            }
            return const SizedBox();
          },
          child: CamControllerProvider(
            action: _camController,
            child: Stack(
              children: [
                // Camera type specific view
                CameraBuilder(
                  controller: _camController,
                  builder: (value, child) {
                    if (value.cameraType == CameraType.text) {
                      return Playground(controller: _playgroundController);
                    }
                    return RawCameraView(action: _camController);
                  },
                ),

                // Camera control overlay
                CameraOverlay(
                  controller: _camController,
                  playgroundCntroller: _playgroundController,
                  videoDuration: widget.videoDuration ?? _defaultVideoDuration,
                ),

                //
              ],
            ),
          ),
        ),
      ),
    );
  }
}
