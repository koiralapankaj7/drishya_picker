import 'package:drishya_picker/src/draggable_resizable/src/entities/photo_asset.dart';

///
const emptyAssetId = '';

///
class StickerboothValue {
  ///
  const StickerboothValue({
    this.aspectRatio = 3 / 4,
    this.stickers = const <PhotoAsset>[],
    this.selectedAssetId = emptyAssetId,
    this.imageId = '',
  });

  // bool get isDashSelected => characters.containsAsset(named: 'dash');

  // bool get isAndroidSelected => characters.containsAsset(named: 'android');

  // bool get isSparkySelected => characters.containsAsset(named: 'sparky');

  // bool get isDinoSelected => characters.containsAsset(named: 'dino');

  // ///
  // bool get isAnyCharacterSelected => characters.isNotEmpty;

  // ///
  // List<PhotoAsset> get assets => characters + stickers;

  ///
  final double aspectRatio;

  ///
  final String imageId;

  ///
  final List<PhotoAsset> stickers;

  ///
  final String selectedAssetId;

  ///
  StickerboothValue copyWith({
    double? aspectRatio,
    String? imageId,
    List<PhotoAsset>? characters,
    List<PhotoAsset>? stickers,
    String? selectedAssetId,
  }) {
    return StickerboothValue(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      imageId: imageId ?? this.imageId,
      stickers: stickers ?? this.stickers,
      selectedAssetId: selectedAssetId ?? this.selectedAssetId,
    );
  }
}

///
extension PhotoAssetsX on List<PhotoAsset> {
  ///
  bool containsAsset({required String named}) {
    return indexWhere((e) => e.asset.name == named) != -1;
  }
}
