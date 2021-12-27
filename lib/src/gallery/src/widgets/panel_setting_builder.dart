import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

const _defaultMin = 0.37;

///
class PanelSettingBuilder extends StatelessWidget {
  ///
  const PanelSettingBuilder({
    Key? key,
    required this.setting,
    required this.builder,
  }) : super(key: key);

  ///
  final PanelSetting? setting;

  ///
  final Widget Function(PanelSetting panelSetting) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final size = constraints.biggest;
        final isFullScreen = size.height == mediaQuery.size.height;
        final ps = setting ?? const PanelSetting();
        final _panelMaxHeight = ps.maxHeight ??
            size.height - (isFullScreen ? mediaQuery.padding.top : 0);
        final _panelMinHeight = ps.minHeight ?? _panelMaxHeight * _defaultMin;
        final _setting = ps.copyWith(
          maxHeight: _panelMaxHeight,
          minHeight: _panelMinHeight,
        );
        return builder(_setting);
      },
    );
  }
}
