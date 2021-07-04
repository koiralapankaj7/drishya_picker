import 'dart:developer';

import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_grid_view.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_header.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_overlay.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import 'widgets/gallery_album_view.dart';
import 'widgets/gallery_asset_selector.dart';

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

    _controller.albumVisibilityNotifier.addListener(_toogleAlbumList);

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

  void _toogleAlbumList() {
    if (_animationController.isAnimating) return;
    _panelController.isGestureEnabled = _animationController.value == 1.0;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    var s = _controller.panelSetting;
    final _panelMaxHeight =
        (s.maxHeight ?? MediaQuery.of(context).size.height) - (s.topMargin);
    final _panelMinHeight = s.minHeight ?? _panelMaxHeight * 0.35;
    final _setting =
        s.copyWith(maxHeight: _panelMaxHeight, minHeight: _panelMinHeight);

    final albumListHeight = _panelMaxHeight - s.headerMaxHeight;

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
              child: GalleryHeader(controller: _controller),
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
