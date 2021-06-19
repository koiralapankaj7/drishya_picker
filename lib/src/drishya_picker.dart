import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/drishya_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import 'camera/camera_view.dart';
import 'gallery/drishya_controller_provider.dart';
import 'gallery/entities.dart';
import 'gallery/albums.dart';
import 'gallery/buttons.dart';
import 'gallery/header.dart';
import 'gallery/media_tile.dart';
import 'gallery/permission_view.dart';
import 'slidable_panel/slidable_panel.dart';

///
class DrishyaPicker extends StatefulWidget {
  ///
  DrishyaPicker({
    Key? key,
    this.child,
    this.controller,
    this.panelSetting,
  }) : super(key: key);

  /// Widget
  final Widget? child;

  /// Controller for [DrishyaPicker]
  final DrishyaController? controller;

  /// Setting for gallery panel
  final PanelSetting? panelSetting;

  @override
  _DrishyaPickerState createState() => _DrishyaPickerState();
}

class _DrishyaPickerState extends State<DrishyaPicker>
    with WidgetsBindingObserver {
  late final DrishyaController _controller;
  late final PanelController _panelController;
  var _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _controller = (widget.controller ?? DrishyaController())
      .._checkKeyboard.addListener(_init);
    _panelController = _controller.panelController;
  }

  void _init() {
    if (_controller._checkKeyboard.value) {
      if (_keyboardVisible) {
        FocusScope.of(context).unfocus();
        Future.delayed(
          const Duration(milliseconds: 180),
          _panelController.openPanel,
        );
      } else {
        _panelController.openPanel();
      }
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance?.window.viewInsets.bottom;
    _keyboardVisible = (bottomInset ?? 0.0) > 0.0;
    if (_keyboardVisible && _panelController.isVisible) {
      _cancel();
    }
  }

  void _cancel() {
    _controller._cancel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DrishyaControllerProvider(
        controller: _controller,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final s = widget.panelSetting ?? PanelSetting();
            final _panelMaxHeight =
                (s.maxHeight ?? constraints.maxHeight) - (s.topMargin);
            final _panelMinHeight = s.minHeight ?? _panelMaxHeight * 0.35;
            final _setting = s.copyWith(
              maxHeight: _panelMaxHeight,
              minHeight: _panelMinHeight,
            );
            return Stack(
              children: [
                // Child i.e, Back view
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (_panelController.isVisible) {
                            _cancel();
                          }
                        },
                        child: widget.child ?? const SizedBox(),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _panelController.panelVisibility,
                      builder: (context, isVisible, child) {
                        return isVisible ? child! : const SizedBox();
                      },
                      child: SizedBox(height: _panelMinHeight),
                    ),
                  ],
                ),

                // Custom media picker view i.e, Front view
                SlidablePanel(
                  setting: _setting,
                  controller: _panelController,
                  child: GalleryView(
                    panelSetting: _setting,
                    controller: _controller,
                  ),
                ),

                //
              ],
            );
          },
        ),
      ),
    );

    //
  }
}

///
class GalleryView extends StatefulWidget {
  ///
  const GalleryView({
    Key? key,
    this.controller,
    this.panelSetting,
  }) : super(key: key);

  ///
  final PanelSetting? panelSetting;

  ///
  final DrishyaController? controller;

  static const String name = 'GalleryView';

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView>
    with SingleTickerProviderStateMixin {
  late final PanelController _panelController;
  late final DrishyaController _controller;

  late final DrishyaRepository _repository;
  late final ValueNotifier<bool> _dropdownNotifier;
  late final ValueNotifier<AlbumsType> _albumsNotifier;
  late final ValueNotifier<AlbumType> _albumNotifier;
  late final ValueNotifier<EntitiesType> _entitiesNotifier;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? DrishyaController();
    _panelController = _controller.panelController;

    _dropdownNotifier = ValueNotifier<bool>(true);
    _albumsNotifier = ValueNotifier(BaseState());
    _albumNotifier = ValueNotifier(BaseState());
    _entitiesNotifier = ValueNotifier(BaseState());

    _repository = DrishyaRepository(
      albumsNotifier: _albumsNotifier,
      albumNotifier: _albumNotifier,
      entitiesNotifier: _entitiesNotifier,
    );

    _repository.fetchAlbums(_controller.setting.requestType);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.decelerate,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dropdownNotifier.dispose();
    _albumsNotifier.dispose();
    _albumNotifier.dispose();
    _entitiesNotifier.dispose();
    super.dispose();
  }

  void _toogleAlbumList() {
    if (_animationController.isAnimating) return;
    _panelController.isGestureEnabled = _animationController.value == 1.0;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _onClosePressed() {
    if (_animationController.isAnimating) return;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
      _panelController.isGestureEnabled = true;
    } else {
      if (_controller.fullScreenMode) {
        Navigator.of(context).pop();
      } else {
        _panelController.minimizePanel();
      }
    }
  }

  void _onSelectionClear() {
    _controller._clearSelection();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    var s = widget.panelSetting ?? PanelSetting();
    final _panelMaxHeight =
        (s.maxHeight ?? MediaQuery.of(context).size.height) - (s.topMargin);
    final _panelMinHeight = s.minHeight ?? _panelMaxHeight * 0.35;
    final _setting =
        s.copyWith(maxHeight: _panelMinHeight, minHeight: _panelMinHeight);
    final albumListHeight = _panelMaxHeight - s.headerMaxHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            // Header
            Header(
              controller: _controller,
              albumNotifier: _albumNotifier,
              dropdownNotifier: _dropdownNotifier,
              panelSetting: _setting,
              toogleAlbumList: _toogleAlbumList,
              onClosePressed: _onClosePressed,
              headerSubtitle: _controller.setting.albumSubtitle,
              onSelectionClear: _onSelectionClear,
            ),

            // Gallery
            Column(
              children: [
                // Space for header
                if (!_controller._fullScreenMode)
                  ValueListenableBuilder<SliderValue>(
                    valueListenable: _panelController,
                    builder: (context, SliderValue value, child) {
                      final num height = (_setting.headerMinHeight +
                              (_setting.headerMaxHeight -
                                      _setting.headerMinHeight) *
                                  value.factor *
                                  1.2)
                          .clamp(
                        _setting.headerMinHeight,
                        _setting.headerMaxHeight,
                      );
                      return SizedBox(height: height as double?);
                    },
                  ),

                if (_controller._fullScreenMode)
                  SizedBox(height: _setting.headerMaxHeight),

                // Gallery view
                Expanded(
                  child: Container(
                    color: _setting.foregroundColor,
                    child: ValueListenableBuilder<EntitiesType>(
                      valueListenable: _entitiesNotifier,
                      builder: (context, state, child) {
                        // Loading state
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Error
                        if (state.hasError) {
                          if (!state.hasPermission) {
                            return const PermissionRequest();
                          }
                        }

                        // No data
                        if (state.data?.isEmpty ?? true) {
                          return const Center(
                            child: Text(
                              'No media available',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }

                        final entities = state.data!;

                        return GridView.builder(
                          controller: _panelController.scrollController,
                          padding: const EdgeInsets.all(0.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1.0,
                            mainAxisSpacing: 1.0,
                          ),
                          itemCount: _controller.setting.enableCamera
                              ? entities.length + 1
                              : entities.length,
                          itemBuilder: (context, index) {
                            if (_controller.setting.enableCamera &&
                                index == 0) {
                              return InkWell(
                                onTap: () async {
                                  _controller._openCameraFromGallery(context);
                                },
                                child: Container(
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    color: Colors.lightBlue.shade300,
                                    size: 26.0,
                                  ),
                                ),
                              );
                            }
                            final ind = _controller.setting.enableCamera
                                ? index - 1
                                : index;
                            final entity = entities[ind];
                            return MediaTile(
                              drishyaController: _controller,
                              entity: entity,
                              onSelect: () {
                                _controller._select(entity, context);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                //
              ],
            ),

            // Send and edit button
            Positioned(
              bottom: 0.0,
              child: Buttons(
                drishyaController: _controller,
                onEdit: (context) {},
                onSubmit: _controller._submit,
              ),
            ),

            // Album List
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  bottom: albumListHeight * (_animation.value - 1),
                  left: 0.0,
                  right: 0.0,
                  child: child!,
                );
              },
              child: AlbumList(
                height: albumListHeight,
                albumsNotifier: _albumsNotifier,
                onPressed: (album) {
                  _toogleAlbumList();
                  _repository.fetchAssetsFor(album);
                  _dropdownNotifier.value = !_dropdownNotifier.value;
                },
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}

/// Widget which pick media from gallery
class GalleryPicker extends StatelessWidget {
  ///
  const GalleryPicker({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.setting,
    this.child,
  }) : super(key: key);

  ///
  /// While picking drishya using gallery [removed] will be true if,
  /// previously selected drishya is unselected otherwise false.
  ///
  final void Function(AssetEntity entity, bool removed)? onChanged;

  ///
  /// Triggered when picker complet its task.
  ///
  final void Function(List<AssetEntity> entities)? onSubmitted;

  ///
  /// Setting for drishya picker
  final DrishyaSetting? setting;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        (context.drishyaController ?? DrishyaController())
          .._openGallery(
            onChanged,
            onSubmitted,
            setting,
            context,
          );
      },
      child: child,
    );
  }
}

///
/// Widget to pick media using camera
class CameraPicker extends StatelessWidget {
  ///
  const CameraPicker({
    Key? key,
    this.onCapture,
    this.child,
  }) : super(key: key);

  ///
  /// Triggered when picker capture media
  ///
  final void Function(AssetEntity entity)? onCapture;

  ///
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DrishyaController()._openCamera(onCapture, context);
      },
      child: child,
    );
  }
}

///
class DrishyaController extends ValueNotifier<DrishyaValue> {
  ///
  DrishyaController()
      : _panelController = PanelController(),
        _checkKeyboard = ValueNotifier(false),
        super(const DrishyaValue());

  final PanelController _panelController;
  final ValueNotifier<bool> _checkKeyboard;
  late Completer<List<AssetEntity>> _completer;

  // When clearing all selected entities on changed need to notify current
  // status of last selected asset
  AssetEntity? _lastSelectedEntity;

  void Function(AssetEntity entity, bool removed)? _onChanged;
  void Function(List<AssetEntity> entities)? _onSubmitted;

  // Media setting
  DrishyaSetting _setting = DrishyaSetting();
  var _fullScreenMode = false;

  bool get fullScreenMode => _fullScreenMode;

  // Selecting and unselecting entities
  void _select(AssetEntity entity, BuildContext context) {
    final selectedList = value.entities.toList();
    if (selectedList.contains(entity)) {
      selectedList.remove(entity);
      _onChanged?.call(entity, true);
    } else {
      if (reachedMaximumLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum selection limit reached!')),
        );
        return;
      }
      selectedList.add(entity);
      _onChanged?.call(entity, false);
      _lastSelectedEntity = entity;
    }
    value = value.copyWith(
      entities: selectedList,
      previousSelection: false,
    );
  }

  // Clear selected entities
  void _clearSelection() {
    _onChanged?.call(_lastSelectedEntity!, true);
    _onSubmitted?.call(value.entities);
    value = const DrishyaValue();
  }

  // When selection is completed
  void _submit(BuildContext context) {
    if (_fullScreenMode) {
      Navigator.of(context).pop();
    } else {
      _panelController.closePanel();
      _completer.complete(value.entities);
      _checkKeyboard.value = false;
    }
    _onSubmitted?.call(value.entities);
    value = const DrishyaValue();
  }

  // When panel closed without any selection
  void _cancel() {
    _panelController.closePanel();
    _completer.complete(setting.selectedItems);
    _checkKeyboard.value = false;
    _onSubmitted?.call(setting.selectedItems);
    value = const DrishyaValue();
  }

  /// Open camera from [GalleryView]
  void _openCameraFromGallery(BuildContext context) async {
    AssetEntity? entity;
    if (_fullScreenMode) {
      final e = await Navigator.of(context).pushReplacement(
        _route<AssetEntity?>(CameraView(), horizontal: true),
      );
      entity = e;
    } else {
      final e = await Navigator.of(context).push(
        _route<AssetEntity?>(CameraView(), horizontal: true),
      );
      entity = e;
    }
    if (entity != null) {
      _onChanged?.call(entity, false);
      final items = [...setting.selectedItems, entity];
      _onSubmitted?.call(items);
      _completer.complete(items);
    }
  }

  /// Open camera from [CameraPicker]
  void _openCamera(
    final void Function(AssetEntity entity)? onCapture,
    BuildContext context,
  ) async {
    final entity = await pickFromCamera(context);
    if (entity != null) {
      onCapture?.call(entity);
    }
  }

  /// Open gallery from [GalleryPicker]
  void _openGallery(
    void Function(AssetEntity entity, bool removed)? onChanged,
    final void Function(List<AssetEntity> entities)? onSubmitted,
    DrishyaSetting? setting,
    BuildContext context,
  ) {
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    pickFromGallery(context, setting: setting);
  }

  /// Pick drishya from camera
  Future<AssetEntity?> pickFromCamera(BuildContext context) async {
    final entity = await Navigator.of(context).push(
      _route<AssetEntity?>(CameraView(), name: CameraView.name),
    );
    return entity;
  }

  /// Pick drishya from gallery
  Future<List<AssetEntity>?> pickFromGallery(
    BuildContext context, {
    DrishyaSetting? setting,
  }) async {
    if (setting != null) {
      _setting = setting;
    }
    if (context.drishyaController == null) {
      _fullScreenMode = true;
      Navigator.of(context).push(
        _route<List<AssetEntity>?>(
          GalleryView(controller: this),
          name: GalleryView.name,
        ),
      );
    } else {
      _fullScreenMode = false;
      _completer = Completer<List<AssetEntity>>();
      _checkKeyboard.value = true;
      if (_setting.selectedItems.isNotEmpty) {
        value = value.copyWith(
          entities: _setting.selectedItems,
          previousSelection: true,
        );
      }
      return _completer.future;
    }
  }

  /// Panel controller
  PanelController get panelController => _panelController;

  /// Media setting
  DrishyaSetting get setting => _setting;

  ///
  bool get reachedMaximumLimit => value.entities.length == setting.maximum;

  @override
  set value(DrishyaValue newValue) {
    super.value = newValue;
  }

  @override
  void dispose() {
    _checkKeyboard.dispose();
    _panelController.dispose();
    super.dispose();
  }

  //
}

/// Camera and gallery route
Route<T> _route<T>(
  Widget page, {
  bool horizontal = false,
  String name = '',
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    settings: RouteSettings(name: name),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = horizontal ? Offset(1.0, 0.0) : Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
