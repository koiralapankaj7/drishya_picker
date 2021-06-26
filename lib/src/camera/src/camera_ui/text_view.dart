import 'dart:developer';

import 'package:drishya_picker/src/camera/src/camera_ui/builders/action_detector.dart';
import 'package:drishya_picker/src/camera/src/camera_ui/widgets/gradient_background.dart';
import 'package:drishya_picker/src/draggable_resizable/src/controller/stickerbooth_value.dart';
import 'package:drishya_picker/src/draggable_resizable/src/draggable_resizable.dart';
import 'package:drishya_picker/src/draggable_resizable/src/entities/sticker_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'builders/camera_action_provider.dart';

// const _initialStickerScale = 0.25;
const _minStickerScale = 0.05;

///
class TextView extends StatefulWidget {
  ///
  const TextView({
    Key? key,
  }) : super(key: key);

  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: const [
          // background
          GradientBackground(),

          _Stickers(),

          //
        ],
      ),
    );
  }
}

class _Stickers extends StatefulWidget {
  const _Stickers({
    Key? key,
  }) : super(key: key);

  @override
  _StickersState createState() => _StickersState();
}

class _StickersState extends State<_Stickers> {
  final _deleteKey = GlobalKey();

  var _collied = false;

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final deleteBox =
        _deleteKey.currentContext?.findRenderObject() as RenderBox?;

    if (deleteBox != null) {
      final deleteSize = deleteBox.size;

      final deletePos = deleteBox.localToGlobal(Offset.zero);

      final stickerPos = details.focalPoint;

      final collide = (deletePos.dx < stickerPos.dx &&
          deletePos.dx + deleteSize.width > stickerPos.dx &&
          deletePos.dy < stickerPos.dy &&
          deletePos.dy + deleteSize.height > stickerPos.dy);

      setState(() {
        _collied = collide;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActionBuilder(
      builder: (action, value, child) {
        return ValueListenableBuilder<StickerboothValue>(
          valueListenable: action.stickerController,
          builder: (context, stickerValue, child) {
            if (stickerValue.assets.isEmpty) return const SizedBox();

            return Center(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  //
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: action.stickerController.outsideTapped,
                    ),
                  ),

                  // Stickers
                  Stack(
                    fit: StackFit.expand,
                    children: stickerValue.assets.map((asset) {
                      final isSelected =
                          asset.id == stickerValue.selectedAssetId;
                      return DraggableResizable(
                        key: Key(asset.id),
                        canTransform: isSelected,
                        onStart: () {
                          action.updateValue(isEditing: true);
                        },
                        onEnd: () {
                          Future.delayed(const Duration(milliseconds: 50), () {
                            if (_collied) {
                              action.stickerController.deleteSticker();
                              action.updateValue(
                                hasStickers: stickerValue.assets.length > 1,
                              );
                              _collied = false;
                            }
                          });
                          action.updateValue(isEditing: false);
                        },
                        onUpdate: (update, key) {
                          action.stickerController
                              .dragSticker(asset: asset, update: update);
                        },
                        onScaleUpdate: _onScaleUpdate,
                        size: asset.sticker.size,
                        constraints: asset.getImageConstraints(),
                        child: Opacity(
                          opacity: isSelected && _collied ? 0.3 : 1.0,
                          child: Image.network(
                            asset.sticker.path!,
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Delete popup area
                  if (value.editingMode)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        key: _deleteKey,
                        duration: const Duration(milliseconds: 100),
                        height: _collied ? 60.0 : 48.0,
                        width: _collied ? 60.0 : 48.0,
                        margin: const EdgeInsets.only(bottom: 60.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black45,
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: _collied ? 32.0 : 24.0,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

extension on StickerAsset {
  BoxConstraints getImageConstraints() {
    return BoxConstraints(
      minWidth: sticker.size.width * _minStickerScale,
      minHeight: sticker.size.height * _minStickerScale,
      maxWidth: double.infinity,
      maxHeight: double.infinity,
    );
  }
}

///
// Future<void> capturePng() async {
//   final boundary =
//       _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

//   if (boundary != null) {
//     final image = await boundary.toImage();

//     final date = DateTime.now();

//     final entity = AssetEntity(
//       id: date.millisecond.toString(),
//       height: image.height,
//       width: image.width,
//       typeInt: 1,
//       mimeType: 'image/png',
//       createDtSecond: date.second,
//       modifiedDateSecond: date.second,
//     );

//     log('$entity');

//     // final  byteData =
//     //     await image.toByteData(format: ui.ImageByteFormat.png);
//     // final Uint8List pngBytes = byteData!.buffer.asUint8List();
//     // print(pngBytes);
//   }
// }
