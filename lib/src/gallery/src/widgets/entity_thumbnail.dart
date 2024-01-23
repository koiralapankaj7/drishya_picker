import 'dart:ui' as ui;

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Widget to display [DrishyaEntity] thumbnail
class EntityThumbnail extends StatelessWidget {
  ///
  const EntityThumbnail({
    required this.entity, Key? key,
    this.onBytesGenerated,
  }) : super(key: key);

  ///
  final DrishyaEntity entity;

  /// Callback function triggered when image bytes is generated
  final ValueSetter<Uint8List?>? onBytesGenerated;

  @override
  Widget build(BuildContext context) {
    Widget child = const SizedBox();

    //
    if (entity.type == AssetType.image || entity.type == AssetType.video) {
      if (entity.pickedThumbData != null) {
        child = Image.memory(
          entity.pickedThumbData!,
          fit: BoxFit.cover,
        );
      } else {
        child = Image(
          image: MediaThumbnailProvider(
            entity: entity,
            onBytesLoaded: onBytesGenerated,
          ),
          fit: BoxFit.cover,
        );
      }
    }

    if (entity.type == AssetType.audio) {
      child = const Center(child: Icon(Icons.audiotrack, color: Colors.white));
    }

    if (entity.type == AssetType.other) {
      child = const Center(child: Icon(Icons.file_copy, color: Colors.white));
    }

    if (entity.type == AssetType.video || entity.type == AssetType.audio) {
      child = Stack(
        fit: StackFit.expand,
        children: [
          child,
          Align(
            alignment: Alignment.bottomRight,
            child: _DurationView(duration: entity.duration),
          ),
        ],
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: child,
    );
  }
}

/// ImageProvider implementation
@immutable
class MediaThumbnailProvider extends ImageProvider<MediaThumbnailProvider> {
  /// Constructor for creating a [MediaThumbnailProvider]
  const MediaThumbnailProvider({
    required this.entity,
    this.size = const ThumbnailSize(400, 400),
    this.format = ThumbnailFormat.jpeg,
    this.quality = 100,
    this.scale = 1,
    this.onBytesLoaded,
  });

  ///
  final DrishyaEntity entity;
  final ValueSetter<Uint8List?>? onBytesLoaded;

  /// The thumbnail size.
  final ThumbnailSize size;

  /// {@macro photo_manager.ThumbnailFormat}
  final ThumbnailFormat format;

  /// The quality value for the thumbnail.
  ///
  /// Valid from 1 to 100.
  /// Defaults to 100.
  final int quality;

  /// Scale of the image.
  final double scale;

  @override
  ImageStreamCompleter loadImage(
    MediaThumbnailProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>(
          'Thumbnail provider: $this \n Thumbnail key: $key',
          this,
          style: DiagnosticsTreeStyle.errorProperty,
        );
      },
    );
  }

  Future<ui.Codec> _loadAsync(
    MediaThumbnailProvider key,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this, '$key is not $this');
    final bytes = await entity.thumbnailDataWithSize(
      size,
      format: format,
      quality: quality,
    );
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes!);
    return decode(buffer);
  }

  @override
  Future<MediaThumbnailProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<MediaThumbnailProvider>(this);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    // ignore: test_types_in_equals
    final typedOther = other as MediaThumbnailProvider;
    return entity.id == typedOther.entity.id;
  }

  @override
  int get hashCode => entity.id.hashCode;

  @override
  String toString() => '$MediaThumbnailProvider("${entity.id}")';
}

class _DurationView extends StatelessWidget {
  const _DurationView({
    required this.duration, Key? key,
  }) : super(key: key);

  final int duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.7),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          duration.formatedDuration,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString().padRight(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
