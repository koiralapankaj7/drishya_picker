part of 'camera_view.dart';

class CameraControl extends StatefulWidget {
  const CameraControl({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final CameraController controller;

  @override
  _CameraControlState createState() => _CameraControlState();
}

class _CameraControlState extends State<CameraControl> {
  XFile? imageFile;
  late final PageController pageController;
  late final _InputController inputController;
  late final ValueNotifier<ScrollDetail> pageVisibility;

  @override
  void initState() {
    super.initState();
    inputController = _InputController();
    pageVisibility = ValueNotifier(ScrollDetail(0.0, AxisDirection.left));
    pageController = PageController(
      viewportFraction: 0.22,
    )..addListener(_pageListener);
  }

  void _pageListener() {
    pageVisibility.value = ScrollDetail(
      pageController.page ?? 0.0,
      pageController.position.axisDirection,
    );
  }

  void _onPageChanged(int index) {}

  ///
  // void _displayThumbnail(XFile file) {
  //   setState(() {
  //     imageFile = file;
  //   });
  // }

  @override
  void dispose() {
    pageController.removeListener(_pageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Close and flash
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Expanded(child: SizedBox()),
              _CameraListener(
                controller: widget.controller,
                builder: (value) {
                  return IconButton(
                    icon: Icon(
                      value.flashMode == FlashMode.off
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  );
                },
              ),
            ],
          ),

          // Expanded
          const Expanded(child: SizedBox()),

          // Filters and capture
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80.0,
                width: 80.0,
                padding: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.0),
                  border: Border.all(
                    color: Colors.white,
                    width: 6.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white60,
                ),
              ),
            ],
          ),

          // preview, mode and camera
          Row(
            children: [
              // Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  color: Colors.white,
                  height: 48.0,
                  width: 48.0,
                  child: imageFile == null
                      ? SizedBox()
                      : Image.file(File(imageFile!.path)),
                ),
              ),

              // Expanded
              Expanded(
                child: Container(
                  height: 40.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Text scroller
                      Expanded(
                        child: PageView.builder(
                          itemCount: _InputType.values.length,
                          controller: pageController,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) {
                            final type = _InputType.values[index];

                            return ValueListenableBuilder<ScrollDetail>(
                              valueListenable: pageVisibility,
                              builder: (context, detail, child) {
                                final value = detail.page;

                                final isCurrent = value == index.toDouble();
                                log('$index : $isCurrent');
                                final color = Colors.white.withAlpha(
                                  (0xFF * value.clamp(0.5, 1.0)).round(),
                                );
                                return _InputItem(
                                  type: type,
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Indicator
                      Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: Radius.circular(2.0),
                            bottomRight: Radius.circular(2.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Camera
              IconButton(
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),

              //
            ],
          ),

          //
        ],
      ),
    );
  }
}

class _InputItem extends StatelessWidget {
  const _InputItem({
    Key? key,
    required this.type,
    this.color,
    this.fontSize = 14.0,
  }) : super(key: key);

  final _InputType type;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 4.0),
      child: Text(
        type.value.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: color ?? Colors.white,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

class _CameraListener extends StatelessWidget {
  const _CameraListener({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(key: key);

  final CameraController controller;
  final Widget Function(CameraValue value) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraValue>(
      valueListenable: controller,
      builder: (context, cameraValue, child) {
        return builder(cameraValue);
      },
    );
  }
}

class _InputController extends ValueNotifier<_InputValue> {
  _InputController() : super(_InputValue());
}

class _InputValue {
  _InputValue({
    this.type = _InputType.normal,
  });

  final _InputType type;
}

class _InputType {
  const _InputType._internal(this.value, this.index);

  ///
  final String value;

  ///
  final int index;

  ///
  static const _InputType text = _InputType._internal('Text', 0);

  ///
  static const _InputType normal = _InputType._internal('Normal', 1);

  ///
  static const _InputType video = _InputType._internal('Video', 2);

  ///
  static const _InputType selfi = _InputType._internal('Selfi', 3);

  ///
  static List<_InputType> get values => [text, normal, video, selfi];
}

class ScrollDetail {
  ScrollDetail(this.page, this.direction);

  final double page;
  final AxisDirection direction;
}
