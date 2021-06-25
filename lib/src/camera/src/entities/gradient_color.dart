import 'package:flutter/painting.dart';

///
class GradientColor {
  ///
  const GradientColor(this.colors);

  ///
  final List<Color> colors;
}

///
const gradients = [
  GradientColor([Color(0xFF00C6FF), Color(0xFF0078FF)]),
  GradientColor([Color(0xFFeb3349), Color(0xFFf45c43)]),
  GradientColor([Color(0xFF26a0da), Color(0xFF314755)]),
  GradientColor([Color(0xFFe65c00), Color(0xFFF9D423)]),
  GradientColor([Color(0xFFfc6767), Color(0xFFec008c)]),
  GradientColor([Color(0xFF5433FF), Color(0xFF20BDFF), Color(0xFFA5FECB)]),
  GradientColor([Color(0xFF334d50), Color(0xFFcbcaa5)]),
  GradientColor([Color(0xFF1565C0), Color(0xFFb92b27)]),
  GradientColor([Color(0xFF0052D4), Color(0xFF4364F7), Color(0xFFA5FECB)]),
  GradientColor([Color(0xFF2193b0), Color(0xFF6dd5ed)]),
  GradientColor([Color(0xFF753a88), Color(0xFFcc2b5e)]),
];
