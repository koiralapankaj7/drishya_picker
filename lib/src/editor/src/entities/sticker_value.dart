import 'package:collection/collection.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
const emptyAssetId = '';

///
@immutable
class StickerValue {
  ///
  const StickerValue({
    this.aspectRatio = 3 / 4,
    this.assets = const <StickerAsset>[],
    this.selectedAssetId = emptyAssetId,
  });

  ///
  final double aspectRatio;

  ///
  final List<StickerAsset> assets;

  ///
  final String selectedAssetId;

  ///
  StickerValue copyWith({
    double? aspectRatio,
    List<StickerAsset>? assets,
    String? selectedAssetId,
  }) {
    return StickerValue(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      assets: assets ?? this.assets,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
    );
  }

  @override
  String toString() => '''
      StickerValue(
        aspectRatio: $aspectRatio, 
        assets: $assets, 
        selectedAssetId: $selectedAssetId
      )''';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is StickerValue &&
        other.aspectRatio == aspectRatio &&
        listEquals(other.assets, assets) &&
        other.selectedAssetId == selectedAssetId;
  }

  @override
  int get hashCode =>
      aspectRatio.hashCode ^ assets.hashCode ^ selectedAssetId.hashCode;
}

///
extension PhotoAssetsX on List<StickerAsset> {
  ///
  bool containsAsset({required String named}) {
    return indexWhere((e) => e.sticker.name == named) != -1;
  }
}
