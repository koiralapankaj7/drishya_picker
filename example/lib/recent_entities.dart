import 'package:drishya_picker/drishya_picker.dart';
import 'package:flutter/material.dart';

///
class RecentEntities extends StatelessWidget {
  ///
  const RecentEntities({
    Key? key,
    required this.controller,
  }) : super(key: key);

  ///
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder<List<DrishyaEntity?>>(
        future: controller.recentEntities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              (snapshot.data?.isEmpty ?? true)) {
            return const SizedBox();
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (c, i) {
              final entity = snapshot.data![i];
              if (entity == null) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: EntityThumbnail(entity: entity),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
