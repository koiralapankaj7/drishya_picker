import 'dart:math';

import 'package:drishya_picker/src/application/media_fetcher.dart';
import 'package:drishya_picker/src/entities/entities.dart';
import 'package:drishya_picker/src/slidable_panel/slidable_panel.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../drishya_picker.dart';

///
class Header extends StatefulWidget {
  ///
  const Header({
    Key? key,
    required this.controller,
    required this.panelSetting,
    required this.dropdownNotifier,
    this.headerSubtitle,
    this.toogleAlbumList,
    this.onClosePressed,
    this.onSelectionClear,
  }) : super(key: key);

  ///
  final DrishyaController controller;

  ///
  final PanelSetting panelSetting;

  ///
  final String? headerSubtitle;

  ///
  final void Function()? toogleAlbumList;

  ///
  final void Function()? onClosePressed;

  ///
  final void Function()? onSelectionClear;

  /// Dropdown notifiler
  final ValueNotifier<bool> dropdownNotifier;

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  //
  void _showAlert() {
    final cancel = TextButton(
      onPressed: Navigator.of(context).pop,
      child: Text(
        'CANCEL',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.lightBlue,
            ),
      ),
    );
    final unselectItems = TextButton(
      onPressed: widget.onSelectionClear,
      child: Text(
        'USELECT ITEMS',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.blue,
            ),
      ),
    );

    final alertDialog = AlertDialog(
      title: Text(
        'Unselect these items?',
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Colors.white70,
            ),
      ),
      content: Text(
        'Going back will undo the selections you made.',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
      actions: [cancel, unselectItems],
      backgroundColor: Colors.grey.shade900,
      actionsPadding: const EdgeInsets.all(0.0),
      titlePadding: const EdgeInsets.all(16.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: widget.panelSetting.headerMinHeight,
        maxHeight: widget.panelSetting.headerMaxHeight,
      ),
      decoration: BoxDecoration(
        color: widget.panelSetting.headerBackground,
        border: Border(
          bottom: BorderSide(color: Colors.lightBlue.shade300, width: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Handler
          if (!widget.controller.fullScreenMode)
            _Handler(height: widget.panelSetting.headerMinHeight),

          if (widget.controller.fullScreenMode)
            SizedBox(height: MediaQuery.of(context).padding.top),

          // Details and controls
          Expanded(
            child: Row(
              children: [
                // Close icon
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ValueListenableBuilder<DrishyaValue>(
                      valueListenable: widget.controller,
                      builder: (context, value, child) {
                        return _IconButton(
                          iconData: Icons.close,
                          onPressed: value.entities.isEmpty
                              ? widget.onClosePressed
                              : _showAlert,
                        );
                      },
                    ),
                  ),
                ),

                // Album name and media receiver name
                _AlbumDetail(subtitle: widget.headerSubtitle),

                // Dropdown
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ValueListenableBuilder<DrishyaValue>(
                      valueListenable: widget.controller,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.entities.isEmpty ? 1.0 : 0.0,
                          child: _AnimatedDropdown(
                            onPressed: widget.toogleAlbumList,
                            notifier: widget.dropdownNotifier,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                //
              ],
            ),
          ),

          //
        ],
      ),
    );
  }
}

class _AnimatedDropdown extends StatelessWidget {
  const _AnimatedDropdown({
    Key? key,
    this.onPressed,
    required this.notifier,
  }) : super(key: key);

  final Function? onPressed;
  final ValueNotifier<bool> notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, isDown, child) {
        return TweenAnimationBuilder(
          tween: Tween(begin: isDown ? 1.0 : 0.0, end: isDown ? 0.0 : 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, double value, child) {
            return Transform.rotate(
              angle: pi * value,
              child: child,
            );
          },
          child: _IconButton(
            iconData: Icons.keyboard_arrow_down,
            onPressed: () {
              onPressed?.call();
              notifier.value = !notifier.value;
            },
            size: 34.0,
          ),
        );
      },
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    Key? key,
    this.iconData,
    this.onPressed,
    this.size,
  }) : super(key: key);

  final IconData? iconData;
  final void Function()? onPressed;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(40.0),
      elevation: 0.0,
      child: IconButton(
        padding: const EdgeInsets.all(0.0),
        icon: Icon(
          iconData ?? Icons.close,
          color: Colors.lightBlue.shade300,
          size: size ?? 26.0,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _AlbumDetail extends StatelessWidget {
  const _AlbumDetail({
    Key? key,
    this.subtitle,
  }) : super(key: key);

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album name
        ValueListenableBuilder<AssetPathEntity?>(
          valueListenable: currentAlbum,
          builder: (context, album, child) {
            return Text(
              album?.name ?? 'Unknown',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        ),

        const SizedBox(height: 2.0),

        // Receiver name
        Text(
          subtitle ?? 'Select',
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _Handler extends StatelessWidget {
  const _Handler({
    Key? key,
    this.height,
  }) : super(key: key);

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            width: 40.0,
            height: 5.0,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
