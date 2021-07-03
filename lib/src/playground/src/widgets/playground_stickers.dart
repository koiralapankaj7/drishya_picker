import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';

import '../controller/playground_controller.dart';

const _minStickerScale = 1.0;

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
  late final GlobalKey _deleteKey;
  late final PlaygroundController _controller;
  var _collied = false;

  @override
  void initState() {
    super.initState();
    _deleteKey = GlobalKey();
    _controller = widget.controller;
  }

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

  Widget? _stickerChild(Sticker sticker) {
    if (sticker is ImageSticker && sticker.pathType == PathType.networkImg) {
      return Image.network(
        sticker.path,
        fit: BoxFit.fill,
        gaplessPlayback: true,
      );
    } else if (sticker is ImageSticker &&
        sticker.pathType == PathType.assetsImage) {
      return Image.asset(
        sticker.path,
        fit: BoxFit.fill,
        gaplessPlayback: true,
      );
    } else if (sticker is TextSticker) {
      return Container(
        constraints: BoxConstraints.loose(sticker.size),
        decoration: BoxDecoration(
          color: sticker.withBackground
              ? _controller.value.textBackground.colors.first
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FittedBox(
          alignment: Alignment.center,
          child: Text(
            sticker.text,
            textAlign: sticker.textAlign,
            style: sticker.style,
          ),
        ),
      );
    } else if (sticker is WidgetSticker) {
      return sticker.child;
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stickerController = _controller.stickerController;

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
                      asset.sticker.onPressed?.call(asset.sticker);
                      if (asset.sticker is TextSticker) {
                        stickerController.deleteSticker(asset);
                        _controller.updateValue(hasFocus: true);
                      }
                    },
                    onStart: () {
                      _controller.updateValue(isEditing: true);
                    },
                    onEnd: () {
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (_collied) {
                          stickerController.deleteSticker(asset);
                          _controller.updateValue(
                            hasStickers: stickerValue.assets.length > 1,
                          );
                          _collied = false;
                        }
                      });
                      _controller.updateValue(isEditing: false);
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
                      child: _stickerChild(asset.sticker),
                    ),
                  );
                }).toList(),
              ),

              // Delete popup area
              if (_controller.value.isEditing)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    key: _deleteKey,
                    duration: const Duration(milliseconds: 100),
                    height: _collied ? 60.0 : 48.0,
                    width: _collied ? 60.0 : 48.0,
                    margin: const EdgeInsets.only(bottom: 24.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black45,
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: _collied ? 36.0 : 30.0,
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
}
