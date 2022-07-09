import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_builder.dart';
import 'package:drishya_picker/src/camera/src/widgets/camera_overlay.dart';
import 'package:drishya_picker/src/camera/src/widgets/raw_camera_view.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_builder.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_permission_view.dart';
import 'package:flutter/cupertino.dart';
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
  static Future<List<DrishyaEntity>?> pick(
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

    ///
    /// Route setting
    CustomRouteSetting? routeSetting,
  }) async {
    return Navigator.of(context).push<List<DrishyaEntity>>(
      SlideTransitionPageRoute(
        builder: CameraView(
          controller: controller,
          setting: setting,
          editorSetting: editorSetting,
          photoEditorSetting: photoEditorSetting,
        ),
        setting: routeSetting ??
            const CustomRouteSetting(
              transitionDuration: _kRouteDuration,
              reverseTransitionDuration: _kRouteDuration,
              settings: RouteSettings(name: name),
            ),
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
    WidgetsBinding.instance.addObserver(this);
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
    if (oldWidget.controller != widget.controller &&
        oldWidget.setting != widget.setting &&
        oldWidget.editorSetting != widget.editorSetting &&
        oldWidget.photoEditorSetting != widget.photoEditorSetting) {
      UIHandler.hideStatusBar();
      _camController = (widget.controller ?? CamController())
        ..init(
          setting: widget.setting,
          editorSetting: widget.editorSetting,
          photoEditorSetting: widget.photoEditorSetting,
        );
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
      // UIHandler.showStatusBar();
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
    // UIHandler.showStatusBar();
    WidgetsBinding.instance.removeObserver(this);
    _photoEditingController.removeListener(_photoEditingListener);
    if (widget.controller == null) {
      _camController.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_camController.pageController.page == 0.0) {
      _camController.openCamera();
      return false;
    }

    /// [CameraShutterButton] is also using [WillPopScope] to handle
    /// video recording stuff. So always return true from here so that
    /// it will also get this callback. Returning false from here will
    /// never trigger onWillPop callback in [CameraShutterButton]
    // if (!_camController.value.isRecordingVideo) {
    //   await UIHandler.showStatusBar();
    // }
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
              return CamControllerProvider(
                action: _camController,
                child: PageView(
                  controller: _camController.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [_GalleryView(), _CameraView()],
                ),
              );
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
            child: PageView(
              controller: _camController.pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [_GalleryView(), _CameraView()],
            ),
          ),
        ),
      ),
    );
  }
}

///
class _GalleryView extends StatelessWidget {
  const _GalleryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.camController!;

    if (!controller.setting.enableGallery) {
      return const SizedBox();
    }

    return Stack(
      children: [
        GalleryView(
          controller: controller.galleryController,
          setting: const GallerySetting(
            selectionMode: SelectionMode.actionBased,
            albumTitle: 'Gallery',
            enableCamera: false,
            panelSetting: PanelSetting(thumbHandlerHeight: 0),
          ),
        ),

        // Camera switch button
        GalleryBuilder(
          controller: controller.galleryController,
          builder: (value, child) {
            if (value.selectedEntities.isNotEmpty) {
              return const SizedBox();
            }
            return child!;
          },
          child: Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: controller.openCamera,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  CupertinoIcons.camera_circle_fill,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraView extends StatelessWidget {
  const _CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = context.camController!;

    return Stack(
      children: [
        // Camera type specific view
        CameraBuilder(
          controller: controller,
          builder: (value, child) {
            if (value.cameraType == CameraType.text) {
              return DrishyaEditor(
                controller: controller.drishyaEditingController,
                setting: controller.editorSetting,
                hideOverlay: true,
              );
            }
            return RawCameraView(controller: controller);
          },
        ),

        // Camera control overlay
        CameraOverlay(controller: controller),

        //
      ],
    );
  }
}
