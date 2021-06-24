import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:drishya_picker/src/camera/src/camera_ui/builders/action_detector.dart';
import 'package:drishya_picker/src/widgets/slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import 'camera_ui/builders/camera_action_provider.dart';
import 'camera_ui/builders/controller_builder.dart';
import 'camera_ui/camera_view.dart';
import 'camera_ui/control_view.dart';
import 'camera_ui/text_view.dart';
import 'controllers/camera_action.dart';
import 'controllers/controller_notifier.dart';
import 'entities/camera_type.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);

///
class CameraPicker extends StatefulWidget {
  ///
  const CameraPicker({
    Key? key,
  }) : super(key: key);

  ///
  static const String name = 'CameraView';

  ///
  static Future<AssetEntity?> pick(
    BuildContext context, {
    bool enableRecording = false,
    bool onlyEnableRecording = false,
    bool enableAudio = true,
    bool enableSetExposure = true,
    bool enableExposureControlOnPoint = true,
    bool enablePinchToZoom = true,
    bool shouldDeletePreviewFile = false,
    bool shouldLockPortrait = true,
    Duration maximumRecordingDuration = const Duration(seconds: 15),
    ThemeData? theme,
    int cameraQuarterTurns = 0,
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
    Widget Function(CameraValue)? foregroundBuilder,
  }) async {
    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<AssetEntity>(
      SlidePageTransitionBuilder<AssetEntity>(
        builder: const CameraPicker(),
        transitionCurve: Curves.easeIn,
        transitionDuration: _kRouteDuration,
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
  late final CameraAction _cameraAction;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _controllerNotifier = ControllerNotifier();
    _cameraAction = CameraAction(
      controllerNotifier: _controllerNotifier,
      context: context,
    );
    Future<void>.delayed(_kRouteDuration, _cameraAction.createCamera);
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
      _controllerNotifier.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _cameraAction.createCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controllerNotifier.dispose();
    _cameraAction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ControllerBuilder(
          controllerNotifier: _controllerNotifier,
          builder: (controller) {
            return CameraActionProvider(
              action: _cameraAction,
              child: Stack(
                children: [
                  // Camera type specific view

                  ActionBuilder(
                    builder: (action, value, child) {
                      // return AnimatedCrossFade(
                      //   firstChild: const TextView(),
                      //   secondChild: CameraView(action: action),
                      //   crossFadeState: value.cameraType == CameraType.text
                      //       ? CrossFadeState.showFirst
                      //       : CrossFadeState.showSecond,
                      //   duration: const Duration(milliseconds: 400),
                      // );

                      switch (_cameraAction.value.cameraType) {
                        case CameraType.text:
                          return const TextView();
                        default:
                          return CameraView(action: action);
                      }
                    },
                  ),

                  // Camera control view
                  const ControlView(videoDuration: Duration(seconds: 10)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
