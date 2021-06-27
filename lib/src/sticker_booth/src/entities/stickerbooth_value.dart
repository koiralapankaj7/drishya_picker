import '../entities/sticker_asset.dart';

///
const emptyAssetId = '';

///
class StickerboothValue {
  ///
  const StickerboothValue({
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
  StickerboothValue copyWith({
    double? aspectRatio,
    List<StickerAsset>? assets,
    String? selectedAssetId,
  }) {
    return StickerboothValue(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      assets: assets ?? this.assets,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
    );
  }
}

///
extension PhotoAssetsX on List<StickerAsset> {
  ///
  bool containsAsset({required String named}) {
    return indexWhere((e) => e.sticker.name == named) != -1;
  }
}
