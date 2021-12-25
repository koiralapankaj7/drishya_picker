import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

///
/// Gallery controller
class GalleryController extends ValueNotifier<GalleryValue> {
  ///
  /// Gallery controller constructor
  GalleryController({
    /// Gallery slidable panel setting
    PanelSetting? panelSetting,

    /// Gallery setting
    GallerySetting? setting,

    /// Gallery photo editor setting
    EditorSetting? galleryPhotoEditorSetting,

    /// Camera setting
    CameraSetting? cameraSetting,

    /// Camera text editor setting
    EditorSetting? cameraTextEditorSetting,

    /// Camera photo editor setting
    EditorSetting? cameraPhotoEditorSetting,
  })  : panelSetting = panelSetting ?? const PanelSetting(),
        setting = setting ?? const GallerySetting(),
        _editorSetting = galleryPhotoEditorSetting ?? const EditorSetting(),
        _cameraSetting = cameraSetting,
        _cameraPhotoEditorSetting = cameraPhotoEditorSetting,
        _cameraTextEditorSetting = cameraTextEditorSetting,
        panelKey = GlobalKey(),
        _panelController = PanelController(),
        _albumVisibility = ValueNotifier(false),
        super(const GalleryValue());

  /// Slidable gallery key
  final GlobalKey panelKey;

  /// Panel setting
  final PanelSetting panelSetting;

  /// Gallery setting
  final GallerySetting setting;

  /// Editor setting
  final EditorSetting _editorSetting;

  /// Panel controller
  final PanelController _panelController;

  /// Recent entities notifier
  final ValueNotifier<bool> _albumVisibility;

  // Camera controller
  final CameraSetting? _cameraSetting;

  // Camera text editor setting
  final EditorSetting? _cameraTextEditorSetting;

  // Camera photo editor setting
  final EditorSetting? _cameraPhotoEditorSetting;

  // Completer for gallerry picker controller
  late Completer<List<DrishyaEntity>> _completer;

  // Flag to handle updating controller value internally
  var _internal = false;

  // Flag for handling when user cleared all selected medias
  var _clearedSelection = false;

  // Gallery picker on changed event callback handler
  void Function(DrishyaEntity entity, bool removed)? _onChanged;

  //  Gallery picker on submitted event callback handler
  void Function(List<DrishyaEntity> entities)? _onSubmitted;

  // Full screen mode or collapsable mode
  var _fullScreenMode = false;

  //
  var _accessCamera = false;

  ///
  /// Update album visibility
  ///
  @internal
  void setAlbumVisibility({required bool visible}) {
    _panelController.isGestureEnabled = !visible;
    _albumVisibility.value = visible;
  }

  ///
  /// Selecting and unselecting entities
  ///
  @internal
  void select(DrishyaEntity entity, BuildContext context) {
    if (singleSelection) {
      _onChanged?.call(entity, false);
      completeTask(context, [entity]);
    } else {
      _clearedSelection = false;
      final selectedList = value.selectedEntities.toList();
      if (selectedList.contains(entity)) {
        selectedList.remove(entity);
        _onChanged?.call(entity, true);
      } else {
        if (reachedMaximumLimit) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Maximum selection limit of '
                  '${setting.maximum} has been reached!',
                ),
              ),
            );
          return;
        }
        selectedList.add(entity);
        _onChanged?.call(entity, false);
      }
      _internal = true;
      value = value.copyWith(
        selectedEntities: selectedList,
        previousSelection: false,
      );
    }
  }

  ///
  /// Complete selection process
  ///
  @internal
  void completeTask(BuildContext context, List<DrishyaEntity>? entities) {
    if (_fullScreenMode) {
      Navigator.of(context).pop(entities);
    } else {
      _panelController.closePanel();
      // _checkKeyboard.value = false;
    }
    _onSubmitted?.call(entities ?? []);
    _completer.complete(entities ?? []);
    _internal = true;
    value = const GalleryValue();
  }

  ///
  /// Close collapsable panel if screen is push/replace by other screen
  ///
  void _closeOnNavigation() {
    _panelController.closePanel();
    _internal = true;
    value = const GalleryValue();
  }

  ///
  /// Open camera from [GalleryView]
  ///
  @internal
  Future<void> openCamera(BuildContext context) async {
    _accessCamera = true;
    DrishyaEntity? entity;

    final route = SlideTransitionPageRoute<DrishyaEntity>(
      builder: CameraView(
        setting: _cameraSetting,
        editorSetting: _cameraTextEditorSetting,
        photoEditorSetting: _cameraPhotoEditorSetting,
      ),
      begainHorizontal: true,
      transitionDuration: const Duration(milliseconds: 300),
    );

    if (fullScreenMode) {
      entity = await Navigator.of(context).pushReplacement(route);
    } else {
      entity = await Navigator.of(context).push(route);
      _closeOnNavigation();
    }

    final entities = [...value.selectedEntities];
    if (entity != null) {
      entities.add(entity);
      _onChanged?.call(entity, false);
      _onSubmitted?.call(entities);
    }
    _accessCamera = false;
    _completer.complete(entities);
  }

  ///
  /// Edit provided entity
  ///
  @internal
  Future<void> editEntity(
    BuildContext context,
    DrishyaEntity entity,
  ) async {
    select(entity, context);
    _accessCamera = true;
    DrishyaEntity? pickedEntity;

    final navigator = Navigator.of(context);

    final bytes = await entity.originBytes;
    final editingController = DrishyaEditingController(
      setting: _editorSetting.copyWith(
        backgrounds: [PhotoBackground(bytes: bytes)],
      ),
    );

    final route = SlideTransitionPageRoute<DrishyaEntity>(
      builder: DrishyaEditor(controller: editingController),
      begainHorizontal: true,
      transitionDuration: const Duration(milliseconds: 300),
    );

    if (!navigator.mounted) return;

    if (fullScreenMode) {
      pickedEntity = await navigator.pushReplacement(route);
    } else {
      pickedEntity = await navigator.push(route);
      _closeOnNavigation();
    }
    Future.delayed(
      const Duration(milliseconds: 500),
      editingController.dispose,
    );
    final entities = [...value.selectedEntities];
    if (pickedEntity != null) {
      entities.add(pickedEntity);
      _onChanged?.call(pickedEntity, false);
      _onSubmitted?.call(entities);
    }
    _accessCamera = false;
    _completer.complete(entities);
  }

  ///
  /// Open gallery using [GalleryViewField]
  ///
  @internal
  void onGalleryFieldPressed(
    void Function(DrishyaEntity entity, bool removed)? onChanged,
    final void Function(List<DrishyaEntity> entities)? onSubmitted,
    List<DrishyaEntity>? selectedEntities,
    BuildContext context,
  ) {
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    pick(context, selectedEntities: selectedEntities).then((value) {
      _onChanged = null;
      _onSubmitted = null;
    });
  }

  // ===================== PUBLIC ==========================

  ///
  /// Close gallery when it is in slidable mode
  ///
  void closeSlidableGallery() {
    if (panelKey.currentState == null) return;
    _panelController.closePanel();
    final entities = (_clearedSelection || value.selectedEntities.isEmpty)
        ? <DrishyaEntity>[]
        : value.selectedEntities;
    _completer.complete(entities);
    _internal = true;
    value = const GalleryValue();
  }

  ///
  /// Clear selected entities
  ///
  void clearSelection() {
    _onSubmitted?.call([]);
    _clearedSelection = true;
    _internal = true;
    value = const GalleryValue();
  }

  ///
  /// Pick assets
  ///
  Future<List<DrishyaEntity>> pick(
    BuildContext context, {
    List<DrishyaEntity>? selectedEntities,
  }) async {
    _completer = Completer<List<DrishyaEntity>>();

    if (panelKey.currentState == null) {
      _fullScreenMode = true;
      final entity = await GalleryView.pick(context, controller: this);
      // User did't open the camera and also didn't pick any assets
      if (entity == null && !_accessCamera) {
        _completer.complete(value.selectedEntities);
      }
    } else {
      _fullScreenMode = false;
      _panelController.openPanel();
      FocusScope.of(context).unfocus();
    }
    if (!singleSelection && (selectedEntities?.isNotEmpty ?? false)) {
      _internal = true;
      value = value.copyWith(
        selectedEntities: selectedEntities,
        previousSelection: true,
      );
    }

    return _completer.future;
  }

  ///
  /// Recent entities list
  ///
  Future<List<DrishyaEntity>> recentEntities({
    RequestType? type,
    int count = 20,
  }) {
    final albums = Albums();
    final entities = albums.recentEntities(type: type, count: count);
    albums.dispose();
    return entities;
  }

  // ===================== GETTERS ==========================

  ///
  /// Album visibility notifier
  ///
  ValueNotifier<bool> get albumVisibility => _albumVisibility;

  ///
  /// return true if gallery is in full screen mode,
  ///
  bool get fullScreenMode => _fullScreenMode;

  ///
  /// return true if selected media reached to maximum selection limit
  ///
  bool get reachedMaximumLimit =>
      value.selectedEntities.length == setting.maximum;

  ///
  /// return true is gallery is in single selection mode
  ///
  bool get singleSelection => setting.maximum == 1;

  /// Gallery view pannel controller
  PanelController get panelController => _panelController;

  @override
  set value(GalleryValue newValue) {
    if (!_internal) return;
    super.value = newValue;
    _internal = false;
  }

  @override
  void dispose() {
    _panelController.dispose();
    _albumVisibility.dispose();
    super.dispose();
  }

  //
}
