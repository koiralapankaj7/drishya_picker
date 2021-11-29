// ignore_for_file: always_use_package_imports

import 'dart:async';
import 'dart:ui';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_builder.dart';
import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'controllers/cam_controller.dart';
import 'entities/camera_type.dart';
import 'widgets/cam_controller_provider.dart';
import 'widgets/camera_overlay.dart';
import 'widgets/raw_camera_view.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);

///
class CameraView extends StatefulWidget {
  ///
  const CameraView({
    Key? key,
    // this.videoDuration,
    // this.resolutionPreset,
    // this.imageFormatGroup,
    this.controller,
  }) : super(key: key);

  // ///
  // /// Vide duration. Default is 10 seconds.
  // ///
  // final Duration? videoDuration;

  // ///
  // /// Camera resolution. Default to [ResolutionPreset.medium]
  // ///
  // final ResolutionPreset? resolutionPreset;

  // ///
  // /// Camera image format. Default to [ImageFormatGroup.jpeg]
  // ///
  // final ImageFormatGroup? imageFormatGroup;

  /// Camera controller
  final CamController? controller;

  /// Camera view route name
  static const String name = 'CameraView';

  /// Open camera view for picking.
  static Future<DrishyaEntity?> pick(
    BuildContext context, {
    // Duration? videoDuration,
    // ResolutionPreset? resolutionPreset,
    // ImageFormatGroup? imageFormatGroup,
    CamController? controller,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: CameraView(
          controller: controller,
          // videoDuration: videoDuration,
          // resolutionPreset: resolutionPreset,
          // imageFormatGroup: imageFormatGroup,
        ),
        transitionCurve: Curves.easeIn,
        transitionDuration: _kRouteDuration,
        reverseTransitionDuration: _kRouteDuration,
        settings: const RouteSettings(name: name),
      ),
    );
  }

  @override
  State<CameraView> createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final PlaygroundController _playgroundController;
  late final CamController _camController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _camController = widget.controller ?? CamController(context: context);
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

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _camController = widget.controller ?? CamController(context: context);
      _playgroundController = PlaygroundController()
        ..addListener(_playgroundListener);
      Future<void>.delayed(_kRouteDuration, () {
        _hideSB();
        _camController.createCamera();
      });
    }
  }

  // Handle app life cycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _camController.controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _showSB();
      cameraController.dispose();
      // _controllerNotifier.controller?.dispose();
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
    if (widget.controller == null) {
      _camController.dispose();
    }
    // _controllerNotifier.dispose();
    _playgroundController
      ..removeListener(_playgroundListener)
      ..dispose();
    super.dispose();
  }

  ///
  void _hideSB() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  ///
  void _showSB() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
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
        body: ValueListenableBuilder<ActionValue>(
          valueListenable: _camController,
          builder: (context, value, child) {
            if (_camController.initialized) {
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
