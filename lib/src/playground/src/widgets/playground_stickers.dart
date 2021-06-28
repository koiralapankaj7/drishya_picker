import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';

// const _initialStickerScale = 0.25;
const _minStickerScale = 0.05;

///
class PlaygroundStickers extends StatefulWidget {
  ///
  const PlaygroundStickers({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final PlaygroundController controller;

  @override
  _PlaygroundStickersState createState() => _PlaygroundStickersState();
}

class _PlaygroundStickersState extends State<PlaygroundStickers> {
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
    final controller = widget.controller;
    final stickerController = controller.stickerController;

    return ValueListenableBuilder<StickerboothValue>(
      valueListenable: stickerController,
      builder: (context, stickerValue, child) {
        if (stickerValue.assets.isEmpty) return const SizedBox();

        return Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              //
              Positioned.fill(
                child: GestureDetector(
                  onTap: stickerController.unselectSticker,
                ),
              ),

              // Stickers
              Stack(
                fit: StackFit.expand,
                children: stickerValue.assets.map((asset) {
                  final isSelected = asset.id == stickerValue.selectedAssetId;
                  return DraggableResizable(
                    key: Key(asset.id),
                    canTransform: isSelected,
                    onTap: () {
                      if (asset.sticker.pathType == StickerPathType.text) {
                        controller.updateValue(hasFocus: true);
                      }
                    },
                    onStart: () {
                      controller.updateValue(isEditing: true);
                    },
                    onEnd: () {
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (_collied) {
                          stickerController.deleteSticker();
                          controller.updateValue(
                            hasStickers: stickerValue.assets.length > 1,
                          );
                          _collied = false;
                        }
                      });
                      controller.updateValue(isEditing: false);
                    },
                    onUpdate: (update, key) {
                      stickerController.dragSticker(
                        asset: asset,
                        update: update,
                      );
                    },
                    onScaleUpdate: _onScaleUpdate,
                    size: asset.sticker.size,
                    constraints: asset.getImageConstraints(),
                    child: Opacity(
                      opacity: isSelected && _collied ? 0.3 : 1.0,
                      child: asset.widget,
                    ),
                  );
                }).toList(),
              ),

              // Delete popup area
              if (controller.value.isEditing)
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

              //
            ],
          ),
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

  Widget? get widget {
    if (sticker.pathType == StickerPathType.networkImg) {
      return Image.network(
        sticker.path!,
        fit: BoxFit.fill,
        gaplessPlayback: true,
      );
    }

    if (sticker.pathType == StickerPathType.assetsImage) {
      return Image.asset(
        sticker.path!,
        fit: BoxFit.fill,
        gaplessPlayback: true,
      );
    }

    if (sticker.pathType == StickerPathType.text) {
      //
    }

    return sticker.widget;
  }
}
