import 'dart:math';

import 'package:drishya_picker/src/application/media_cubit.dart';
import 'package:drishya_picker/src/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../drishya_picker.dart';

///
class Header extends StatefulWidget {
  ///
  const Header({
    Key? key,
    required this.drishyaController,
    this.background,
    this.headerSubtitle,
    this.toogleAlbumList,
    this.onClosePressed,
    this.onSelectionClear,
  }) : super(key: key);

  ///
  final DrishyaController drishyaController;

  ///
  final Color? background;

  ///
  final String? headerSubtitle;

  ///
  final void Function()? toogleAlbumList;

  ///
  final void Function()? onClosePressed;

  ///
  final void Function()? onSelectionClear;

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
    final drishyaController = widget.drishyaController;

    return Container(
      color: widget.background ?? Colors.black,
      constraints: BoxConstraints(
        minHeight: drishyaController.panelController.headerMinHeight!,
        maxHeight: drishyaController.panelController.headerMaxHeight!,
      ),
      child: Column(
        children: [
          // Handler
          _Handler(height: drishyaController.panelController.headerMinHeight),

          // Details and controls
          Expanded(
            child: Row(
              children: [
                // Close icon
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ValueListenableBuilder<DrishyaValue>(
                      valueListenable: drishyaController,
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
                      valueListenable: drishyaController,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.entities.isEmpty ? 1.0 : 0.0,
                          child: _AnimatedDropdown(
                            onPressed: widget.toogleAlbumList,
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

class _AnimatedDropdown extends StatefulWidget {
  const _AnimatedDropdown({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final Function? onPressed;

  @override
  _AnimatedDropdownState createState() => _AnimatedDropdownState();
}

class _AnimatedDropdownState extends State<_AnimatedDropdown> {
  bool isDown = true;
  @override
  Widget build(BuildContext context) {
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
          widget.onPressed?.call();
          setState(() {
            isDown = !isDown;
          });
        },
        size: 34.0,
      ),
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

        BlocBuilder<CurrentAlbumCubit, CurrentAlbumState>(
          builder: (context, state) {
            return Text(
              state.name,
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
