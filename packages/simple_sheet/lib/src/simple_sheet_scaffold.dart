import 'package:flutter/material.dart';
import 'package:simple_sheet/simple_sheet.dart';

///
class SimpleSheetScaffold extends StatefulWidget {
  ///
  const SimpleSheetScaffold({
    required this.child,
    super.key,
  });

  ///
  final Widget child;

  @override
  State<SimpleSheetScaffold> createState() => _SimpleSheetScaffoldState();
}

class _SimpleSheetScaffoldState extends State<SimpleSheetScaffold> {
  // late final GalleryController _controller;
  // late final PanelController _panelController;

  // @override
  // void initState() {
  //   super.initState();
  //   // No need to init controller from here, [GalleryView] will do that for us.
  //   _controller = widget.controller ?? GalleryController();
  //   _panelController = _controller.panelController;
  // }

  // @override
  // void dispose() {
  //   if (widget.controller == null) {
  //     _controller.dispose();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //
        widget.child,
        // Parent view
        // Column(
        //   children: [
        //     //
        //     Expanded(
        //       child: GestureDetector(
        //         behavior: HitTestBehavior.opaque,
        //         onTap: () {
        //           final focusNode = FocusScope.of(context);
        //           if (focusNode.hasFocus) {
        //             focusNode.unfocus();
        //           }
        //           if (_panelController.isVisible) {
        //             _controller.completeTask(context);
        //           }
        //         },
        //         child: widget.child,
        //       ),
        //     ),

        //     // Space for panel min height
        //     ValueListenableBuilder<bool>(
        //       valueListenable: _panelController.panelVisibility,
        //       builder: (context, isVisible, child) {
        //         return SizedBox(
        //           height: showPanel && isVisible ? panelSetting.minHeight : 0.0,
        //         );
        //       },
        //     ),

        //     //
        //   ],
        // ),

        //
        SimpleSheet(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemBuilder: (context, index) {
              return const ColoredBox(color: Colors.amber);
            },
          ),
        ),
        // SlidablePanel(
        //   setting: panelSetting,
        //   controller: _panelController,
        //   child: Builder(
        //     // Builder is used here to pass accurate settings down
        //     // the tree
        //     builder: (_) => GalleryView(
        //       controller: _controller,
        //       setting: _controller.setting
        //           .copyWith(panelSetting: panelSetting),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
