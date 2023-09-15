class DrishyaTextDelegate {
  const DrishyaTextDelegate();
  String get cancel => 'Cancel';
  String get unselectItems => 'Unselect Items';
  String get unselectTheseItems => 'Unselect these items?';
  String get backUndo => 'Going back will undo the selections you made.';
  String get gallery => 'Gallery';
  String get cameraView => 'CameraView';
  String get unavailable => 'cameraUnavailable';
  String get couldntFindCamera => "Couldn't find the camera!";
  String get simulator => 'Simulator';
  String get text => 'Text';
  String get normal => 'Normal';
  String get video => 'Video';
  String get selfie => 'Selfie';
  String get unknown => 'Unknown';
  String get unsupportedBackground => 'Un-supported background!';
  String get failedLoadBackground => 'Failed to load background!';
  String get stickersNotAvailable => 'Stickers not available!';
  String get done => 'Done';
  String get no => 'NO';
  String get discard => 'DISCARD';
  String get discardChanges => 'Discard changes?';
  String get areYouSureDiscard =>
      'Are you sure you want to discard your changes?';
  String get somethingWrong => 'Something went wrong! Please try again.';
  String get tapToType=>'Tap to type...';
  String get galleryView=>'GalleryView';
  String maximumSelection(int value)=>'Maximum selection limit of '
      '${value} has been reached!';

  String get allPhotos=>'All Photos';
  String get selectMedia=>'Select Media';

  String get noAlbumsAvailable=>'No albums available';
  String get noAlbums=>'No albums';
  String get edit=>'EDIT';
  String get select=>'SELECT';
  String get noMediaAvailable=>'No media available';
  String get camera=>'Camera';
  String get album=>'Album';
  ///keep a space after for correct spacing
  String get accessYour=>'Access Your ';
  String get denyAccess=>'Deny Access';
  String get allowAccess=>'Allow Access';
  String get cameraAndMicrophone=>'camera and microphone';
  String get albumForMedia=>'album for picking media';
  ///keepa a space after for correct spacing
  String get allowPermission=>'Allow Drishya picker to access your ';

  String typeLabel(int value) {
    switch (value) {
      case 0:
        return text;
      case 1:
        return normal;
      case 2:
        return video;
      case 4:
        return selfie;
    }
    return unknown;
  }
}
