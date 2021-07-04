import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
import 'package:drishya_picker/src/gallery/src/widgets/gallery_controller_provider.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../gallery_view.dart';

///
class GalleryViewWrapper extends StatefulWidget {
  ///
  const GalleryViewWrapper({
    Key? key,
    required this.child,
    this.controller,
  }) : super(key: key);

  ///
  final Widget child;

  ///
  final GalleryController? controller;

  @override
  _GalleryViewWrapperState createState() => _GalleryViewWrapperState();
}

class _GalleryViewWrapperState extends State<GalleryViewWrapper>
    with WidgetsBindingObserver {
  late final GalleryController _controller;
  late final PanelController _panelController;
  var _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _controller = (widget.controller ?? GalleryController());
    // .._checkKeyboard.addListener(_init);
    _panelController = _controller.panelController;
  }

  // void _init() {
  //   if (_controller._checkKeyboard.value) {
  //     if (_keyboardVisible) {
  //       FocusScope.of(context).unfocus();
  //       Future.delayed(
  //         const Duration(milliseconds: 180),
  //         _panelController.openPanel,
  //       );
  //     } else {
  //       _panelController.openPanel();
  //     }
  //   }
  // }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance?.window.viewInsets.bottom;
    _keyboardVisible = (bottomInset ?? 0.0) > 0.0;
    if (_keyboardVisible && _panelController.isVisible) {
      _controller.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ps = _controller.panelSetting;
    final _panelMaxHeight = ps.maxHeight ??
        MediaQuery.of(context).size.height - (ps.topMargin ?? 0.0);
    final _panelMinHeight = ps.minHeight ?? _panelMaxHeight * 0.35;
    final _setting =
        ps.copyWith(maxHeight: _panelMaxHeight, minHeight: _panelMinHeight);

    return Material(
      key: _controller.wrapperKey,
      child: GalleryControllerProvider(
        controller: _controller,
        child: Stack(
          children: [
            // Parent view
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_panelController.isVisible) {
                        _controller.cancel();
                      }
                    },
                    child: widget.child,
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

            // Gallery view
            SlidablePanel(
              setting: _setting,
              controller: _panelController,
              child: GalleryView(controller: _controller),
            ),

            //
          ],
        ),
      ),
    );

    //
  }
}
