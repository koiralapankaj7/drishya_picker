import 'package:drishya_picker/src/draggable_resizable/src/controller/stickerbooth_value.dart';
import 'package:drishya_picker/src/draggable_resizable/src/draggable_resizable.dart';
import 'package:drishya_picker/src/draggable_resizable/src/entities/photo_asset.dart';
import 'package:flutter/material.dart';

///
class StickerboothController extends ValueNotifier<StickerboothValue> {
  ///
  StickerboothController() : super(const StickerboothValue());

  /// sticker tapped
  void addSticker(Asset sticker) {
    final newSticker = PhotoAsset(id: '1', asset: sticker);
    final list = List.of(value.stickers)..add(newSticker);
    value = value.copyWith(
      stickers: list,
      selectedAssetId: newSticker.id,
    );
  }

  /// sticker dragged
  void dragSticker({
    required PhotoAsset sticker,
    required DragUpdate update,
  }) {
    final asset = sticker;
    final stickers = List.of(value.stickers);
    final index = stickers.indexWhere((element) => element.id == asset.id);
    final removedSticker = stickers.removeAt(index);
    stickers.add(
      removedSticker.copyWith(
        angle: update.angle,
        position: PhotoAssetPosition(
          dx: update.position.dx,
          dy: update.position.dy,
        ),
        size: PhotoAssetSize(
          width: update.size.width,
          height: update.size.height,
        ),
        constraint: PhotoConstraint(
          width: update.constraints.width,
          height: update.constraints.height,
        ),
      ),
    );
    value = value.copyWith(stickers: stickers, selectedAssetId: asset.id);
  }

  /// remove selected sticker
  void deleteSticker() {
    final stickers = List.of(value.stickers);
    final index = stickers.indexWhere(
      (element) => element.id == value.selectedAssetId,
    );
    final stickerExists = index != -1;
    if (stickerExists) {
      stickers.removeAt(index);
    }
    value = value.copyWith(
      stickers: stickers,
      selectedAssetId: emptyAssetId,
    );
  }

  /// clear stickers tapped
  void clearStickers() {}

  /// PhotoTapped
  void outsideTapped() {
    value = value.copyWith(selectedAssetId: emptyAssetId);
  }
}
