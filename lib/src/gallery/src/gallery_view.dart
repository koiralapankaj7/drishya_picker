import 'dart:async';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/repo/gallery_repository.dart';
import 'package:drishya_picker/src/gallery/src/widgets/albums_page.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_asset_selector.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_grid_view.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _defaultMin = 0.37;

///
///
class GalleryView extends StatefulWidget {
  ///
  const GalleryView({
    Key? key,
    this.controller,
    this.setting,
  }) : super(key: key);

  /// Gallery controller
  final GalleryController? controller;

  /// Gallery setting
  final GallerySetting? setting;

  ///
  static const String name = 'GalleryView';

  ///
  /// Pick media
  ///
  static Future<List<DrishyaEntity>?> pick(
    BuildContext context, {

    /// Gallery controller
    GalleryController? controller,

    /// Gallery setting
    GallerySetting? setting,
  }) {
    return Navigator.of(context).push<List<DrishyaEntity>>(
      SlideTransitionPageRoute(
        builder: GalleryView(controller: controller, setting: setting),
        transitionCurve: Curves.easeIn,
        settings: const RouteSettings(name: name),
      ),
    );
  }

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView>
    with SingleTickerProviderStateMixin {
  late final GalleryController _controller;
  late final PanelController _panelController;

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final Albums _albums;

  double albumHeight = 0;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ?? GalleryController())
      ..init(setting: widget.setting);

    _albums = Albums()..fetchAlbums(_controller.setting.requestType);

    _panelController = _controller.panelController;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 300),
      value: 0,
    );

    // ignore: prefer_int_literals
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _albums.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toogleAlbumList(bool isVisible) {
    if (_animationController.isAnimating) return;
    _controller.setAlbumVisibility(visible: !isVisible);
    _panelController.isGestureEnabled = _animationController.value == 1.0;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  //
  void _showAlert() {
    final cancel = TextButton(
      onPressed: Navigator.of(context).pop,
      child: Text(
        'CANCEL',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.lightBlue,
            ),
      ),
    );
    final unselectItems = TextButton(
      onPressed: _onSelectionClear,
      child: Text(
        'USELECT ITEMS',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.blue,
            ),
      ),
    );

    final alertDialog = AlertDialog(
      title: Text(
        'Unselect these items?',
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Colors.white70,
            ),
      ),
      content: Text(
        'Going back will undo the selections you made.',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
      actions: [cancel, unselectItems],
      backgroundColor: Colors.grey.shade900,
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
    );

    showDialog<void>(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  Future<bool> _onClosePressed() async {
    if (_animationController.isAnimating) return false;

    if (_controller.albumVisibility.value) {
      _toogleAlbumList(true);
      return false;
    }

    if (_controller.value.selectedEntities.isNotEmpty) {
      _showAlert();
      return false;
    }

    if (_controller.fullScreenMode) {
      Navigator.of(context).pop();
      return true;
    }

    final isPanelMax = _panelController.value.state == PanelState.max;

    if (!_controller.fullScreenMode && isPanelMax) {
      _panelController.minimizePanel();
      return false;
    }

    return true;
  }

  void _onSelectionClear() {
    _controller.clearSelection();
    Navigator.of(context).pop();
  }

  void _onAlbumChange(Album album) {
    if (_animationController.isAnimating) return;
    _albums.changeAlbum(album);
    _toogleAlbumList(true);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final ps = _controller.panelSetting;
    final _panelMaxHeight = ps.maxHeight ??
        mediaQuery.size.height - (ps.topMargin ?? mediaQuery.padding.top);
    final _panelMinHeight = ps.minHeight ?? _panelMaxHeight * _defaultMin;
    final _setting =
        ps.copyWith(maxHeight: _panelMaxHeight, minHeight: _panelMinHeight);

    final albumListHeight = _panelMaxHeight - ps.headerMaxHeight;
    albumHeight = albumListHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _setting.overlayStyle,
      child: WillPopScope(
        onWillPop: _onClosePressed,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            // fit: StackFit.expand,
            children: [
              // Header
              Align(
                alignment: Alignment.topCenter,
                child: GalleryHeader(
                  controller: _controller,
                  albums: _albums,
                  onClose: _onClosePressed,
                  onAlbumToggle: _toogleAlbumList,
                ),
              ),

              // Body
              Column(
                children: [
                  // Header space
                  Builder(
                    builder: (context) {
                      if (_controller.fullScreenMode) {
                        return SizedBox(height: _setting.headerMaxHeight);
                      }

                      return ValueListenableBuilder<PnaelValue>(
                        valueListenable: _panelController,
                        builder: (context, PnaelValue value, child) {
                          final height = (_setting.headerMinHeight +
                                  (_setting.headerMaxHeight -
                                          _setting.headerMinHeight) *
                                      value.factor *
                                      1.2)
                              .clamp(
                            _setting.headerMinHeight,
                            _setting.headerMaxHeight,
                          );
                          return SizedBox(height: height);
                        },
                      );
//
                    },
                  ),

                  // Divider
                  Divider(
                    color: Colors.lightBlue.shade300,
                    thickness: 0.3,
                    height: 2,
                  ),

                  // Gallery grid
                  Expanded(
                    child: GalleryGridView(
                      controller: _controller,
                      albums: _albums,
                    ),
                  ),
                ],
              ),

              // Send and edit button
              GalleryAssetSelector(controller: _controller),

              // Album list
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final offsetY = _setting.headerMaxHeight +
                      (_panelMaxHeight - ps.headerMaxHeight) *
                          (1 - _animation.value);
                  return Visibility(
                    visible: _animation.value > 0.0,
                    child: Transform.translate(
                      offset: Offset(0, offsetY),
                      child: child,
                    ),
                  );
                },
                child: AlbumsPage(
                  albums: _albums,
                  controller: _controller,
                  onAlbumChange: _onAlbumChange,
                ),
              ),

              //
            ],
          ),
        ),
      ),
    );
  }
}
