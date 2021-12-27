import 'package:drishya_picker/drishya_picker.dart';
import 'package:example/fullscreen_gallery.dart';
import 'package:flutter/material.dart';

///
class RecentEntities extends StatefulWidget {
  ///
  const RecentEntities({
    Key? key,
    required this.controller,
    required this.notifier,
  }) : super(key: key);

  ///
  final GalleryController controller;

  ///
  final ValueNotifier<Data> notifier;

  @override
  State<RecentEntities> createState() => _RecentEntitiesState();
}

class _RecentEntitiesState extends State<RecentEntities> {
  late final Future<List<DrishyaEntity?>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.recentEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Recent',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        SizedBox(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          child: FutureBuilder<List<DrishyaEntity?>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  (snapshot.data?.isEmpty ?? true)) {
                return const SizedBox();
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 4.0),
                itemBuilder: (c, i) {
                  final entity = snapshot.data![i];
                  if (entity == null) return const SizedBox();
                  return ValueListenableBuilder<Data>(
                    valueListenable: widget.notifier,
                    builder: (context, data, child) {
                      final selected = data.entities.contains(entity);

                      return Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: InkWell(
                          onTap: () {
                            final entities =
                                List<DrishyaEntity>.from(data.entities);
                            if (selected) {
                              entities.remove(entity);
                            } else {
                              entities.add(entity);
                            }
                            widget.notifier.value =
                                data.copyWith(entities: entities);
                          },
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 100.0,
                                width: 100.0,
                                child: EntityThumbnail(entity: entity),
                              ),
                              if (selected)
                                Positioned.fill(
                                  child: ColoredBox(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.5),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
