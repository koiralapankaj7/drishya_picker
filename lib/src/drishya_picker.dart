import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import 'application/media_cubit.dart';
import 'camera/camera_view.dart';
import 'drishya_controller_provider.dart';
import 'entities/entities.dart';
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
  late final PanelSetting _setting;
  late final DrishyaController _controller;
  late final PanelController _panelController;

  late AlbumCollectionCubit _albumCollectionCubit;
  late CurrentAlbumCubit _currentAlbumCubit;
  late GalleryCubit _galleryCubit;

  late double _panelMaxHeight;
  late double _panelMinHeight;
  var _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _setting = widget.panelSetting ?? const PanelSetting();
    _controller = (widget.controller ?? DrishyaController()).._init(context);
    _panelController = _controller.panelController;
    _galleryCubit = GalleryCubit();

    _currentAlbumCubit = CurrentAlbumCubit()
      ..stream.listen((state) {
        if (state.hasData) {
          _galleryCubit.fetchAssets(state.album!);
        }
      });
    _albumCollectionCubit = AlbumCollectionCubit()
      ..fetchAlbums(_controller.setting.requestType)
      ..stream.listen((state) {
        if (state.hasData) {
          if (state.isEmpty) {
            _galleryCubit.empty();
          } else {
            _currentAlbumCubit.changeAlbum(state.albums.first);
          }
        }
      });

    _controller._checkKeyboard.addListener(_init);
  }

  void _init() {
    if (_controller._checkKeyboard.value) {
      if (_keyboardVisible) {
        FocusScope.of(context).unfocus();
        Future.delayed(
          const Duration(milliseconds: 180),
          () {
            if (_controller.setting.fullScreenMode) {
              _panelController.maximizePanel();
            } else {
              _panelController.openPanel();
            }
          },
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DrishyaControllerProvider(
        controller: _controller,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _panelMaxHeight =
                (_setting.panelMaxHeight ?? constraints.maxHeight) -
                    (_setting.topMargin ?? 0.0);
            _panelMinHeight = _setting.panelMinHeight ?? _panelMaxHeight * 0.35;

            return Stack(
              // fit: StackFit.expand,
              children: [
                // Child i.e, Back view
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _panelController.isVisible ? _cancel : null,
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
                MultiBlocProvider(
                  providers: [
                    BlocProvider<AlbumCollectionCubit>(
                      create: (context) => _albumCollectionCubit,
                    ),
                    BlocProvider<CurrentAlbumCubit>(
                      create: (context) => _currentAlbumCubit,
                    ),
                    BlocProvider<GalleryCubit>(
                      create: (context) => _galleryCubit,
                    ),
                  ],
                  child: Center(
                    child: SlidablePanel(
                      controller: _panelController,
                      panelHeaderMaxHeight: _setting.panelHeaderMaxHeight,
                      panelHeaderMinHeight: _setting.panelHeaderMinHeight,
                      panelMinHeight: _panelMinHeight,
                      panelMaxHeight: _panelMaxHeight,
                      snapingPoint: _setting.snapingPoint,
                      child: GalleryView(
                        controller: _controller,
                        headerBackground: _setting.panelHeaderBackground ??
                            _setting.background,
                        panelBackground:
                            _setting.panelBackground ?? _setting.background,
                      ),
                    ),
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
    required this.controller,
    this.headerBackground,
    this.panelBackground,
  }) : super(key: key);

  ///
  final Color? headerBackground;

  ///
  final Color? panelBackground;

  ///
  final DrishyaController controller;

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView>
    with SingleTickerProviderStateMixin {
  late final PanelController _panelController;
  late final DrishyaController _controller;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _panelController = _controller.panelController;
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
    super.dispose();
  }

  void _toogleAlbumList() {
    final gState = context.read<GalleryCubit>().state;

    if (!gState.hasPermission || gState.items.isEmpty) return;

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
      _panelController.minimizePanel();
    }
  }

  void _onSelectionClear() {
    _controller._clearSelection();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final albumListHeight =
        _panelController.panelMaxHeight! - _panelController.headerMaxHeight!;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Header
        Header(
          drishyaController: _controller,
          background: widget.headerBackground,
          toogleAlbumList: _toogleAlbumList,
          onClosePressed: _onClosePressed,
          headerSubtitle: _controller.setting.albumSubtitle,
          onSelectionClear: _onSelectionClear,
        ),

        // Gallery
        Column(
          children: [
            // Space for header
            ValueListenableBuilder<SliderValue>(
              valueListenable: _panelController,
              builder: (context, SliderValue value, child) {
                final num height = (_panelController.headerMinHeight! +
                        (_panelController.headerMaxHeight! -
                                _panelController.headerMinHeight!) *
                            value.factor *
                            1.2)
                    .clamp(
                  _panelController.headerMinHeight!,
                  _panelController.headerMaxHeight!,
                );
                return SizedBox(height: height as double?);
              },
            ),

            // Gallery view
            Expanded(
              child: Container(
                color: widget.panelBackground ?? Colors.black,
                child: BlocConsumer<GalleryCubit, GalleryState>(
                  listener: (context, state) {
                    // PhotoManager.requestPermission();
                    // if (s.paginationFailure != null) {
                    //   ScaffoldMessenger.of(context)
                    //.showSnackBar(SnackBar(
                    //       content: Text(s.paginationFailure.message)));
                    // }
                  },
                  builder: (context, state) {
                    // Loading state
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.hasError) {
                      if (!state.hasPermission) {
                        return const PermissionRequest();
                      }
                    }

                    if (state.items.isEmpty) {
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

                    return GridView.builder(
                      controller: _panelController.scrollController,
                      padding: const EdgeInsets.all(0.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 1.0,
                      ),
                      itemCount: state.count + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return CameraView();
                                }),
                              );
                            },
                            child: Container(
                              color: Colors.cyan,
                              child: Icon(Icons.add),
                            ),
                          );
                        }
                        final entity = state.items[index - 1];
                        return MediaTile(
                          drishyaController: _controller,
                          entity: entity,
                          onSelect: () {
                            _controller._select(entity);
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
            onEdit: () {},
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
            onPressed: (album) {
              context.read<CurrentAlbumCubit>().changeAlbum(album);
              _toogleAlbumList();
            },
          ),
        ),

        //
      ],
    );
  }
}

///
class DrishyaPickerField extends StatefulWidget {
  ///
  const DrishyaPickerField({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.setting,
    this.child,
  }) : super(key: key);

  ///
  /// If source is [DrishyaSource.camera] [removed] will be always false
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
  _DrishyaPickerFieldState createState() => _DrishyaPickerFieldState();
}

///
class _DrishyaPickerFieldState extends State<DrishyaPickerField> {
  late final DrishyaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DrishyaController().._init(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller._fromPicker(
          widget.onChanged,
          widget.onSubmitted,
          widget.setting,
        );
      },
      child: widget.child,
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
  late BuildContext _context;

  void _init(BuildContext context) {
    _context = context;
  }

  // When clearing all selected entities on changed need to notify current
  // status of last selected asset
  AssetEntity? _lastSelectedEntity;
  void Function(AssetEntity entity, bool removed)? _onChanged;
  void Function(List<AssetEntity> entities)? _onSubmitted;

  // Media setting
  DrishyaSetting _setting = DrishyaSetting();

  // Selecting and unselecting entities
  void _select(AssetEntity entity) {
    final selectedList = value.entities.toList();
    if (selectedList.contains(entity)) {
      selectedList.remove(entity);
      _onChanged?.call(entity, true);
    } else {
      if (reachedMaximumLimit) {
        ScaffoldMessenger.of(_context).showSnackBar(
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
  void _submit() {
    _panelController.closePanel();
    _completer.complete(value.entities);
    _checkKeyboard.value = false;
    _onSubmitted?.call(value.entities);
    value = const DrishyaValue();
  }

  // When panel closed without any selection
  void _cancel() {
    _panelController.closePanel();
    _completer.complete(<AssetEntity>[]);
    _checkKeyboard.value = false;
    _onSubmitted?.call(<AssetEntity>[]);
    value = const DrishyaValue();
  }

  ///
  void _fromPicker(
    void Function(AssetEntity entity, bool removed)? onChanged,
    final void Function(List<AssetEntity> entities)? onSubmitted,
    DrishyaSetting? setting,
  ) {
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    pickDrishya(setting: setting);
  }

  /// Pick media
  Future<List<AssetEntity>> pickDrishya({DrishyaSetting? setting}) async {
    if (setting != null) {
      _setting = setting;
    }

    // Camera picker
    if (_setting.source == DrishyaSource.camera) {
      final entity = await Navigator.of(_context).push<AssetEntity?>(
        MaterialPageRoute(builder: (context) => CameraView()),
      );
      if (entity != null) {
        _onChanged?.call(entity, false);
        _onSubmitted?.call([entity]);
        return [entity];
      }
      return [];
    }

    // Gallery picker
    if (_setting.source == DrishyaSource.gallery) {
      _completer = Completer<List<AssetEntity>>();
      _checkKeyboard.value = true;
      // If widget is not wrapped by drishya picker
      if (_context.drishyaController == null) {
        Navigator.of(_context).push<List<AssetEntity>?>(
          MaterialPageRoute(
            builder: (context) => DrishyaPicker(controller: this),
          ),
        );
      }
      if (_setting.selectedItems.isNotEmpty) {
        value = value.copyWith(
          entities: _setting.selectedItems,
          previousSelection: true,
        );
      }
      return _completer.future;
    }

    return [];
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
