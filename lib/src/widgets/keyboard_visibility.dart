import 'package:flutter/material.dart';

///
class KeyboardVisibility extends StatefulWidget {
  ///
  const KeyboardVisibility({
    Key? key,
    this.child,
    this.listener,
    this.builder,
  }) : super(key: key);

  ///
  final Widget? child;

  ///
  final Widget Function(
      BuildContext context, bool isKeyboardVisible, Widget? child)? builder;

  ///
  final void Function(bool visible, double size)? listener;

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
    final viewInsets = WidgetsBinding.instance!.window.viewInsets;
    final bottomInset = viewInsets.bottom;
    final visibility = bottomInset > 0.0;
    if (visibility != _isKeyboardVisible) {
      widget.listener?.call(visibility, bottomInset);
      setState(() {
        _isKeyboardVisible = visibility;
      });
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder?.call(
        context,
        _isKeyboardVisible,
        widget.child,
      ) ??
      widget.child ??
      const SizedBox();
}
