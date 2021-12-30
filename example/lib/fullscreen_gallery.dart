import 'package:drishya_picker/drishya_picker.dart';
import 'package:example/collapsable_gallery.dart';
import 'package:example/grid_view_widget.dart';
import 'package:example/recent_entities.dart';
import 'package:example/text_field_view.dart';
import 'package:flutter/material.dart';

///
class FullscreenGallery extends StatefulWidget {
  ///
  const FullscreenGallery({
    Key? key,
  }) : super(key: key);

  @override
  _FullscreenGalleryState createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late final GalleryController _controller;
  late final ValueNotifier<Data> _notifier;

  @override
  void initState() {
    super.initState();
    _controller = GalleryController();
    _notifier = ValueNotifier(Data());
  }

  @override
  void dispose() {
    super.dispose();
    _notifier.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullscreen Gallery'),
      ),
      body: Column(
        children: [
          // Grid view
          Expanded(
            child: GridViewWidget(
              controller: _controller,
              setting: gallerySetting,
              notifier: _notifier,
            ),
          ),

          const SizedBox(height: 8.0),

          RecentEntities(controller: _controller, notifier: _notifier),

          const SizedBox(height: 8.0),

          // Textfield
          Container(
            padding: const EdgeInsets.all(8.0),
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
            child: Row(
              children: [
                // Textfield
                Expanded(child: TextFieldView(notifier: _notifier)),

                // Camera field..
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CameraViewField(
                    editorSetting: gallerySetting.editorSetting,
                    onCapture: (entities) {
                      _notifier.value = _notifier.value.copyWith(
                        entities: [..._notifier.value.entities, ...entities],
                      );
                    },
                    child: const Icon(Icons.camera),
                  ),
                ),

                // Gallery field
                ValueListenableBuilder<Data>(
                  valueListenable: _notifier,
                  builder: (context, data, child) {
                    return GalleryViewField(
                      setting: gallerySetting.copyWith(
                        maximumCount: data.maxLimit,
                        albumSubtitle: 'Image only',
                        requestType: data.requestType,
                        selectedEntities: data.entities,
                      ),
                      onChanged: (entity, remove) {
                        final entities = _notifier.value.entities.toList();
                        remove ? entities.remove(entity) : entities.add(entity);
                        _notifier.value =
                            _notifier.value.copyWith(entities: entities);
                      },
                      onSubmitted: (list) => _notifier.value =
                          _notifier.value.copyWith(entities: list),
                      child: child,
                    );
                  },
                  child: const Icon(Icons.photo),
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

///
class Data {
  ///
  Data({
    this.entities = const [],
    this.maxLimit = 10,
    this.requestType = RequestType.all,
  });

  ///
  final List<DrishyaEntity> entities;

  ///
  final int maxLimit;

  ///
  final RequestType requestType;

  ///
  Data copyWith({
    List<DrishyaEntity>? entities,
    int? maxLimit,
    RequestType? requestType,
  }) {
    return Data(
      entities: entities ?? this.entities,
      maxLimit: maxLimit ?? this.maxLimit,
      requestType: requestType ?? this.requestType,
    );
  }
}
