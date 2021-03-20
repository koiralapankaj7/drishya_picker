import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import '../src/widgets/media_controller_provider.dart';
import '../src/widgets/slidable_panel.dart';
import 'application/media_cubit.dart';

part '../src/widgets/gallery_view.dart';
part '../src/widgets/header.dart';
part '../src/widgets/media_picker.dart';

/// Media picker setting
class MediaSetting {
  ///
  MediaSetting({
    this.selected,
    this.maximum,
    this.albumSubtitle,
  });

  /// Previously selected media which will be pre selected
  final List<AssetEntity>? selected;

  /// Total medai allowed to select. Default is 20
  final int? maximum;

  /// String displayed below alnum name, Default : 'Select media'
  final String? albumSubtitle;
}

///
class DrishyaPicker extends StatefulWidget {
  ///
  DrishyaPicker({
    Key? key,
    this.controller,
    this.child,
    this.requestType,
    this.panelHeaderMaxHeight,
    this.panelHeaderMinHeight,
    this.panelHeaderBackground,
    this.panelMinHeight,
    this.panelMaxHeight,
    this.panelBackground,
    this.snapingPoint,
    this.background,
    this.topMargin,
  })  : assert(
          snapingPoint == null || (snapingPoint >= 0.0 && snapingPoint <= 1.0),
          '[snapingPoint] value must be between 1.0 and 0.0',
        ),
        super(key: key);

  /// Controller for [DrishyaPicker]
  final CustomMediaController? controller;

  /// Widget
  final Widget? child;

  /// Type of media e.g, image, video, audio, other
  final RequestType? requestType;

  /// Panel maximum height
  ///
  /// mediaQuery = MediaQuery.of(context)
  /// Default: mediaQuery.size.height -  mediaQuery.padding.top
  final double? panelMaxHeight;

  /// Panel minimum height
  /// Default: 35% of [panelMaxHeight]
  final double? panelMinHeight;

  /// Panel header maximum size
  ///
  /// Default: 75.0 px
  final double? panelHeaderMaxHeight;

  /// Panel header minimum size,
  ///
  /// which will be use as panel scroll handler
  /// Default: 25.0 px
  final double? panelHeaderMinHeight;

  /// Background color for panel header,
  /// Default: [Colors.black]
  final Color? panelHeaderBackground;

  /// Background color for panel,
  /// Default: [Colors.black]
  final Color? panelBackground;

  /// Point from where panel will start fling animation to snap it's height
  ///
  /// Value must be between 0.0 - 1.0
  /// Default: 0.4
  final double? snapingPoint;

  /// If [panelHeaderBackground] is missing [background] will be applied
  /// If [panelBackground] is missing [background] will be applied
  ///
  /// Default: [Colors.black]
  final Color? background;

  /// Margin for panel top. Which can be used to show status bar if you need
  /// to show panel above scaffold.
  final double? topMargin;

  @override
  _DrishyaPickerState createState() => _DrishyaPickerState();
}

class _DrishyaPickerState extends State<DrishyaPicker>
    with WidgetsBindingObserver {
  late CustomMediaController _controller;
  late PanelController _panelController;

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

    _controller = widget.controller ?? CustomMediaController();
    _panelController = _controller.panelController;
    _galleryCubit = GalleryCubit();

    _currentAlbumCubit = CurrentAlbumCubit()
      ..stream.listen((state) {
        if (state.hasData) {
          _galleryCubit.fetchAssets(state.album!);
        }
      });
    _albumCollectionCubit = AlbumCollectionCubit()
      ..fetchAlbums(widget.requestType ?? RequestType.common)
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
      _controller._cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MediaControllerProvider(
        controller: _controller,
        child: LayoutBuilder(builder: (context, constraints) {
          _panelMaxHeight = (widget.panelMaxHeight ?? constraints.maxHeight) -
              (widget.topMargin ?? 0.0);
          _panelMinHeight = widget.panelMinHeight ?? _panelMaxHeight * 0.35;

          return Stack(
            // fit: StackFit.expand,
            children: [
              // Child i.e, Back view
              Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_panelController.isVisible) {
                          _controller._cancel();
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
                    panelHeaderMaxHeight: widget.panelHeaderMaxHeight,
                    panelHeaderMinHeight: widget.panelHeaderMinHeight,
                    panelMinHeight: _panelMinHeight,
                    panelMaxHeight: _panelMaxHeight,
                    snapingPoint: widget.snapingPoint,
                    child: GalleryView(
                      mediaController: _controller,
                      headerBackground:
                          widget.panelHeaderBackground ?? widget.background,
                      panelBackground:
                          widget.panelBackground ?? widget.background,
                    ),
                  ),
                ),
              ),

              //
            ],
          );
        }),
      ),
    );

    //
  }
}

///
class CustomMediaController extends ValueNotifier<CustomMediaValue> {
  ///
  CustomMediaController()
      : _panelController = PanelController(),
        _checkKeyboard = ValueNotifier(false),
        super(const CustomMediaValue());

  final PanelController _panelController;
  final ValueNotifier<bool> _checkKeyboard;
  late Completer<List<AssetEntity>> _completer;

  // When clearing all selected entities on changed need to notify current
  // status of last selected asset
  AssetEntity? _lastSelectedEntity;

  Function(AssetEntity entity, bool removed)? _onChanged;
  void Function(List<AssetEntity> entities)? _onSubmitted;

  // Media setting
  MediaSetting? _setting;

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
    value = const CustomMediaValue();
  }

  // When selection is completed
  void _submit() {
    _panelController.closePanel();
    _completer.complete(value.entities);
    _checkKeyboard.value = false;
    _onSubmitted?.call(value.entities);
    value = const CustomMediaValue();
  }

  // When panel closed without any selection
  void _cancel() {
    _panelController.closePanel();
    _completer.complete(<AssetEntity>[]);
    _checkKeyboard.value = false;
    _onSubmitted?.call(<AssetEntity>[]);
    value = const CustomMediaValue();
  }

  //
  void _fromPicker(
    void Function(AssetEntity entity, bool removed)? onChanged,
    final void Function(List<AssetEntity> entities)? onSubmitted,
    MediaSetting setting,
  ) {
    _onChanged = onChanged;
    _onSubmitted = onSubmitted;
    pickMedia(setting: setting);
  }

  /// Pick media
  Future<List<AssetEntity>> pickMedia({MediaSetting? setting}) {
    _completer = Completer<List<AssetEntity>>();
    _checkKeyboard.value = true;
    _setting = MediaSetting(
      albumSubtitle: setting?.albumSubtitle ?? 'Select media',
      maximum: setting?.maximum ?? 20,
      selected: setting?.selected ?? <AssetEntity>[],
    );
    if (setting?.selected?.isNotEmpty ?? false) {
      value = value.copyWith(
        entities: setting?.selected,
        previousSelection: true,
      );
    }
    return _completer.future;
  }

  /// Panel controller
  PanelController get panelController => _panelController;

  /// Media setting
  MediaSetting? get setting => _setting;

  ///
  bool get reachedMaximumLimit => value.entities.length == setting!.maximum;

  @override
  set value(CustomMediaValue newValue) {
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

///
class CustomMediaValue {
  ///
  const CustomMediaValue({
    this.entities = const <AssetEntity>[],
    this.previousSelection = true,
  });

  ///
  final List<AssetEntity> entities;

  ///
  final bool previousSelection;

  ///
  CustomMediaValue copyWith({
    List<AssetEntity>? entities,
    bool? previousSelection,
  }) =>
      CustomMediaValue(
        entities: entities ?? this.entities,
        previousSelection: previousSelection ?? this.previousSelection,
      );

  @override
  String toString() => 'LENGTH  :  ${entities.length} \nLIST  :  $entities';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is CustomMediaValue) {
      if (entities.length != other.entities.length) return false;

      var isIdentical = true;
      for (var i = 0; i < entities.length; i++) {
        if (!isIdentical) return false;
        isIdentical = other.entities[i].id == entities[i].id;
      }
      return true;
    }
    return false;
  }

  @override
  int get hashCode => entities.hashCode;

  // hashValues(
  //       text.hashCode,
  //       selection.hashCode,
  //       composing.hashCode,
  //     );
}
