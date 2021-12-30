import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/gallery/src/widgets/widgets.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/material.dart';

///
class SlidableGallery extends StatefulWidget {
  ///
  const SlidableGallery({
    Key? key,
    required this.child,
    this.controller,
    this.setting,
  }) : super(key: key);

  /// Child
  final Widget child;

  /// Gallery controller
  final GalleryController? controller;

  /// Panel setting
  final PanelSetting? setting;

  @override
  State<SlidableGallery> createState() => _SlidableGalleryState();
}

class _SlidableGalleryState extends State<SlidableGallery> {
  late final GalleryController _controller;
  late final PanelController _panelController;

  @override
  void initState() {
    super.initState();
    // No need to init controller from here, [GalleryView] will do that for us.
    _controller = widget.controller ?? GalleryController();
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
    return Material(
      key: _controller.panelKey,
      child: GalleryControllerProvider(
        controller: _controller,
        child: PanelSettingBuilder(
          setting: widget.setting,
          builder: (panelSetting) {
            final showPanel = MediaQuery.of(context).viewInsets.bottom == 0.0;
            return Stack(
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
                            _controller.completeTask(context);
                          }
                        },
                        child: widget.child,
                      ),
                    ),

                    // Space for panel min height
                    ValueListenableBuilder<bool>(
                      valueListenable: _panelController.panelVisibility,
                      builder: (context, isVisible, child) {
                        return SizedBox(
                          height: showPanel && isVisible
                              ? panelSetting.minHeight
                              : 0.0,
                        );
                      },
                    ),

                    //
                  ],
                ),

                // Gallery
                SlidablePanel(
                  setting: panelSetting,
                  controller: _panelController,
                  child: Builder(
                    // Builder is used here to pass accurate settings down
                    // the tree
                    builder: (_) => GalleryView(
                      controller: _controller,
                      setting: _controller.setting
                          .copyWith(panelSetting: panelSetting),
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
