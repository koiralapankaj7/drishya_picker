import 'package:drishya_picker/drishya_picker.dart';

///
class GalleryValue {
  ///
  const GalleryValue({
    this.selectedEntities = const <DrishyaEntity>[],
    this.previousSelection = true,
    this.isAlbumVisible = false,
    this.forceMultiSelection = false,
  });

  ///
  final List<DrishyaEntity> selectedEntities;

  ///
  final bool previousSelection;

  ///
  final bool isAlbumVisible;

  ///
  final bool forceMultiSelection;

  ///
  GalleryValue copyWith({
    List<DrishyaEntity>? selectedEntities,
    bool? previousSelection,
    bool? isAlbumVisible,
    bool? forceMultiSelection,
  }) =>
      GalleryValue(
        selectedEntities: selectedEntities ?? this.selectedEntities,
        previousSelection: previousSelection ?? this.previousSelection,
        isAlbumVisible: isAlbumVisible ?? this.isAlbumVisible,
        forceMultiSelection: forceMultiSelection ?? this.forceMultiSelection,
      );

  @override
  String toString() =>
      'LENGTH  :  ${selectedEntities.length} \nLIST  :  $selectedEntities';
}
