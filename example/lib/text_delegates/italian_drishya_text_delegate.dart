import 'package:drishya_picker/drishya_picker.dart';

class ItalianDrishyaTextDelegate implements DrishyaTextDelegate{
  @override
  String get accessYour => 'Permetti l\'accesso a';

  @override
  String get album => 'Album';

  @override
  String get albumForMedia => 'galleria per le foto';

  @override
  String get allPhotos => 'Foto';

  @override
  String get allowAccess => 'Accetta';

  @override
  String get allowPermission => 'Concedi il permesso per ';

  @override
  String get areYouSureDiscard => 'Sicuro di voler scartare?';

  @override
  String get backUndo => 'Torna indietro';

  @override
  String get camera => 'Fotocamera';

  @override
  String get cameraAndMicrophone => 'fotocamera e microfono';

  @override
  String get cameraView => 'CameraView';

  @override
  String get cancel => 'ANNULLA';

  @override
  String get couldntFindCamera => 'Errore nel caricamento della fotocamera';

  @override
  String get denyAccess => 'RIFIUTA';

  @override
  String get discard => 'SCARTA';

  @override
  String get discardChanges => 'Scarta le tue modifiche';

  @override
  String get done => 'FATTO';

  @override
  String get edit => 'MODIFICA';

  @override
  String get failedLoadBackground => 'Impossibile caricare lo sfondo';

  @override
  String get gallery => 'Galleria';

  @override
  String get galleryView => 'GalleryView';

  @override
  String maximumSelection(int value) =>'Il limite massimo di selezione '
        '$value è stato raggiunto!';

  @override
  String get no => 'NO';

  @override
  String get noAlbums => 'Nessun album';

  @override
  String get noAlbumsAvailable => 'Nessun album disponibile';

  @override
  String get noMediaAvailable => 'Nessun media disponibile';

  @override
  String get normal => 'Normale';

  @override
  String get select => 'SELEZIONA';

  @override
  String get selectMedia => 'Seleziona media';

  @override
  String get selfie => 'Selfie';

  @override
  String get simulator => 'Simulatore';

  @override
  String get somethingWrong => 'C\'è stato un errore. Riprova più tardi';

  @override
  String get stickersNotAvailable => 'Stickers non disponibili al momento';

  @override
  String get tapToType => 'Tocca per scrivere';

  @override
  String get text => 'Testo';

  @override
  String get unavailable => 'Non disponibile';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get unselectItems => 'Deseleziona elementi';

  @override
  String get unselectTheseItems => 'Deseleziona questi elementi';

  @override
  String get unsupportedBackground => 'Sfondo non supportato';

  @override
  String get video => 'Video';

  @override
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