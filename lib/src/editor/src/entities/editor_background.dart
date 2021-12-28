import 'dart:typed_data';

import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
// ignore: one_member_abstracts
abstract class EditorBackground {
  /// Playgroung builder
  Widget build(BuildContext context);
}

///
class DrishyaBackground implements EditorBackground {
  ///
  /// Drishya background only support image background
  const DrishyaBackground({required this.entity});

  /// Drishya entity
  final DrishyaEntity entity;

  @override
  Widget build(BuildContext context) {
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
      future: entity.originBytes,
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

///
class MemoryAssetBackground implements EditorBackground {
  ///
  /// Background for memory asset
  MemoryAssetBackground({required this.bytes});

  /// Asset bytes
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: MemoryImage(bytes),
        ),
      ),
    );
  }
}

///
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
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors!,
            ),
      ),
    );
  }
}
