import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

const _defaultMin = 0.37;

///
class SlidableGalleryView extends StatefulWidget {
  ///
  const SlidableGalleryView({
    Key? key,
    required this.child,
    this.controller,
    this.setting,
  }) : super(key: key);

  /// Child
  final Widget child;

  /// Gallery controller
  final GalleryController? controller;

  /// Gallery setting
  final GallerySetting? setting;

  @override
  State<SlidableGalleryView> createState() => _SlidableGalleryViewState();
}

class _SlidableGalleryViewState extends State<SlidableGalleryView> {
  late final GalleryController _controller;
  late final PanelController _panelController;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? GalleryController())
      ..init(setting: widget.setting);
    _panelController = _controller.panelController;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ps = _controller.panelSetting;
    final _panelMaxHeight = ps.maxHeight ??
        MediaQuery.of(context).size.height - (ps.topMargin ?? 0.0);
    final _panelMinHeight = ps.minHeight ?? _panelMaxHeight * _defaultMin;
    final _setting =
        ps.copyWith(maxHeight: _panelMaxHeight, minHeight: _panelMinHeight);

    final showPanel = MediaQuery.of(context).viewInsets.bottom == 0.0;

    return Material(
      key: _controller.panelKey,
      child: GalleryControllerProvider(
        controller: _controller,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Parent view
            Column(
              children: [
                //
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final focusNode = FocusScope.of(context);
                      if (focusNode.hasFocus) {
                        focusNode.unfocus();
                      }
                      if (_panelController.isVisible) {
                        _controller.closeSlidableGallery();
                      }
                    },
                    child: Builder(builder: (_) => widget.child),
                  ),
                ),

                // Space for panel min height
                ValueListenableBuilder<bool>(
                  valueListenable: _panelController.panelVisibility,
                  builder: (context, isVisible, child) {
                    return SizedBox(
                      height: showPanel && isVisible ? _panelMinHeight : 0.0,
                    );
                  },
                ),

                //
              ],
            ),

            // Gallery
            SlidablePanel(
              setting: _setting,
              controller: _panelController,
              child: Builder(
                builder: (_) => GalleryView(
                  controller: _controller,
                  setting: widget.setting,
                ),
              ),
            ),

            //
          ],
        ),
      ),
    );

    //
  }
}
