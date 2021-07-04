import 'dart:async';
import 'dart:ui';

import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_builder.dart';
import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import 'controllers/cam_controller.dart';
import 'controllers/controller_notifier.dart';
import 'entities/camera_type.dart';
import 'widgets/cam_controller_provider.dart';
import 'widgets/camera_overlay.dart';
import 'widgets/camera_view.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);
const Duration _defaultVideoDuration = Duration(seconds: 10);

///
class CameraPicker extends StatefulWidget {
  ///
  const CameraPicker({
    Key? key,
    this.videoDuration,
  }) : super(key: key);

  ///
  final Duration? videoDuration;

  ///
  static const String name = 'CameraView';

  ///
  static Future<AssetEntity?> pick(
    BuildContext context, {
    Duration? videoDuration,
  }) async {
    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<AssetEntity>(
      SlidePageTransitionBuilder<AssetEntity>(
        builder: CameraPicker(videoDuration: videoDuration),
        transitionCurve: Curves.easeIn,
        transitionDuration: _kRouteDuration,
        reverseTransitionDuration: _kRouteDuration,
      ),
    );
    return result;
  }

  @override
  _CameraPickerState createState() {
    return _CameraPickerState();
  }
}

class _CameraPickerState extends State<CameraPicker>
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
      // _showSB();
      _controllerNotifier.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // _hideSB();
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
    _showSB();
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
                    return CameraView(action: _camController);
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
