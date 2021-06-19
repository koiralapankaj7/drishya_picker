import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../drishya_picker.dart';
import '../drishya_picker.dart';

///
class MediaTile extends StatefulWidget {
  ///
  const MediaTile({
    Key? key,
    required this.entity,
    required this.drishyaController,
    required this.onSelect,
  }) : super(key: key);

  ///
  final DrishyaController drishyaController;

  ///
  final AssetEntity entity;

  ///
  final void Function() onSelect;

  @override
  MediaTileState createState() => MediaTileState();
}

///
class MediaTileState extends State<MediaTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drishyaController = widget.drishyaController;

    return GestureDetector(
      onTap: widget.onSelect,
      child: Container(
        color: Colors.grey.shade700,
        child: FutureBuilder<Uint8List?>(
          future: widget.entity.thumbDataWithSize(
            400,
            400,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _animation,
                    child: child,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),

                    // Duration
                    if (widget.entity.type == AssetType.video)
                      Positioned(
                        right: 4.0,
                        bottom: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            child: Text(
                              widget.entity.duration.formatedDuration,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Image selection overlay
                    ValueListenableBuilder<DrishyaValue>(
                      valueListenable: drishyaController,
                      builder: (context, value, child) {
                        final isSelected =
                            value.entities.contains(widget.entity);

                        if (!isSelected) return const SizedBox();

                        return Container(
                          color: Colors.white54,
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 14.0,
                              child: Text(
                                '${value.entities.indexOf(widget.entity) + 1}',
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    //
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

///
extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString();
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
