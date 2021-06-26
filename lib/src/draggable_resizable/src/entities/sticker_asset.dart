import 'package:flutter/widgets.dart';

///
class StickerAsset {
  ///
  const StickerAsset({
    required this.id,
    required this.sticker,
    this.angle = 0.0,
    this.constraint = const StickerConstraint(),
    this.position = const StickerPosition(),
    this.size = const StickerSize(),
  });

  ///
  final String id;

  ///
  final Sticker sticker;

  ///
  final double angle;

  ///
  final StickerConstraint constraint;

  ///
  final StickerPosition position;

  ///
  final StickerSize size;

  ///
  StickerAsset copyWith({
    Sticker? sticker,
    double? angle,
    StickerConstraint? constraint,
    StickerPosition? position,
    StickerSize? size,
  }) {
    return StickerAsset(
      id: id,
      sticker: sticker ?? this.sticker,
      angle: angle ?? this.angle,
      constraint: constraint ?? this.constraint,
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }
}

///
class StickerConstraint {
  ///
  const StickerConstraint({this.width = 1, this.height = 1});

  ///
  final double width;

  ///
  final double height;
}

///
class StickerSize {
  ///
  const StickerSize({this.width = 1, this.height = 1});

  ///
  final double width;

  ///
  final double height;
}

///
class StickerPosition {
  ///
  const StickerPosition({this.dx = 0, this.dy = 0});

  ///
  final double dx;

  ///
  final double dy;
}

/// {@template asset}
/// A Dart object which holds metadata for a given sticker.
/// {@endtemplate}
class Sticker {
  /// {@macro asset}
  const Sticker({
    this.name,
    this.path,
    this.size = const Size(200.0, 200.0),
    this.pathType = StickerPathType.none,
    this.widget,
  });

  /// The name of the sticker.
  final String? name;

  /// The url of the sticker. either network/accets or text
  final String? path;

  ///
  final StickerPathType pathType;

  /// The size of the asset. Default Size(100.0, 100.0)
  final Size size;

  ///
  final Widget? widget;
}

///
enum StickerPathType {
  ///
  text,

  ///
  networkImg,

  ///
  assetsImage,

  ///
  none,
}

//
const animatedStickers = {
  Sticker(
    name: 'No Way',
    path: 'https://media.giphy.com/media/USUIWSteF8DJoc5Snd/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Sad Face',
    path: 'https://media.giphy.com/media/h4OGa0npayrJX2NRPT/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Angry Face',
    path: 'https://media.giphy.com/media/j5E5qvtLDTfmHbT84Y/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Sad Miss You',
    path: 'https://media.giphy.com/media/IzcFv6WJ4310bDeGjo/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Angry Face',
    path: 'https://media.giphy.com/media/kyQfR7MlQQ9Gb8URKG/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Smiley Face Love',
    path: 'https://media.giphy.com/media/hof5uMY0nBwxyjY9S2/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Sad Face',
    path: 'https://media.giphy.com/media/kfS15Gnvf9UhkwafJn/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Crying',
    path: 'https://media.giphy.com/media/ViHbdDMcIOeLeblrbq/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Wow',
    path: 'https://media.giphy.com/media/XEyXIfu7IRQivZl1Mw/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Fuckboy',
    path: 'https://media.giphy.com/media/Kd5vjqlBqOhLsu3Rna/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Bless You',
    path: 'https://media.giphy.com/media/WqR7WfQVrpXNcmrm81/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'As If Whatever',
    path: 'https://media.giphy.com/media/Q6xFPLfzfsgKoKDV60/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Sick face',
    path: 'https://media.giphy.com/media/W3CLbW0KY3RtjsqtYO/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Birthday cake',
    path: 'https://media.giphy.com/media/l4RS2PG61HIYiukdoT/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Embarrassed Face',
    path: 'https://media.giphy.com/media/kyzzHEoaLAAr9nX4fy/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Celebrate Happy Birthday',
    path: 'https://media.giphy.com/media/7zSBoGW2VoCEzWVjyA/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: 'Effects ',
    path: 'https://media.giphy.com/media/xT0GqKaASLordVtYCk/giphy.gif',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: '',
    path:
        'https://e7.pngegg.com/pngimages/857/954/png-clipart-tattoo-others-miscellaneous-3d-computer-graphics.png',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: '',
    path:
        'https://static4.depositphotos.com/1006994/298/v/600/depositphotos_2983099-stock-illustration-grunge-design.jpg',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: '',
    path:
        'https://toppng.com/uploads/preview/blue-paint-drip-png-black-paint-drips-1156289356992eulaf4l6.png',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: '',
    path:
        'https://w7.pngwing.com/pngs/841/943/png-transparent-lion-euclidean-ink-jet-ink-effect-splash.png',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: '',
    path:
        'https://i.pinimg.com/originals/0a/1f/82/0a1f820e29719c7b67e9d5aa44241155.png',
    pathType: StickerPathType.networkImg,
  ),
  Sticker(
    name: '',
    path:
        'https://w7.pngwing.com/pngs/114/579/png-transparent-pink-cross-stroke-ink-brush-pen-red-ink-brush-ink-leave-the-material-text.png',
    pathType: StickerPathType.networkImg,
  ),
};
