import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_header.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import 'widgets/gallery_album_view.dart';
import 'widgets/gallery_asset_selector.dart';
import 'widgets/gallery_grid_view.dart';

///
class GalleryView extends StatefulWidget {
  ///
  const GalleryView({
    Key? key,
    this.controller,
  }) : super(key: key);

  ///
  final GalleryController? controller;

  ///
  static const String name = 'GalleryView';

  ///
  static Future<List<AssetEntity>?> pick(BuildContext context) {
    return Navigator.of(context).push<List<AssetEntity>>(
      SlideTransitionPageRoute(
        builder: const GalleryView(),
        transitionCurve: Curves.easeIn,
        settings: const RouteSettings(name: name),
      ),
    );
  }

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView>
    with SingleTickerProviderStateMixin {
  late final GalleryController _controller;
  late final PanelController _panelController;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? GalleryController());

    _panelController = _controller.panelController;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      reverseDuration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastLinearToSlowEaseIn,
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  void _toogleAlbumList(bool visible) {
    if (_animationController.isAnimating) return;
    _controller.setAlbumVisibility(!visible);
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
      actionsPadding: const EdgeInsets.all(0.0),
      titlePadding: const EdgeInsets.all(16.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
    );

    showDialog<void>(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  void _onClosePressed() {
    if (_animationController.isAnimating) return;
    final value = _controller.value;
    if (_controller.albumVisibilityNotifier.value) {
      _toogleAlbumList(true);
    } else if (value.selectedEntities.isNotEmpty) {
      _showAlert();
    } else {
      if (_controller.fullScreenMode) {
        Navigator.of(context).pop();
      } else {
        _controller.panelController.minimizePanel();
      }
    }
  }

  void _onSelectionClear() {
    _controller.clearSelection();
    Navigator.of(context).pop();
  }

  void _onALbumChange(AssetPathEntity album) {
    if (_animationController.isAnimating) return;
    _controller.repository.fetchAssetsFor(album);
    _toogleAlbumList(true);
  }

  @override
  Widget build(BuildContext context) {
    var ps = _controller.panelSetting;
    final _panelMaxHeight = ps.maxHeight ??
        MediaQuery.of(context).size.height - (ps.topMargin ?? 0.0);
    final _panelMinHeight = ps.minHeight ?? _panelMaxHeight * 0.35;
    final _setting =
        ps.copyWith(maxHeight: _panelMaxHeight, minHeight: _panelMinHeight);

    final albumListHeight = _panelMaxHeight - ps.headerMaxHeight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _setting.overlayStyle,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            // Header
            Align(
              alignment: Alignment.topCenter,
              child: GalleryHeader(
                controller: _controller,
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

                    return ValueListenableBuilder<SliderValue>(
                      valueListenable: _panelController,
                      builder: (context, SliderValue value, child) {
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
                  height: 2.0,
                ),

                // Gallery grid
                Expanded(child: GalleryGridView(controller: _controller)),
              ],
            ),

            // Send and edit button
            Positioned(
              bottom: 0.0,
              child: GalleryAssetSelector(controller: _controller),
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
              child: SizedBox(
                height: albumListHeight,
                child: GalleryAlbumView(
                  controller: _controller,
                  onAlbumChange: _onALbumChange,
                ),
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}
