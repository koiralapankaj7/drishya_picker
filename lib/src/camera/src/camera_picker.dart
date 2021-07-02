import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import 'controllers/action_notifier.dart';
import 'controllers/controller_notifier.dart';
import 'entities/camera_type.dart';
import 'widgets/action_notifier_provider.dart';
import 'widgets/camera_overlay.dart';
import 'widgets/camera_view.dart';
import 'widgets/controller_builder.dart';

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
  late final PlaygroundController _playgroundController;
  late final ActionNotifier _actionNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _controllerNotifier = ControllerNotifier();
    _actionNotifier = ActionNotifier(
      controllerNotifier: _controllerNotifier,
      context: context,
    );
    _playgroundController = PlaygroundController()
      ..addListener(_playgroundListener);
    Future<void>.delayed(_kRouteDuration, _actionNotifier.createCamera);
  }

  void _playgroundListener() {
    final value = _playgroundController.value;
    final hide = value.hasFocus || value.isEditing || value.hasStickers;
    _actionNotifier.value = _actionNotifier.value.copyWith(
      hideCameraChanger: hide,
    );
    if (value.hasFocus || value.isEditing || value.hasStickers) {}
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
      _actionNotifier.createCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controllerNotifier.dispose();
    _actionNotifier.dispose();
    _playgroundController
      ..removeListener(_playgroundListener)
      ..dispose();
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
            return ActionNotifierProvider(
              action: _actionNotifier,
              child: ValueListenableBuilder<ActionValue>(
                valueListenable: _actionNotifier,
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      // Camera type specific view

                      Builder(
                        builder: (context) {
                          switch (_actionNotifier.value.cameraType) {
                            case CameraType.text:
                              return Playground(
                                controller: _playgroundController,
                              );
                            default:
                              return CameraView(action: _actionNotifier);
                          }
                        },
                      ),

                      // Camera control overlay
                      CameraOverlay(
                        action: _actionNotifier,
                        playgroundCntroller: _playgroundController,
                        videoDuration: const Duration(seconds: 10),
                      ),

                      //
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
