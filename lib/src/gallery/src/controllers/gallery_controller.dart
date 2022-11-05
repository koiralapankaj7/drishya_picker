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

  // Flag which will used to determine that controller can be auto dispose
  // or not.
  var _autoDispose = false;

  /// Value will be true if controller can be auto dispose
  @internal
  bool get autoDispose => _autoDispose;

  // Gallery picker on changed event callback handler
  void Function(DrishyaEntity entity, bool removed)? _onChanged;

  ///
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_setting.selectedEntities.isNotEmpty) {
        _internal = true;
        value = value.copyWith(selectedEntities: _setting.selectedEntities);
      }
    });
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
  /// Toogle force multi selection button
  @internal
  void toogleMultiSelection() {
    _internal = true;
    value = value.copyWith(
      enableMultiSelection: !value.enableMultiSelection,
    );
  }

  ///
  /// Selecting and unselecting entities
  @internal
  void select(
    BuildContext context,
    DrishyaEntity entity, {
    bool edited = false,
  }) {
    // Check limit
    if (reachedMaximumLimit) {
      UIHandler.of(context).showSnackBar(
        'Maximum selection limit of '
        '${setting.maximumCount} has been reached!',
      );
      return;
    }

    // Handle single selection mode
    if (singleSelection) {
      if (_setting.selectionMode == SelectionMode.actionBased) {
        editEntity(context, entity).then((ety) {
          if (ety != null) {
            _onChanged?.call(ety, false);
            completeTask(context, items: [ety]);
          }
        });
      } else {
        _onChanged?.call(entity, false);
        completeTask(context, items: [entity]);
      }
      return;
    }

    final entities = value.selectedEntities.toList();
    final isSelected = entities.contains(entity);

    // Unselect item if selected previously
    if (isSelected) {
      _onChanged?.call(entity, true);
      entities.remove(entity);
      _internal = true;
      value = value.copyWith(selectedEntities: entities);
      return;
    }

    // Unselect previous item and continue if it was edited
    if (edited && entities.isNotEmpty) {
      final item = entities.last;
      _onChanged?.call(item, true);
      entities.remove(item);
    }

    entities.add(entity);
    _onChanged?.call(entity, false);
    _internal = true;
    value = value.copyWith(selectedEntities: entities);
  }

  ///
  /// Open camera from [GalleryView]
  @internal
  Future<DrishyaEntity?> openCamera(BuildContext context) async {
    final uiHandler = UIHandler.of(context);

    final route = SlideTransitionPageRoute<List<DrishyaEntity>>(
      builder: CameraView(
        setting: _cameraSetting.copyWith(enableGallery: false),
        editorSetting: _cameraTextEditorSetting,
        photoEditorSetting: _cameraPhotoEditorSetting,
      ),
      setting: const CustomRouteSetting(
        start: TransitionFrom.leftToRight,
        reverse: TransitionFrom.rightToLeft,
      ),
    );

    if (fullScreenMode) {
      final list = await uiHandler.push(route);
      await UIHandler.showStatusBar();
      if (list?.isNotEmpty ?? false) {
        final ety = list!.first;
        _onChanged?.call(ety, false);
        if (!uiHandler.mounted) return null;
        completeTask(context, items: [...value.selectedEntities, ety]);
        return ety;
      }
    } else {
      _panelController.minimizePanel();
      final list = await Navigator.of(context).push(route);
      await UIHandler.showStatusBar();
      if (list?.isNotEmpty ?? false) {
        final ety = list!.first;
        // Camera was open on selection mode? then complete task
        // else select item
        if (singleSelection) {
          if (!uiHandler.mounted) return null;
          completeTask(context, items: [ety]);
        } else {
          if (!uiHandler.mounted) return null;
          select(context, ety);
        }
        return ety;
      }
    }
    return null;
  }

  ///
  /// Edit provided entity
  @internal
  Future<DrishyaEntity?> editEntity(
    BuildContext context,
    DrishyaEntity entity,
  ) async {
    //
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

    if (!fullScreenMode) {
      _panelController.minimizePanel();
    }

    final ety = await uiHandler.push(route);
    await UIHandler.showStatusBar();
    return ety;
  }

  ///
  /// Open gallery using [GalleryViewField]
  @internal
  Future<List<DrishyaEntity>> onGalleryFieldPressed(
    BuildContext context, {
    void Function(DrishyaEntity entity, bool removed)? onChanged,
    GallerySetting? setting,
    CustomRouteSetting? routeSetting,
    bool disposeOnFinish = false,
  }) async {
    _onChanged = onChanged;
    // Dispose controller created inside [GalleryViewField]
    // onPressed which need to be disposed.
    _autoDispose = disposeOnFinish;
    final entities =
        await pick(context, setting: setting, routeSetting: routeSetting);
    _onChanged = null;
    return entities;
  }

  ///
  /// Handle picking process for slidable gallery using completer
  Future<List<DrishyaEntity>> _collapsableGallery(BuildContext context) {
    _completer = Completer<List<DrishyaEntity>>();
    _panelController.openPanel();
    FocusScope.of(context).unfocus();
    return _completer.future;
  }

  ///
  /// Complete selection process
  @internal
  List<DrishyaEntity> completeTask(
    BuildContext context, {
    List<DrishyaEntity>? items,
  }) {
    final entities = items ?? value.selectedEntities;

    // In fullscreen mode just pop the widget with selected entities
    if (fullScreenMode) {
      UIHandler.of(context).pop(entities);
      return entities;
    }

    _panelController.closePanel();
    _internal = true;
    value = const GalleryValue();
    _completer.complete(entities);
    return entities;
  }

  // ===================== PUBLIC ==========================

  ///
  /// Clear selected entities
  void clearSelection() {
    _internal = true;
    value = value.copyWith(selectedEntities: []);
  }

  ///
  /// Pick assets
  Future<List<DrishyaEntity>> pick(
    BuildContext context, {
    GallerySetting? setting,
    CustomRouteSetting? routeSetting,
  }) async {
    if (fullScreenMode) {
      final entities = await GalleryView.pick(
        context,
        controller: this,
        setting: setting,
        routeSetting: routeSetting,
      );
      await UIHandler.showStatusBar();
      return entities ?? [];
    }

    if (setting != null) {
      init(setting: setting);
    }
    return _collapsableGallery(context);
  }

  ///
  /// Fetch recent entities
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
  bool get fullScreenMode => panelKey.currentState == null;

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
    if (!_internal || value == newValue) return;
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
