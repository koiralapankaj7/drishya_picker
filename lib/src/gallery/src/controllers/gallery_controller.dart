import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

///
/// Gallery controller
class GalleryController extends ValueNotifier<GalleryValue> {
  ///
  /// Gallery controller constructor
  GalleryController()
      : panelKey = GlobalKey(),
        _panelController = PanelController(),
        _albumVisibility = ValueNotifier(false),
        super(const GalleryValue()) {
    init();
  }

  /// Slidable gallery key
  final GlobalKey panelKey;

  /// Panel controller
  final PanelController _panelController;

  /// Recent entities notifier
  final ValueNotifier<bool> _albumVisibility;

  late PanelSetting _panelSetting;

  /// Panel setting
  PanelSetting get panelSetting => _panelSetting;

  late GallerySetting _setting;

  /// Gallery setting
  GallerySetting get setting => _setting;

  /// Editor setting
  late EditorSetting _editorSetting;

  // Camera controller
  late CameraSetting _cameraSetting;

  // Camera text editor setting
  late EditorSetting _cameraTextEditorSetting;

  // Camera photo editor setting
  late EditorSetting _cameraPhotoEditorSetting;

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

  /// Initialize controller setting
  @internal
  void init({GallerySetting? setting}) {
    _setting = setting ?? const GallerySetting();
    _panelSetting = _setting.panelSetting ?? const PanelSetting();
    _editorSetting = _setting.editorSetting ?? const EditorSetting();
    _cameraSetting = _setting.cameraSetting ?? const CameraSetting();
    _cameraTextEditorSetting =
        _setting.cameraTextEditorSetting ?? _editorSetting;
    _cameraPhotoEditorSetting =
        _setting.cameraPhotoEditorSetting ?? _editorSetting;
  }

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
      if (fullScreenMode) {
        Navigator.of(context).pop([entity]);
      }
      completeTask(entities: [entity]);
    } else {
      _clearedSelection = false;
      final selectedList = List<DrishyaEntity>.from(value.selectedEntities);
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
  @internal
  void completeTask({List<DrishyaEntity>? entities}) {
    final selectedEntities = entities ??
        (_clearedSelection || value.selectedEntities.isEmpty
            ? <DrishyaEntity>[]
            : value.selectedEntities);

    if (!_fullScreenMode && _panelController.isVisible) {
      _panelController.closePanel();
    }

    _onSubmitted?.call(selectedEntities);
    _completer.complete(selectedEntities);
    _fullScreenMode = false;
    _internal = true;
    value = const GalleryValue();
  }

  ///
  /// Open camera from [GalleryView]
  @internal
  Future<void> openCamera(BuildContext context) async {
    _accessCamera = true;

    final route = SlideTransitionPageRoute<DrishyaEntity>(
      builder: CameraView(
        setting: _cameraSetting,
        editorSetting: _cameraTextEditorSetting,
        photoEditorSetting: _cameraPhotoEditorSetting,
      ),
      begainHorizontal: true,
      transitionDuration: const Duration(milliseconds: 300),
    );

    final entities = [...value.selectedEntities];

    if (fullScreenMode) {
      final entity = await Navigator.of(context).pushReplacement(route);
      if (entity != null) {
        entities.add(entity);
        _onChanged?.call(entity, false);
      }
      completeTask(entities: entities);
      _accessCamera = false;
    } else {
      final entity = await Navigator.of(context).push(route);
      _panelController.minimizePanel();
      if (entity != null) {
        entities.add(entity);
        _onChanged?.call(entity, false);
      }
      _accessCamera = false;
    }
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
    drishyaUIMode = SystemUiMode.manual;
    final navigator = Navigator.of(context);

    final route = SlideTransitionPageRoute<DrishyaEntity>(
      builder: DrishyaEditor(
        setting: _editorSetting.copyWith(
          backgrounds: [DrishyaBackground(entity: entity)],
        ),
      ),
      begainHorizontal: true,
      transitionDuration: const Duration(milliseconds: 300),
    );

    if (!navigator.mounted) return;

    if (fullScreenMode) {
      final entity = await navigator.pushReplacement(route);
      if (entity != null) {
        _onChanged?.call(entity, false);
      }
      completeTask(entities: entity != null ? [entity] : null);
      return;
    } else {
      final entity = await navigator.push(route);
      _panelController.minimizePanel();
      final entities = [...value.selectedEntities];
      if (entity != null) {
        entities.add(entity);
        _onChanged?.call(entity, false);
      }
    }
  }

  ///
  /// Open gallery using [GalleryViewField]
  ///
  @internal
  void onGalleryFieldPressed(
    BuildContext context, {
    void Function(DrishyaEntity entity, bool removed)? onChanged,
    final void Function(List<DrishyaEntity> entities)? onSubmitted,
    List<DrishyaEntity>? selectedEntities,
    GallerySetting? setting,
  }) {
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    pick(
      context,
      selectedEntities: selectedEntities,
      setting: setting,
    ).then((value) {
      _onChanged = null;
      _onSubmitted = null;
      if (panelKey.currentState == null) {
        Future.delayed(const Duration(milliseconds: 500), dispose);
      }
    });
  }

  // ===================== PUBLIC ==========================

  ///
  /// Clear selected entities
  void clearSelection() {
    _onSubmitted?.call([]);
    _clearedSelection = true;
    _internal = true;
    value = const GalleryValue();
  }

  ///
  /// Pick assets
  Future<List<DrishyaEntity>> pick(
    BuildContext context, {
    List<DrishyaEntity>? selectedEntities,
    GallerySetting? setting,
  }) async {
    _completer = Completer<List<DrishyaEntity>>();

    /// [SlidableGalleryView] is not used so we need to update setting
    if (panelKey.currentState == null && setting != null) {
      init(setting: setting);
    }

    if (!singleSelection && (selectedEntities?.isNotEmpty ?? false)) {
      _internal = true;
      value = value.copyWith(
        selectedEntities: selectedEntities,
        previousSelection: true,
      );
    }

    if (panelKey.currentState == null) {
      _fullScreenMode = true;
      await GalleryView.pick(context, controller: this, setting: setting);
      // User did't open the camera and also didn't pick any assets
      if (!_accessCamera) {
        completeTask();
      }
    } else {
      _fullScreenMode = false;
      _panelController.openPanel();
      FocusScope.of(context).unfocus();
    }

    return _completer.future;
  }

  ///
  /// Recent entities list
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
  ValueNotifier<bool> get albumVisibility => _albumVisibility;

  ///
  /// return true if gallery is in full screen mode,
  bool get fullScreenMode => _fullScreenMode;

  ///
  /// return true if selected media reached to maximum selection limit
  bool get reachedMaximumLimit =>
      value.selectedEntities.length == setting.maximum;

  ///
  /// return true is gallery is in single selection mode
  bool get singleSelection => setting.maximum == 1;

  ///
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
