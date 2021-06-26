import 'dart:developer';

import 'package:drishya_picker/src/draggable_resizable/src/controller/stickerbooth_value.dart';
import 'package:drishya_picker/src/draggable_resizable/src/draggable_resizable.dart';
import 'package:drishya_picker/src/draggable_resizable/src/entities/sticker_asset.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

///
typedef UuidGetter = String Function();

///
class StickerboothController extends ValueNotifier<StickerboothValue> {
  ///
  StickerboothController([UuidGetter? uuid])
      : uuid = uuid ?? const Uuid().v4,
        super(const StickerboothValue());

  ///
  final UuidGetter uuid;

  ///
  void setStickers(List<StickerAsset> stickers) {
    Future.delayed(const Duration(milliseconds: 16), () {
      value = value.copyWith(
        assets: List.from(stickers),
        selectedAssetId: emptyAssetId,
      );
    });
  }

  /// sticker tapped
  void addSticker(Sticker sticker) {
    final assets = StickerAsset(id: uuid(), sticker: sticker);
    value = value.copyWith(
      assets: List.of(value.assets)..add(assets),
      selectedAssetId: assets.id,
    );
  }

  /// sticker dragged
  void dragSticker({
    required StickerAsset asset,
    required DragUpdate update,
  }) {
    Future.delayed(const Duration(milliseconds: 16), () {
      final assets = List.of(value.assets);
      final index = assets.indexWhere((element) => element.id == asset.id);
      final sticker = assets.removeAt(index);
      assets.add(
        sticker.copyWith(
          angle: update.angle,
          position: StickerPosition(
            dx: update.position.dx,
            dy: update.position.dy,
          ),
          size: StickerSize(
            width: update.size.width,
            height: update.size.height,
          ),
          constraint: StickerConstraint(
            width: update.constraints.width,
            height: update.constraints.height,
          ),
        ),
      );
      value = value.copyWith(assets: assets, selectedAssetId: asset.id);
    });
  }

  /// remove selected sticker
  void deleteSticker() {
    final stickers = List.of(value.assets);
    final index = stickers.indexWhere(
      (element) => element.id == value.selectedAssetId,
    );
    final stickerExists = index != -1;
    if (stickerExists) {
      stickers.removeAt(index);
    }
    value = value.copyWith(
      assets: stickers,
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
