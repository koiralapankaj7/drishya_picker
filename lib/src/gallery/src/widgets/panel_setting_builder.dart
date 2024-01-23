import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

const _defaultMin = 0.37;

///
class PanelSettingBuilder extends StatelessWidget {
  ///
  const PanelSettingBuilder({
    required this.setting,
    required this.builder,
    Key? key,
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
        final panelMaxHeight = ps.maxHeight ??
            size.height - (isFullScreen ? mediaQuery.padding.top : 0);
        final panelMinHeight = ps.minHeight ?? panelMaxHeight * _defaultMin;
        final updatedSetting = ps.copyWith(
          maxHeight: panelMaxHeight,
          minHeight: panelMinHeight,
        );
        return builder(updatedSetting);
      },
    );
  }
}
