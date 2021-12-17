import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class GridViewWidget extends StatelessWidget {
  ///
  const GridViewWidget({
    Key? key,
    required this.controller,
    required this.notifier,
    required this.onAddButtonPressed,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final ValueNotifier<List<DrishyaEntity>> notifier;

  ///
  final VoidCallback onAddButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ValueListenableBuilder<List<DrishyaEntity>>(
        valueListenable: notifier,
        builder: (context, list, child) {
          if (list.isEmpty) {
            return ValueListenableBuilder<PnaelValue>(
              valueListenable: controller.panelController,
              builder: (context, value, child) {
                if (value.state == PanelState.close) {
                  return child!;
                }
                return const SizedBox();
              },
              child: Center(
                child: InkWell(
                  onTap: onAddButtonPressed,
                  child: const CircleAvatar(
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(4.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 1.0,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final entity = list[index];
              return EntityThumbnail(entity: entity);
            },
          );
        },
      ),
    );
  }
}

///