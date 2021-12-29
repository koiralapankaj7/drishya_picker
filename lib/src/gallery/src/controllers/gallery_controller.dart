import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/camera/src/widgets/ui_handler.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:flutter/material.dart';
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

  /// Panel setting
  late PanelSetting _panelSetting;

  /// Panel setting
  PanelSetting get panelSetting => _panelSetting;

  late GallerySetting _setting;

  /// Gallery setting
  GallerySetting get setting => _setting;

  /// Editor setting
  late EditorSetting _editorSetting;

  //
  // Camera setting, gallery view will be disabled even user opted to enable it.
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
  var _fullScreenMode = true;

  //
  var _accessCamera = false;

  ///
  /// Initialize controller setting
  @internal
  void init({GallerySetting? setting}) {
    _completer = Completer<List<DrishyaEntity>>();
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
  @internal
  void setAlbumVisibility({required bool visible}) {
    _panelController.isGestureEnabled = !visible;
    _albumVisibility.value = visible;
    _internal = true;
    value = value.copyWith(isAlbumVisible: visible);
  }

  ///
  /// Selecting and unselecting entities
  @internal
  void select(BuildContext context, DrishyaEntity entity) {
    if (singleSelection) {
      _onChanged?.call(entity, false);
      // if (fullScreenMode) {
      //   Navigator.of(context).pop([entity]);
      // }
      completeTask(entities: [entity]);
    } else {
      _clearedSelection = false;
      final selectedList = List<DrishyaEntity>.from(value.selectedEntities);
      if (selectedList.contains(entity)) {
        selectedList.remove(entity);
        _onChanged?.call(entity, true);
      } else {
        if (reachedMaximumLimit) {
          UIHandler.of(context).showSnackBar(
            'Maximum selection limit of '
            '${setting.maximumCount} has been reached!',
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
  /// Toogle force multi selection button
  @internal
  void forceMultiSelect() {
    _internal = true;
    value = value.copyWith(
      enableMultiSelection: !value.enableMultiSelection,
    );
  }

  ///
  /// Complete selection process
  @internal
  List<DrishyaEntity> completeTask({List<DrishyaEntity>? entities}) {
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
    return selectedEntities;
  }

  ///
  /// Open camera from [GalleryView]
  @internal
  Future<void> openCamera(BuildContext context) async {
    _accessCamera = true;

    final route = SlideTransitionPageRoute<List<DrishyaEntity>>(
      builder: CameraView(
        setting: _cameraSetting.copyWith(enableGallery: false),
        editorSetting: _cameraTextEditorSetting,
        photoEditorSetting: _cameraPhotoEditorSetting,
      ),
      setting: CustomRouteSetting(
        start: TransitionFrom.rightToLeft,
        reverse: fullScreenMode
            ? TransitionFrom.topToBottom
            : TransitionFrom.leftToRight,
      ),
    );

    final entities = [...value.selectedEntities];

    if (fullScreenMode) {
      final list = await Navigator.of(context).pushReplacement(route);
      await UIHandler.showStatusBar();
      if (list?.isNotEmpty ?? false) {
        final ety = list!.first;
        entities.add(ety);
        _onChanged?.call(ety, false);
      }
      completeTask(entities: entities);
      _accessCamera = false;
    } else {
      _panelController.minimizePanel();
      final list = await Navigator.of(context).push(route);
      await UIHandler.showStatusBar();
      if (list?.isNotEmpty ?? false) {
        final ety = list!.first;
        entities.add(ety);
        _onChanged?.call(ety, false);
      }
      _accessCamera = false;
    }
  }

  ///
  /// Edit provided entity
  @internal
  Future<void> editEntity(
    BuildContext context,
    DrishyaEntity entity,
  ) async {
    if (!singleSelection) {
      select(context, entity);
    }

    _accessCamera = true;

    final uiHandler = UIHandler.of(context);

    final route = SlideTransitionPageRoute<DrishyaEntity>(
      builder: DrishyaEditor(
        setting: _editorSetting.copyWith(
          backgrounds: [DrishyaBackground(entity: entity)],
        ),
      ),
      setting: const CustomRouteSetting(
        start: TransitionFrom.rightToLeft,
        reverse: TransitionFrom.leftToRight,
      ),
    );

    if (fullScreenMode) {
      final ety = await uiHandler.push(route);
      if (ety != null) {
        _onChanged?.call(ety, false);
        completeTask(entities: [ety]);
        uiHandler.pop([ety]);
      }
    } else {
      _panelController.minimizePanel();
      final ety = await uiHandler.push(route);
      await UIHandler.showStatusBar();
      final entities = [...value.selectedEntities];
      if (ety != null) {
        entities.add(ety);
        _onChanged?.call(ety, false);
      }
    }
  }

  ///
  /// Open gallery using [GalleryViewField]
  @internal
  void onGalleryFieldPressed(
    BuildContext context, {
    void Function(DrishyaEntity entity, bool removed)? onChanged,
    final void Function(List<DrishyaEntity> entities)? onSubmitted,
    List<DrishyaEntity>? selectedEntities,
    GallerySetting? setting,
    CustomRouteSetting? routeSetting,
  }) {
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    pick(
      context,
      selectedEntities: selectedEntities,
      setting: setting,
      routeSetting: routeSetting,
    ).then((value) {
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
    CustomRouteSetting? routeSetting,
  }) async {
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
      await GalleryView.pick(
        context,
        controller: this,
        setting: setting,
        routeSetting: routeSetting,
      );
      // User did't open the camera and also didn't pick any assets
      if (!_accessCamera) {
        completeTask();
      }
    } else {
      _fullScreenMode = false;
      _panelController.openPanel();
      FocusScope.of(context).unfocus();
    }

    // TODO(koiralapankaj007): move completer to completeTask Functon
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
      value.selectedEntities.length == setting.maximumCount;

  ///
  /// return true is gallery is in single selection mode
  bool get singleSelection =>
      _setting.selectionMode == SelectionMode.actionBased
          ? !value.enableMultiSelection
          : setting.maximumCount == 1;

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
