import 'package:flutter/material.dart';

///
class KeyboardVisibility extends StatefulWidget {
  ///
  const KeyboardVisibility({
    Key? key,
    this.child,
    this.listener,
    required this.builder,
  }) : super(key: key);

  ///
  final Widget? child;

  ///
  final Widget Function(
    BuildContext context,
    bool isKeyboardVisible,
    Widget? child,
  ) builder;

  ///
  final ValueSetter<bool>? listener;

  @override
  State<KeyboardVisibility> createState() => _KeyboardVisibilityState();
}

class _KeyboardVisibilityState extends State<KeyboardVisibility>
    with WidgetsBindingObserver {
  var _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance!.window.viewInsets.bottom;
    final visibility = bottomInset > 0.0;
    if (visibility != _isKeyboardVisible) {
      widget.listener?.call(visibility);
      setState(() {
        _isKeyboardVisible = visibility;
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _isKeyboardVisible,
        widget.child,
      );
}
