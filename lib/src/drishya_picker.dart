import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

import 'animations/animations.dart';

const Duration _kRouteDuration = Duration(milliseconds: 300);

///
class DrishyaPicker {
  ///
  static Future<AssetEntity?> camera(
    BuildContext context, {
    Duration? videoDuration,
  }) async {
    return Navigator.of(context).push<AssetEntity>(
      SlideTransitionPageRoute(
        builder: CameraPicker(videoDuration: videoDuration),
        transitionCurve: Curves.easeIn,
        transitionDuration: _kRouteDuration,
        reverseTransitionDuration: _kRouteDuration,
      ),
    );
  }

  ///
  static Future<List<AssetEntity>?> gallery(BuildContext context) {
    return Navigator.of(context).push<List<AssetEntity>>(
      SlideTransitionPageRoute(
        builder: const GalleryView(),
        transitionCurve: Curves.easeIn,
      ),
    );
  }
}



// import 'dart:async';

// import 'package:drishya_picker/drishya_picker.dart';
// import 'package:drishya_picker/src/gallery/src/controllers/drishya_repository.dart';
// import 'package:drishya_picker/src/gallery/src/widgets/gallery_grid_view.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:photo_manager/photo_manager.dart';

// import 'camera/src/camera_picker.dart';
// import 'gallery/src/entities/gallery_value.dart';
// import 'gallery/src/widgets/drishya_controller_provider.dart';
// import 'gallery/src/widgets/gallery_header.dart';
// import 'gallery/src/widgets/gallery_album_view.dart';
// import 'gallery/src/widgets/gallery_asset_selector.dart';
// import 'slidable_panel/slidable_panel.dart';

// ///
// class DrishyaPicker extends StatefulWidget {
//   ///
//   const DrishyaPicker({
//     Key? key,
//     this.child,
//     this.controller,
//     this.panelSetting,
//   }) : super(key: key);

//   /// Widget
//   final Widget? child;

//   /// Controller for [DrishyaPicker]
//   final DrishyaController? controller;

//   /// Setting for gallery panel
//   final PanelSetting? panelSetting;

//   @override
//   _DrishyaPickerState createState() => _DrishyaPickerState();
// }

// class _DrishyaPickerState extends State<DrishyaPicker>
//     with WidgetsBindingObserver {
//   late final DrishyaController _controller;
//   late final PanelController _panelController;
//   var _keyboardVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addObserver(this);
//     _controller = (widget.controller ?? DrishyaController())
//       .._checkKeyboard.addListener(_init);
//     _panelController = _controller.panelController;
//   }

//   void _init() {
//     if (_controller._checkKeyboard.value) {
//       if (_keyboardVisible) {
//         FocusScope.of(context).unfocus();
//         Future.delayed(
//           const Duration(milliseconds: 180),
//           _panelController.openPanel,
//         );
//       } else {
//         _panelController.openPanel();
//       }
//     }
//   }

//   @override
//   void didChangeMetrics() {
//     super.didChangeMetrics();
//     final bottomInset = WidgetsBinding.instance?.window.viewInsets.bottom;
//     _keyboardVisible = (bottomInset ?? 0.0) > 0.0;
//     if (_keyboardVisible && _panelController.isVisible) {
//       _cancel();
//     }
//   }

//   void _cancel() {
//     _controller._cancel();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance?.removeObserver(this);
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: DrishyaControllerProvider(
//         controller: _controller,
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final s = widget.panelSetting ?? const PanelSetting();
//             final _panelMaxHeight =
//                 (s.maxHeight ?? constraints.maxHeight) - (s.topMargin);
//             final _panelMinHeight = s.minHeight ?? _panelMaxHeight * 0.35;
//             final _setting = s.copyWith(
//               maxHeight: _panelMaxHeight,
//               minHeight: _panelMinHeight,
//             );
//             return Stack(
//               children: [
//                 // Child i.e, Back view
//                 Column(
//                   children: [
//                     Expanded(
//                       child: GestureDetector(
//                         behavior: HitTestBehavior.opaque,
//                         onTap: () {
//                           if (_panelController.isVisible) {
//                             _cancel();
//                           }
//                         },
//                         child: widget.child ?? const SizedBox(),
//                       ),
//                     ),
//                     ValueListenableBuilder<bool>(
//                       valueListenable: _panelController.panelVisibility,
//                       builder: (context, isVisible, child) {
//                         return isVisible ? child! : const SizedBox();
//                       },
//                       child: SizedBox(height: _panelMinHeight),
//                     ),
//                   ],
//                 ),

//                 // Custom media picker view i.e, Front view
//                 SlidablePanel(
//                   setting: _setting,
//                   controller: _panelController,
//                   child: GalleryPicker(
//                     panelSetting: _setting,
//                     controller: _controller,
//                   ),
//                 ),

//                 //
//               ],
//             );
//           },
//         ),
//       ),
//     );

//     //
//   }
// }

// ///
// class GalleryPicker extends StatefulWidget {
//   ///
//   const GalleryPicker({
//     Key? key,
//     this.controller,
//     this.panelSetting,
//   }) : super(key: key);

//   ///
//   final PanelSetting? panelSetting;

//   ///
//   final DrishyaController? controller;

//   ///
//   static const String name = 'GalleryView';

//   @override
//   _GalleryPickerState createState() => _GalleryPickerState();
// }

// class _GalleryPickerState extends State<GalleryPicker>
//     with SingleTickerProviderStateMixin {
//   late final PanelController _panelController;
//   late final DrishyaController _controller;

//   late final DrishyaRepository _repository;
//   late final ValueNotifier<bool> _dropdownNotifier;
//   late final ValueNotifier<AlbumsType> _albumsNotifier;
//   late final ValueNotifier<AlbumType> _albumNotifier;
//   late final ValueNotifier<EntitiesType> _entitiesNotifier;

//   late final AnimationController _animationController;
//   late final Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? DrishyaController();
//     _panelController = _controller.panelController;

//     _dropdownNotifier = ValueNotifier<bool>(true);
//     _albumsNotifier = ValueNotifier(const BaseState());
//     _albumNotifier = ValueNotifier(const BaseState());
//     _entitiesNotifier = ValueNotifier(const BaseState());

//     // _repository = DrishyaRepository(
//     //   albumsNotifier: _albumsNotifier,
//     //   albumNotifier: _albumNotifier,
//     //   entitiesNotifier: _entitiesNotifier,
//     // );

//     // _repository.fetchAlbums(_controller.setting.requestType);

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//       value: 0.0,
//     );

//     _animation = Tween(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.fastOutSlowIn,
//         reverseCurve: Curves.decelerate,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _dropdownNotifier.dispose();
//     _albumsNotifier.dispose();
//     _albumNotifier.dispose();
//     _entitiesNotifier.dispose();
//     super.dispose();
//   }

//   void _toogleAlbumList() {
//     if (_animationController.isAnimating) return;
//     _panelController.isGestureEnabled = _animationController.value == 1.0;
//     if (_animationController.value == 1.0) {
//       _animationController.reverse();
//     } else {
//       _animationController.forward();
//     }
//   }

//   void _onClosePressed() {
//     if (_animationController.isAnimating) return;
//     if (_animationController.value == 1.0) {
//       _animationController.reverse();
//       _panelController.isGestureEnabled = true;
//     } else {
//       if (_controller.fullScreenMode) {
//         _controller._submit(context);
//       } else {
//         _panelController.minimizePanel();
//       }
//     }
//   }

//   void _onSelectionClear() {
//     _controller._clearSelection();
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var s = widget.panelSetting ?? const PanelSetting();
//     final _panelMaxHeight =
//         (s.maxHeight ?? MediaQuery.of(context).size.height) - (s.topMargin);
//     final _panelMinHeight = s.minHeight ?? _panelMaxHeight * 0.35;
//     final _setting =
//         s.copyWith(maxHeight: _panelMinHeight, minHeight: _panelMinHeight);
//     final albumListHeight = _panelMaxHeight - s.headerMaxHeight;

//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: _setting.overlayStyle,
//       child: Scaffold(
//         body: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // Header
//             // GalleryAlbumChanger(
//             //   controller: _controller,
//             //   albumNotifier: _albumNotifier,
//             //   dropdownNotifier: _dropdownNotifier,
//             //   panelSetting: _setting,
//             //   toogleAlbumList: _toogleAlbumList,
//             //   onClosePressed: _onClosePressed,
//             //   headerSubtitle: _controller.setting.albumSubtitle,
//             //   onSelectionClear: _onSelectionClear,
//             // ),

//             // Body
//             Column(
//               children: [
//                 // Space for header
//                 if (!_controller._fullScreenMode)
//                   ValueListenableBuilder<SliderValue>(
//                     valueListenable: _panelController,
//                     builder: (context, SliderValue value, child) {
//                       final num height = (_setting.headerMinHeight +
//                               (_setting.headerMaxHeight -
//                                       _setting.headerMinHeight) *
//                                   value.factor *
//                                   1.2)
//                           .clamp(
//                         _setting.headerMinHeight,
//                         _setting.headerMaxHeight,
//                       );
//                       return SizedBox(height: height as double?);
//                     },
//                   ),

//                 if (_controller._fullScreenMode)
//                   SizedBox(height: _setting.headerMaxHeight),

//                 // Gallery view
//                 // Expanded(
//                 //   child: GalleryGridView(
//                 //     controller: _controller,
//                 //     panelSetting: _setting,
//                 //     entitiesNotifier: _entitiesNotifier,
//                 //     onCameraPressed: _controller._openCameraFromGallery,
//                 //     onMediaSelect: _controller._select,
//                 //   ),
//                 // ),

//                 //
//               ],
//             ),

//             // Send and edit button
//             // Positioned(
//             //   bottom: 0.0,
//             //   child: GalleryAssetSelector(
//             //     controller: _controller,
//             //     onEdit: (context) {},
//             //     onSubmit: _controller._submit,
//             //   ),
//             // ),

//             // Album List
//             // AnimatedBuilder(
//             //   animation: _animation,
//             //   builder: (context, child) {
//             //     return Positioned(
//             //       bottom: albumListHeight * (_animation.value - 1),
//             //       left: 0.0,
//             //       right: 0.0,
//             //       child: child!,
//             //     );
//             //   },
//             //   child: GalleryAlbumView(
//             //     height: albumListHeight,
//             //     albumsNotifier: _albumsNotifier,
//             //     onPressed: (album) {
//             //       _toogleAlbumList();
//             //       _repository.fetchAssetsFor(album);
//             //       _dropdownNotifier.value = !_dropdownNotifier.value;
//             //     },
//             //   ),
//             // ),

//             //
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Widget which pick media from gallery
// class GalleryPickerField extends StatelessWidget {
//   ///
//   const GalleryPickerField({
//     Key? key,
//     this.onChanged,
//     this.onSubmitted,
//     this.setting,
//     this.child,
//   }) : super(key: key);

//   ///
//   /// While picking drishya using gallery removed will be true if,
//   /// previously selected drishya is unselected otherwise false.
//   ///
//   final void Function(AssetEntity entity, bool removed)? onChanged;

//   ///
//   /// Triggered when picker complet its task.
//   ///
//   final void Function(List<AssetEntity> entities)? onSubmitted;

//   ///
//   /// Setting for drishya picker
//   final GallerySetting? setting;

//   ///
//   final Widget? child;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         (context.drishyaController ?? DrishyaController())._openGallery(
//           onChanged,
//           onSubmitted,
//           setting,
//           context,
//         );
//       },
//       child: child,
//     );
//   }
// }

// ///
// /// Widget to pick media using camera
// class CameraPickerField extends StatelessWidget {
//   ///
//   const CameraPickerField({
//     Key? key,
//     this.onCapture,
//     this.child,
//   }) : super(key: key);

//   ///
//   /// Triggered when picker capture media
//   ///
//   final void Function(AssetEntity entity)? onCapture;

//   ///
//   final Widget? child;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         DrishyaController()._openCamera(onCapture, context);
//       },
//       child: child,
//     );
//   }
// }

// ///
// class DrishyaController extends ValueNotifier<GalleryValue> {
//   ///
//   /// Drishya controller
//   DrishyaController()
//       : _panelController = PanelController(),
//         _checkKeyboard = ValueNotifier(false),
//         super(const GalleryValue());

//   // Flag to handle updating controller value internally
//   var _internal = false;

//   // Panel controller
//   final PanelController _panelController;

//   // Handling keyboard and collapsable gallery view
//   final ValueNotifier<bool> _checkKeyboard;

//   // Completer for gallerry picker controller
//   late Completer<List<AssetEntity>> _completer;

//   // Flag for handling when user cleared all selected medias
//   var _clearedSelection = false;

//   // Gallery picker on changed event callback handler
//   void Function(AssetEntity entity, bool removed)? _onChanged;

//   //  Gallery picker on submitted event callback handler
//   void Function(List<AssetEntity> entities)? _onSubmitted;

//   // Media setting
//   GallerySetting _setting = const GallerySetting();

//   // Full screen mode or collapsable mode
//   var _fullScreenMode = false;

//   // Clear selected entities
//   void _clearSelection() {
//     _onSubmitted?.call([]);
//     _clearedSelection = true;
//     _internal = true;
//     value = const GalleryValue();
//   }

//   // Selecting and unselecting entities
//   void _select(AssetEntity entity, BuildContext context) {
//     if (singleSelection) {
//       _handelSingleSelection(context, entity);
//     } else {
//       _clearedSelection = false;
//       final selectedList = value.selectedEntities.toList();
//       if (selectedList.contains(entity)) {
//         selectedList.remove(entity);
//         _onChanged?.call(entity, true);
//       } else {
//         if (reachedMaximumLimit) {
//           ScaffoldMessenger.of(context)
//             ..clearSnackBars()
//             ..showSnackBar(SnackBar(
//                 content: Text(
//               'Maximum selection limit of '
//               '${setting.maximum} has been reached!',
//             )));
//           return;
//         }
//         selectedList.add(entity);
//         _onChanged?.call(entity, false);
//       }
//       _internal = true;
//       value = value.copyWith(
//         selectedEntities: selectedList,
//         previousSelection: false,
//       );
//     }
//   }

//   // Single selection handler
//   void _handelSingleSelection(BuildContext context, AssetEntity entity) {
//     _onChanged?.call(entity, false);
//     _submit(context, entities: [...setting.selectedItems, entity]);
//   }

//   // When selection is completed
//   void _submit(BuildContext context, {List<AssetEntity>? entities}) {
//     if (_fullScreenMode) {
//       Navigator.of(context).pop();
//     } else {
//       _panelController.closePanel();
//       _checkKeyboard.value = false;
//     }
//     _onSubmitted?.call(entities ?? value.selectedEntities);
//     _completer.complete(entities ?? value.selectedEntities);
//     _internal = true;
//     value = const GalleryValue();
//   }

//   // When panel closed without any selection
//   void _cancel() {
//     _panelController.closePanel();
//     final entities = (_clearedSelection || value.selectedEntities.isEmpty)
//         ? <AssetEntity>[]
//         : setting.selectedItems;
//     _completer.complete(entities);
//     _onSubmitted?.call(entities);
//     _checkKeyboard.value = false;
//     _internal = true;
//     value = const GalleryValue();
//   }

//   /// Close collapsable panel if camera is selected from inside gallery view
//   void _closeOnCameraSelect() {
//     _panelController.closePanel();
//     _checkKeyboard.value = false;
//     _internal = true;
//     value = const GalleryValue();
//   }

//   /// Open camera from [GalleryPicker]
//   void _openCameraFromGallery(BuildContext context) async {
//     AssetEntity? entity;
//     if (_fullScreenMode) {
//       final e = await Navigator.of(context).pushReplacement(
//         _route<AssetEntity?>(const CameraPicker(), horizontal: true),
//       );
//       entity = e;
//     } else {
//       final e = await Navigator.of(context).push(
//         _route<AssetEntity?>(const CameraPicker(), horizontal: true),
//       );
//       _closeOnCameraSelect();
//       entity = e;
//     }
//     if (entity != null) {
//       _onChanged?.call(entity, false);
//       final items = [...setting.selectedItems, entity];
//       _onSubmitted?.call(items);
//       _completer.complete(items);
//     }
//   }

//   /// Open camera from [CameraPicker]
//   void _openCamera(
//     final void Function(AssetEntity entity)? onCapture,
//     BuildContext context,
//   ) async {
//     final entity = await pickFromCamera(context);
//     if (entity != null) {
//       onCapture?.call(entity);
//     }
//   }

//   /// Open gallery from [GalleryPicker]
//   void _openGallery(
//     void Function(AssetEntity entity, bool removed)? onChanged,
//     final void Function(List<AssetEntity> entities)? onSubmitted,
//     GallerySetting? setting,
//     BuildContext context,
//   ) {
//     _onChanged = onChanged;
//     _onSubmitted = onSubmitted;
//     pickFromGallery(context, setting: setting);
//   }

//   /// Pick drishya using camera
//   Future<AssetEntity?> pickFromCamera(BuildContext context) async {
//     final entity = CameraPicker.pick(context);
//     // await Navigator.of(context).push(
//     //   _route<AssetEntity?>(const CameraView(), name: CameraView.name),
//     // );
//     return entity;
//   }

//   /// Pick drishya using gallery
//   Future<List<AssetEntity>?> pickFromGallery(
//     BuildContext context, {
//     GallerySetting? setting,
//   }) async {
//     if (setting != null) {
//       _setting = setting;
//     }
//     if (_setting.selectedItems.isNotEmpty) {
//       _internal = true;
//       value = value.copyWith(
//         selectedEntities: _setting.selectedItems,
//         previousSelection: true,
//       );
//     }
//     _completer = Completer<List<AssetEntity>>();
//     if (context.drishyaController == null) {
//       _fullScreenMode = true;
//       await Navigator.of(context).push(
//         _route<List<AssetEntity>?>(
//           GalleryPicker(controller: this),
//           name: GalleryPicker.name,
//         ),
//       );
//       if (value.selectedEntities.isEmpty) {
//         //
//       }
//     } else {
//       _fullScreenMode = false;
//       _checkKeyboard.value = true;
//     }
//     return _completer.future;
//   }

//   /// return true if drishya picker is in full screen mode,
//   bool get fullScreenMode => _fullScreenMode;

//   /// Panel controller
//   PanelController get panelController => _panelController;

//   /// Media setting
//   GallerySetting get setting => _setting;

//   /// return true if selected media reached to maximum selection limit
//   bool get reachedMaximumLimit =>
//       value.selectedEntities.length == setting.maximum;

//   ///
//   bool get singleSelection => setting.maximum == 1;

//   @override
//   set value(GalleryValue newValue) {
//     if (_internal) {
//       super.value = newValue;
//       _internal = false;
//     }
//   }

//   @override
//   void dispose() {
//     _checkKeyboard.dispose();
//     _panelController.dispose();
//     super.dispose();
//   }

//   //
// }

// /// Camera and gallery route
// Route<T> _route<T>(
//   Widget page, {
//   bool horizontal = false,
//   String name = '',
// }) {
//   return PageRouteBuilder<T>(
//     pageBuilder: (context, animation, secondaryAnimation) => page,
//     settings: RouteSettings(name: name),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       var begin = horizontal ? const Offset(1.0, 0.0) : const Offset(0.0, 1.0);
//       var end = Offset.zero;
//       var curve = Curves.ease;
//       var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//       return SlideTransition(
//         position: animation.drive(tween),
//         child: child,
//       );
//     },
//   );
// }
