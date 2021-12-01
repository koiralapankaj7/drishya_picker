import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

///
typedef UuidGetter = String Function();

///
class StickerController extends ValueNotifier<StickerValue> {
  ///
  StickerController([UuidGetter? uuid])
      : uuid = uuid ?? const Uuid().v4,
        super(const StickerValue());

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
  void addSticker(
    Sticker sticker, {
    double? angle,
    StickerConstraint? constraint,
    StickerPosition? position,
    StickerSize? size,
  }) {
    final assets = StickerAsset(
      id: uuid(),
      sticker: sticker,
      angle: angle ?? 0.0,
      constraint: constraint ?? const StickerConstraint(),
      position: position ?? const StickerPosition(),
      size: size ?? const StickerSize(),
    );
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
      if (index.isNegative) return;

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
  void deleteSticker(StickerAsset asset) {
    final stickers = List.of(value.assets)
      ..removeWhere((element) => element.id == asset.id);
    // final index = stickers.indexWhere(
    //   (element) => element.id == value.selectedAssetId,
    // );
    // final stickerExists = index != -1;
    // if (stickerExists) {
    //   stickers.removeAt(index);
    // }
    value = value.copyWith(
      assets: stickers,
      selectedAssetId: emptyAssetId,
    );
  }

  /// clear stickers tapped
  void clearStickers() {
    value = value.copyWith(
      assets: [],
      selectedAssetId: emptyAssetId,
    );
  }

  /// PhotoTapped
  void unselectSticker() {
    value = value.copyWith(selectedAssetId: emptyAssetId);
  }

//
}
