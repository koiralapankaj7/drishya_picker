import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
/// Fully customizable background for editor.
///
/// [DrishyaBackground], [MemoryAssetBackground] and [GradientBackground] are
/// the default backgrounds.
///
/// You can make your own background by implementing [EditorBackground] class.
///
// ignore: one_member_abstracts
abstract class EditorBackground {
  /// Playgroung builder
  Widget build(BuildContext context);
}

///
@immutable
class DrishyaBackground implements EditorBackground {
  ///
  /// Drishya background only support image background
  const DrishyaBackground({
    required this.entity,
  });

  /// Drishya entity
  final DrishyaEntity entity;

  @override
  Widget build(BuildContext context) => _EntityBGView(entity: entity);

  ///
  DrishyaBackground copyWith({
    DrishyaEntity? entity,
  }) {
    return DrishyaBackground(
      entity: entity ?? this.entity,
    );
  }

  @override
  String toString() => 'DrishyaBackground(entity: $entity)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DrishyaBackground && other.entity == entity;
  }

  @override
  int get hashCode => entity.hashCode;
}

///
@immutable
class MemoryAssetBackground implements EditorBackground {
  ///
  /// Background for memory asset
  const MemoryAssetBackground({required this.bytes});

  /// Asset bytes
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: MemoryImage(bytes),
          ),
        ),
      );

  ///
  MemoryAssetBackground copyWith({
    Uint8List? bytes,
  }) {
    return MemoryAssetBackground(
      bytes: bytes ?? this.bytes,
    );
  }

  @override
  String toString() => 'MemoryAssetBackground(bytes: $bytes)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MemoryAssetBackground && other.bytes == bytes;
  }

  @override
  int get hashCode => bytes.hashCode;
}

///
@immutable
class GradientBackground implements EditorBackground {
  ///
  const GradientBackground({
    this.colors,
    this.gradient,
  }) : assert(
          colors != null || gradient != null,
          "Both colors and gradient canno't be null",
        );

  ///
  final List<Color>? colors;

  ///
  final Gradient? gradient;

  /// First color from the gradient
  Color get firstColor => colors?.first ?? gradient!.colors.first;

  /// Last color from the gradient
  Color get lastColor => colors?.last ?? gradient!.colors.last;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ??
              LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors!,
              ),
        ),
      );

  /// Helper function to copy object data
  GradientBackground copyWith({
    List<Color>? colors,
    Gradient? gradient,
  }) {
    return GradientBackground(
      colors: colors ?? this.colors,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  String toString() => '''
      GradientBackground(
        colors: $colors, 
        gradient: $gradient
      )''';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is GradientBackground &&
        listEquals(other.colors, colors) &&
        other.gradient == gradient;
  }

  @override
  int get hashCode => colors.hashCode ^ gradient.hashCode;
}

/// For better performance, this approact prevent unnecessary build
class _EntityBGView extends StatefulWidget {
  const _EntityBGView({Key? key, required this.entity}) : super(key: key);

  final DrishyaEntity entity;

  @override
  _EntityBGViewState createState() => _EntityBGViewState();
}

class _EntityBGViewState extends State<_EntityBGView> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.entity.originBytes;
  }

  @override
  Widget build(BuildContext context) {
    final entity = widget.entity;

    if (entity.type != AssetType.image) {
      return Center(
        child: Text(
          'Un-supported background!',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
                color: Colors.white,
              ),
        ),
      );
    }
    return FutureBuilder<Uint8List?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (snapshot.data == null) {
          return Center(
            child: Text(
              'Failed to load background!',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    color: Colors.white,
                  ),
            ),
          );
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: MemoryImage(snapshot.data!),
            ),
          ),
        );
      },
    );
  }
}
