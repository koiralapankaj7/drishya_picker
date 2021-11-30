// ignore_for_file: always_use_package_imports

import 'dart:developer';
import 'dart:ui' as ui;

import 'package:drishya_picker/drishya_picker.dart';
import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

import '../entities/playground_background.dart';
import '../entities/playground_value.dart';

///
class PlaygroundController extends ValueNotifier<PlaygroundValue> {
  ///
  PlaygroundController({
    PlaygroundBackground? background,
    bool enableOverlay = true,
  })  : _playgroundKey = GlobalKey(),
        _stickerController = StickerBoothController(),
        _textController = TextEditingController(),
        super(
          PlaygroundValue(
            background: background,
            enableOverlay: enableOverlay,
          ),
        );

  final GlobalKey _playgroundKey;

  ///
  final StickerBoothController _stickerController;

  ///
  final TextEditingController _textController;

  ///
  GlobalKey get playgroundKey => _playgroundKey;

  ///
  bool get isPlaygroundEmpty => !value.hasStickers;

  /// Playground sticker booth controller
  StickerBoothController get stickerController => _stickerController;

  /// Playground text editing controller
  TextEditingController get textController => _textController;

  @override
  void dispose() {
    _stickerController.dispose();
    super.dispose();
  }

  /// Update playground value
  void updateValue({
    bool? fillColor,
    int? maxLines,
    TextAlign? textAlign,
    bool? hasFocus,
    bool? editingMode,
    bool? hasStickers,
    bool? isEditing,
    bool? stickerPickerView,
    bool? colorPickerVisibility,
  }) {
    if (!(hasFocus ?? false)) {
      // Hide status bar
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    value = value.copyWith(
      fillColor: fillColor,
      maxLines: maxLines,
      textAlign: textAlign,
      hasFocus: hasFocus,
      editingMode: editingMode,
      hasStickers: hasStickers,
      isEditing: isEditing,
      stickerPickerView: stickerPickerView,
      colorPickerVisibility: colorPickerVisibility,
    );
  }

  /// Clear playground
  void clearPlayground() {
    _stickerController.clearStickers();
    value = value.copyWith(hasStickers: false);
  }

  /// Change playground background
  void changeBackground({PlaygroundBackground? background}) {
    // Photo background
    if (background != null && background is PhotoBackground) {
      value = value.copyWith(background: background);
    } else {
      final current = value.background;
      final index = value.background is GradientBackground
          ? gradients.indexOf(current as GradientBackground)
          : 0;
      final hasMatch = index != -1;
      final nextIndex =
          hasMatch && index + 1 < gradients.length ? index + 1 : 0;
      final bg = gradients[nextIndex];
      value = value.copyWith(background: bg, textBackground: bg);
    }
  }

  /// Take screen shot of the playground
  Future<DrishyaEntity?> takeScreenshot() async {
    try {
      final bg = value.background;
      if (bg is PhotoBackground && bg.bytes != null && !value.hasStickers) {
        final entity = await PhotoManager.editor.saveImage(bg.bytes!);
        return entity?.toDrishya;
      } else {
        final boundary = _playgroundKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
        final image = await boundary!.toImage();
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final data = byteData!.buffer.asUint8List();
        final entity = await PhotoManager.editor.saveImage(data);
        return entity?.toDrishya;
      }
    } catch (e) {
      log('Exception occured while capturing picture : $e');
    }
  }

  //
}
