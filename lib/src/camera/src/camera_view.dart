import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_builder.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_overlay.dart';
import 'package:drishya_picker/src/camera/src/widgets/raw_camera_view.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_permission_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);

///
class CameraView extends StatefulWidget {
  ///
  const CameraView({
    Key? key,
    this.controller,
    this.setting,
    this.editorSetting,
    this.photoEditorSetting,
  }) : super(key: key);

  /// Camera controller
  final CamController? controller;

  /// Settings related to the camera
  final CameraSetting? setting;

  /// Settings for text editor
  /// If setting is null default setting's will be used
  final EditorSetting? editorSetting;

  /// Setting for photo editing after taking picture,
  /// If this setting is null [editorSetting] will be used
  final EditorSetting? photoEditorSetting;

  /// Camera view route name
  static const String name = 'CameraView';

  /// Open camera view for picking.
  static Future<DrishyaEntity?> pick(
    BuildContext context, {

    /// Camera controller
    CamController? controller,

    /// Settings related to the camera
    CameraSetting? setting,

    /// Settings for text editor
    /// If setting is null default setting's will be used
    EditorSetting? editorSetting,

    /// Setting for photo editing after taking picture,
    /// If this setting is null [editorSetting] will be used
    EditorSetting? photoEditorSetting,
  }) async {
    return Navigator.of(context).push<DrishyaEntity>(
      SlideTransitionPageRoute(
        builder: CameraView(
          controller: controller,
          setting: setting,
          editorSetting: editorSetting,
          photoEditorSetting: photoEditorSetting,
        ),
        transitionCurve: Curves.easeIn,
        transitionDuration: _kRouteDuration,
        reverseTransitionDuration: _kRouteDuration,
        settings: const RouteSettings(name: name),
      ),
    );
  }

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late DrishyaEditingController _photoEditingController;
  late CamController _camController;

  @override
  void initState() {
    super.initState();
    UIHandler.hideStatusBar();
    WidgetsBinding.instance?.addObserver(this);
    _camController = (widget.controller ?? CamController())
      ..init(
        setting: widget.setting,
        editorSetting: widget.editorSetting,
        photoEditorSetting: widget.photoEditorSetting,
      );
    _photoEditingController = _camController.drishyaEditingController
      ..addListener(_photoEditingListener);
    Future<void>.delayed(_kRouteDuration, _camController.createCamera);
    // _camController.createCamera();
  }

  // Listen photo editing state
  void _photoEditingListener() {
    final value = _photoEditingController.value;
    final isPlaygroundActive =
        value.hasFocus || value.isEditing || value.hasStickers;
    _camController.update(isPlaygroundActive: isPlaygroundActive);
  }

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      UIHandler.hideStatusBar();
      _camController = widget.controller ?? CamController();
      _photoEditingController = _camController.drishyaEditingController
        ..addListener(_photoEditingListener);
      _camController.createCamera();
    }
  }

  // Handle app life cycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _camController.cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      UIHandler.showStatusBar();
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      UIHandler.hideStatusBar();
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
    UIHandler.showStatusBar();
    WidgetsBinding.instance?.removeObserver(this);
    _photoEditingController.removeListener(_photoEditingListener);
    if (widget.controller == null) {
      _camController.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    /// [CameraShutterButton] is also using [WillPopScope] to handle
    /// video recording stuff. So always return true from here so that
    /// it will also get this callback. Returning false from here will
    /// never trigger onWillPop callback in [CameraShutterButton]
    if (!_camController.value.isRecordingVideo) {
      await UIHandler.showStatusBar();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ValueListenableBuilder<CamValue>(
          valueListenable: _camController,
          builder: (context, value, child) {
            // Camera
            if (_camController.initialized) {
              return child!;
            }

            // Camera permission
            if (value.error != null &&
                value.error!.code == 'cameraPermission') {
              return Container(
                alignment: Alignment.center,
                child: GalleryPermissionView(
                  isCamera: true,
                  onRefresh: _camController.createCamera,
                ),
              );
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
                      return DrishyaEditor(
                        controller: _photoEditingController,
                        setting: _camController.editorSetting,
                        hideOverlay: true,
                      );
                    }
                    return RawCameraView(controller: _camController);
                  },
                ),

                // Camera control overlay
                CameraOverlay(controller: _camController),

                //
              ],
            ),
          ),
        ),
      ),
    );
  }
}
