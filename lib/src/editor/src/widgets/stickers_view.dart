import 'package:drishya_picker/src/editor/editor.dart';
import 'package:drishya_picker/src/editor/src/widgets/widgets.dart';
import 'package:flutter/material.dart';

const _minStickerScale = 1.0;

///
class StickersView extends StatefulWidget {
  ///
  const StickersView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  @override
  State<StickersView> createState() => _StickersViewState();
}

class _StickersViewState extends State<StickersView> {
  late final GlobalKey _deleteKey;
  late final DrishyaEditingController _controller;
  var _collied = false;

  @override
  void initState() {
    super.initState();
    _deleteKey = GlobalKey();
    _controller = widget.controller;
  }

  // On tap outside of the stickers
  void _onTapOutside() {
    _controller.stickerController.unselectSticker();
    if (_controller.value.isColorPickerOpen) {
      _controller.updateValue(isColorPickerOpen: false);
    }
  }

  // On sticker select
  void _onStickerSelect(StickerAsset asset, DraggableResizableState state) {
    if (asset.sticker is TextSticker) {
      _controller.currentAssetState.value = state;
      _controller.currentAsset.value = asset;
      _controller.textController.text = (asset.sticker as TextSticker).text;
      _controller.stickerController.deleteSticker(asset);
    }
    _controller.updateValue(
      hasFocus: asset.sticker is TextSticker,
      isColorPickerOpen: asset.sticker is IconSticker,
    );
  }

  // On updating sticker position/scale/rotation
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final deleteBox =
        _deleteKey.currentContext?.findRenderObject() as RenderBox?;

    if (deleteBox != null) {
      final deleteSize = deleteBox.size;

      final deletePos = deleteBox.localToGlobal(Offset.zero);

      final stickerPos = details.focalPoint;

      final collide = deletePos.dx < stickerPos.dx &&
          deletePos.dx + deleteSize.width > stickerPos.dx &&
          deletePos.dy < stickerPos.dy &&
          deletePos.dy + deleteSize.height > stickerPos.dy;
      setState(() {
        _collied = collide;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stickerController = _controller.stickerController;

    return ValueListenableBuilder<StickerValue>(
      valueListenable: stickerController,
      builder: (context, stickerValue, child) {
        if (stickerValue.assets.isEmpty) {
          return const SizedBox();
        }

        return Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // For outside tap
              Positioned.fill(child: GestureDetector(onTap: _onTapOutside)),

              // Stickers
              Stack(
                fit: StackFit.expand,
                children: stickerValue.assets.map((asset) {
                  final isSelected = asset.id == stickerValue.selectedAssetId;
                  return DraggableResizable(
                    key: Key(asset.id),
                    canTransform: isSelected,
                    onTap: (DraggableResizableState state) =>
                        _onStickerSelect(asset, state),
                    onStart: () {
                      _controller.updateValue(isEditing: true);
                    },
                    onEnd: () {
                      Future.delayed(const Duration(milliseconds: 50), () {
                        if (_collied) {
                          _controller.stickerController.deleteSticker(asset);
                          _controller.updateValue(
                            hasStickers: stickerValue.assets.length > 1,
                          );
                          _collied = false;
                        }
                      });
                      _controller.updateValue(isEditing: false);
                    },
                    onUpdate: (update, key) {
                      _controller.stickerController.dragSticker(
                        asset: asset,
                        update: update,
                      );
                    },
                    onScaleUpdate: _onScaleUpdate,
                    constraints: BoxConstraints(
                      minWidth: asset.sticker.size.width * _minStickerScale,
                      minHeight: asset.sticker.size.height * _minStickerScale,
                    ),
                    size: asset.sticker.size,
                    initialPosition: asset.position.offset,
                    initialAngle: asset.angle,
                    initialScale: asset.scale,
                    child: Opacity(
                      opacity: isSelected && _collied ? 0.3 : 1.0,
                      child: asset.sticker
                          .build(context, _controller, null, asset),
                    ),
                  );
                }).toList(),
              ),

              // Delete popup area
              if (_controller.value.isEditing &&
                  !_controller.value.isStickerPickerOpen)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    key: _deleteKey,
                    duration: const Duration(milliseconds: 100),
                    height: _collied ? 60.0 : 48.0,
                    width: _collied ? 60.0 : 48.0,
                    margin: const EdgeInsets.only(bottom: 24),
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
