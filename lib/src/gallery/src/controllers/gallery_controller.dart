import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/entities/gallery_value.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/material.dart';

import 'drishya_repository.dart';

///
class GalleryController extends ValueNotifier<GalleryValue> {
  ///
  /// Drishya controller
  GalleryController({
    PanelSetting? panelSetting,
    GallerySetting? gallerySetting,
  })  : panelSetting = panelSetting ?? const PanelSetting(),
        setting = gallerySetting ?? const GallerySetting(),
        panelController = PanelController(),
        albumsNotifier = ValueNotifier(const BaseState()),
        albumNotifier = ValueNotifier(const BaseState()),
        entitiesNotifier = ValueNotifier(const BaseState()),
        recentEntitiesNotifier = ValueNotifier(const BaseState()),
        albumVisibilityNotifier = ValueNotifier(true),
        super(const GalleryValue()) {
    repository = DrishyaRepository(
      albumsNotifier: albumsNotifier,
      albumNotifier: albumNotifier,
      entitiesNotifier: entitiesNotifier,
      recentEntitiesNotifier: recentEntitiesNotifier,
    )..fetchAlbums(setting.requestType);
  }

  /// Drishya repository
  late final DrishyaRepository repository;

  /// Albums notifier
  final ValueNotifier<AlbumsType> albumsNotifier;

  /// Current album notifier
  final ValueNotifier<AlbumType> albumNotifier;

  /// Current album entities notifier
  final ValueNotifier<EntitiesType> entitiesNotifier;

  /// Recent entities notifier
  final ValueNotifier<EntitiesType> recentEntitiesNotifier;

  /// Recent entities notifier
  final ValueNotifier<bool> albumVisibilityNotifier;

  /// Panel controller
  final PanelController panelController;

  /// Panel setting
  final PanelSetting panelSetting;

  /// Media setting
  late final GallerySetting setting;

  // Completer for gallerry picker controller
  late Completer<List<AssetEntity>> _completer;

  // Flag to handle updating controller value internally
  var _internal = false;

  // Flag for handling when user cleared all selected medias
  var _clearedSelection = false;

  // Gallery picker on changed event callback handler
  void Function(AssetEntity entity, bool removed)? _onChanged;

  //  Gallery picker on submitted event callback handler
  void Function(List<AssetEntity> entities)? _onSubmitted;

  // Full screen mode or collapsable mode
  var _fullScreenMode = false;

  final _wrapperKey = GlobalKey();

  ///
  GlobalKey get wrapperKey => _wrapperKey;

  ///
  void setAlbumVisibility(bool visible) {
    panelController.isGestureEnabled = !visible;
    albumVisibilityNotifier.value = visible;
  }

  /// Change album
  void changeAlbum(AssetPathEntity album) {
    repository.fetchAssetsFor(album);
    setAlbumVisibility(false);
  }

  /// Clear selected entities
  void clearSelection() {
    _onSubmitted?.call([]);
    _clearedSelection = true;
    _internal = true;
    value = const GalleryValue();
  }

  /// Selecting and unselecting entities
  void select(AssetEntity entity, BuildContext context) {
    if (singleSelection) {
      _onChanged?.call(entity, false);
      completeTask(context, entities: [entity]);
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
            ..showSnackBar(SnackBar(
                content: Text(
              'Maximum selection limit of '
              '${setting.maximum} has been reached!',
            )));
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

  /// When selection is completed
  void completeTask(BuildContext context, {List<AssetEntity>? entities}) {
    if (_fullScreenMode) {
      Navigator.of(context).pop(entities);
    } else {
      panelController.closePanel();
      // _checkKeyboard.value = false;
    }
    _onSubmitted?.call(entities ?? []);
    _completer.complete(entities ?? []);
    _internal = true;
    value = const GalleryValue();
  }

  /// When panel closed without any selection
  void cancel() {
    panelController.closePanel();
    final entities = (_clearedSelection || value.selectedEntities.isEmpty)
        ? <AssetEntity>[]
        : value.selectedEntities;
    _completer.complete(entities);
    // _onSubmitted?.call(entities);
    // _checkKeyboard.value = false;
    _internal = true;
    value = const GalleryValue();
  }

  /// Close collapsable panel if camera is selected from inside gallery view
  void _closeOnCameraSelect() {
    panelController.closePanel();
    // _checkKeyboard.value = false;
    _internal = true;
    value = const GalleryValue();
  }

  /// Open camera from [GalleryView]
  Future<void> openCamera(BuildContext context) async {
    AssetEntity? entity;

    final route = SlideTransitionPageRoute<AssetEntity>(
      builder: const CameraPicker(),
      horizontal: true,
    );

    if (fullScreenMode) {
      entity = await Navigator.of(context).pushReplacement(route);
    } else {
      entity = await Navigator.of(context).push(route);
      _closeOnCameraSelect();
    }

    final entities = value.selectedEntities;
    if (entity != null) {
      entities.add(entity);
      _onChanged?.call(entity, false);
      _onSubmitted?.call(entities);
    }
    _completer.complete(entities);
  }

  /// Open gallery using [GalleryViewField]
  void openGallery(
    void Function(AssetEntity entity, bool removed)? onChanged,
    final void Function(List<AssetEntity> entities)? onSubmitted,
    List<AssetEntity>? selectedEntities,
    BuildContext context,
  ) {
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    pick(context, selectedEntities: selectedEntities);
  }

  /// Pick assets
  Future<List<AssetEntity>?> pick(
    BuildContext context, {
    List<AssetEntity>? selectedEntities,
  }) {
    _completer = Completer<List<AssetEntity>>();

    if (_wrapperKey.currentState == null) {
      _fullScreenMode = true;
      final route = SlideTransitionPageRoute<List<AssetEntity>>(
        builder: GalleryView(controller: this),
      );
      Navigator.of(context).push(route).then((result) {
        // Closed by user
        if (result == null) {
          _completer.complete(value.selectedEntities);
        }
      });
    } else {
      _fullScreenMode = false;
      panelController.openPanel();
      // _checkKeyboard.value = true;
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

  // ===================== GETTERS ==========================

  /// return true if drishya picker is in full screen mode,
  bool get fullScreenMode => _fullScreenMode;

  /// return true if selected media reached to maximum selection limit
  bool get reachedMaximumLimit =>
      value.selectedEntities.length == setting.maximum;

  ///
  bool get singleSelection => setting.maximum == 1;

  @override
  set value(GalleryValue newValue) {
    if (_internal) {
      super.value = newValue;
      _internal = false;
    }
  }

  @override
  void dispose() {
    panelController.dispose();
    albumsNotifier.dispose();
    albumNotifier.dispose();
    entitiesNotifier.dispose();
    recentEntitiesNotifier.dispose();
    albumVisibilityNotifier.dispose();
    super.dispose();
  }

  //
}
