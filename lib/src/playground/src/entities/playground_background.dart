import 'dart:typed_data';

import 'package:drishya_picker/src/playground/playground.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

///
// ignore: one_member_abstracts
abstract class PlaygroundBackground {
  /// Playgroung builder
  Widget build(BuildContext context);
}

///
class PhotoBackground implements PlaygroundBackground {
  ///
  PhotoBackground({
    this.bytes,
    this.url,
  });

  ///
  final Uint8List? bytes;

  ///
  final String? url;

  ///
  bool get hasData => (url?.isNotEmpty ?? false) || (bytes != null);

  @override
  Widget build(BuildContext context) => PhotoBackgroundView(background: this);
}

///
class GradientBackground implements PlaygroundBackground {
  ///
  const GradientBackground(this.colors);

  ///
  final List<Color> colors;

  @override
  Widget build(BuildContext context) =>
      GradientBackgroundView(background: this);
}

///
const gradients = [
  GradientBackground([Color(0xFF00C6FF), Color(0xFF0078FF)]),
  GradientBackground([Color(0xFFeb3349), Color(0xFFf45c43)]),
  GradientBackground([Color(0xFF26a0da), Color(0xFF314755)]),
  GradientBackground([Color(0xFFe65c00), Color(0xFFF9D423)]),
  GradientBackground([Color(0xFFfc6767), Color(0xFFec008c)]),
  GradientBackground([Color(0xFF5433FF), Color(0xFF20BDFF), Color(0xFFA5FECB)]),
  GradientBackground([Color(0xFF334d50), Color(0xFFcbcaa5)]),
  GradientBackground([Color(0xFF1565C0), Color(0xFFb92b27)]),
  GradientBackground([Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFFA5FECB)]),
  GradientBackground([Color(0xFF2193b0), Color(0xFF6dd5ed)]),
  GradientBackground([Color(0xFF753a88), Color(0xFFcc2b5e)]),
];
