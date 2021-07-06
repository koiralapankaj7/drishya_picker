// import 'package:drishya_picker/src/gallery/src/controllers/gallery_controller.dart';
// import 'package:drishya_picker/src/gallery/src/widgets/gallery_album_view.dart';
// import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
// import 'package:flutter/material.dart';

// import 'gallery_asset_selector.dart';

// ///
// class GalleryOverlay extends StatelessWidget {
//   ///
//   const GalleryOverlay({
//     Key? key,
//     required this.controller,
//     required this.panelSetting,
//   }) : super(key: key);

//   ///
//   final GalleryController controller;

//   ///
//   final PanelSetting panelSetting;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // Send and edit button
//         Positioned(
//           bottom: 0.0,
//           child: GalleryAssetSelector(controller: controller),
//         ),

//         // Album List
//         GalleryAlbumView(controller: controller, panelSetting: panelSetting),

//         //
//       ],
//     );
//   }
// }
