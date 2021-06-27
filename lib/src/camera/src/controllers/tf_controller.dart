import 'package:drishya_picker/src/camera/src/entities/tf_value.dart';
import 'package:flutter/widgets.dart';

///
class TFController extends ValueNotifier<TFValue> {
  ///
  TFController() : super(const TFValue());

  /// Update controller value
  void updateValue({
    Color? fillColor,
    int? maxLines,
    TextAlign? textAlign,
    bool? hasFocus,
  }) {
    value = value.copyWith(
      fillColor: fillColor,
      maxLines: maxLines,
      textAlign: textAlign,
      hasFocus: hasFocus,
    );
  }
}
