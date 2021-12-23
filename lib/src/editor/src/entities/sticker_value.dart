import 'package:drishya_picker/src/editor/editor.dart';

///
const emptyAssetId = '';

///
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
}

///
extension PhotoAssetsX on List<StickerAsset> {
  ///
  bool containsAsset({required String named}) {
    return indexWhere((e) => e.sticker.name == named) != -1;
  }
}
