///
class CameraType {
  const CameraType._internal(this.value, this.index);

  ///
  final String value;

  ///
  final int index;

  ///
  static const CameraType text = CameraType._internal('Text', 0);

  ///
  static const CameraType normal = CameraType._internal('Normal', 1);

  ///
  static const CameraType video = CameraType._internal('Video', 2);

  ///
  // static const _InputType boomerang = _InputType._internal('Boomerang', 3);

  ///
  static const CameraType selfi = CameraType._internal('Selfi', 4);

  ///
  static List<CameraType> get values => [text, normal, video, selfi];
}
