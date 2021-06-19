import 'package:drishya_picker/src/entities/entities.dart';
import 'package:flutter/material.dart';

import '../drishya_picker.dart';

class Buttons extends StatefulWidget {
  const Buttons({
    Key? key,
    required this.drishyaController,
    this.onEdit,
    this.onSubmit,
  }) : super(key: key);

  final DrishyaController drishyaController;
  final void Function(BuildContext context)? onEdit;
  final void Function(BuildContext context)? onSubmit;

  @override
  ButtonsState createState() => ButtonsState();
}

class ButtonsState extends State<Buttons> with TickerProviderStateMixin {
  late AnimationController _editOpaController;
  late AnimationController _selectOpaController;
  late AnimationController _selectSizeController;
  late Animation<double> _editOpa;
  late Animation<double> _selectOpa;
  late Animation<double> _selectSize;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 300);
    _editOpaController = AnimationController(vsync: this, duration: duration);
    _selectOpaController = AnimationController(vsync: this, duration: duration);
    _selectSizeController =
        AnimationController(vsync: this, duration: duration);

    final tween = Tween(begin: 0.0, end: 1.0);

    _editOpa = tween.animate(CurvedAnimation(
      parent: _editOpaController,
      curve: Curves.easeIn,
    ));

    _selectOpa = tween.animate(CurvedAnimation(
      parent: _selectOpaController,
      curve: Curves.easeIn,
    ));

    _selectSize = tween.animate(CurvedAnimation(
      parent: _selectSizeController,
      curve: Curves.easeIn,
    ));

    widget.drishyaController.addListener(() {
      if (mounted) {
        final entities = widget.drishyaController.value.entities;

        if (!widget.drishyaController.reachedMaximumLimit) {
          if (entities.isEmpty && _selectOpaController.value == 1.0) {
            _editOpaController.reverse();
            _selectOpaController.reverse();
          }

          if (entities.isNotEmpty) {
            if (entities.length == 1) {
              _editOpaController.forward();
              _selectOpaController.forward();
              _selectSizeController.reverse();
            } else {
              _editOpaController.reverse();
              _selectSizeController.forward();
              if (_selectOpaController.value == 0.0) {
                _selectOpaController.forward();
              }
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _editOpaController.dispose();
    _selectOpaController.dispose();
    _selectSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const padding = 20.0 + 16.0 + 20.0;
    final buttonWidth = (size.width - padding) / 2;

    return ValueListenableBuilder<DrishyaValue>(
      valueListenable: widget.drishyaController,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          width: size.width,
          child: Stack(
            children: [
              // Edit button
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: _editOpa,
                  builder: (context, child) {
                    final hide = (value.entities.isEmpty &&
                            !_editOpaController.isAnimating) ||
                        _editOpa.value == 0.0;
                    return hide
                        ? const SizedBox()
                        : Opacity(
                            opacity: _editOpa.value,
                            child: child,
                          );
                  },
                  child: SizedBox(
                    width: buttonWidth,
                    child: _TextButton(
                      onPressed: () {
                        widget.onEdit?.call(context);
                      },
                      label: 'EDIT',
                      background: Colors.white,
                      labelColor: Colors.black,
                    ),
                  ),
                ),
              ),

              // Margin
              const SizedBox(width: 16.0),

              // Select
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedBuilder(
                  animation: _selectOpa,
                  builder: (context, child) {
                    final hide = (value.entities.isEmpty &&
                            !_selectOpaController.isAnimating) ||
                        _selectOpa.value == 0.0;

                    return hide
                        ? const SizedBox()
                        : Opacity(
                            opacity: _selectOpa.value,
                            child: child,
                          );
                  },
                  child: AnimatedBuilder(
                    animation: _selectSize,
                    builder: (context, child) {
                      return SizedBox(
                        width: buttonWidth +
                            _selectSize.value * (buttonWidth + 20.0),
                        child: child,
                      );
                    },
                    child: _TextButton(
                      onPressed: () {
                        widget.onSubmit?.call(context);
                      },
                      label: 'SELECT',
                    ),
                  ),
                ),
              ),

              // Send Button
            ],
          ),
        );
      },
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    Key? key,
    this.label,
    this.background,
    this.labelColor,
    this.onPressed,
  }) : super(key: key);

  final String? label;
  final Color? background;
  final Color? labelColor;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed as void Function()?,
      child: Text(
        label ?? '',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: labelColor ?? Colors.white,
            ),
      ),
      style: TextButton.styleFrom(
        primary: Colors.black,
        backgroundColor: background ?? Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
    );
  }
}
