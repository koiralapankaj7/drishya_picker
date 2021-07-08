# drishya_picker

Messanger like media picker

<img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/main/assets/gif.gif" width="300" height="500">

<img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/main/assets/1.jpg" width="300" height="500">. <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/main/assets/2.jpg" width="300" height="500">. <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/main/assets/3.jpg" width="300" height="500">. <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/main/assets/4.jpg" width="300" height="500">. <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/main/assets/5.jpg" width="300" height="500">. <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/main/assets/6.jpg" width="300" height="500">
    
    
## Collapsible Gallery View
---


```dart
/// Media picker demo using controller
class PickerDemo extends StatelessWidget {
  late final GalleryController controller;

  @override
  void initState() {
    super.initState();
    controller = GalleryController(
      gallerySetting: const GallerySetting(
        albumSubtitle: 'Collapsable',
        enableCamera: true,
        maximum: 10,
        requestType: RequestType.all,
      ),
      panelSetting: const PanelSetting(topMargin: 24.0),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GalleryViewWrapper(
      controller: controller,
      child: Scaffold(
        body: TextButton(
           onPressed: () async {
             final entities = await controller.pick(context);
           },
           style: TextButton.styleFrom(
             primary: Colors.white,
             backgroundColor: Colors.green,
           ),
           child: const Text('Pick'),
         ),
      ),
    );
  }
}
```

## Fullscreen Gallery View

- Remove GalleryViewWrapper for fullscreen navigation
---
```dart
/// Media picker demo using controller
class PickerDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TextButton(
           onPressed: () async {
             final entities = await controller.pick(context);
           },
           style: TextButton.styleFrom(
             primary: Colors.white,
             backgroundColor: Colors.green,
           ),
           child: const Text('Pick'),
       ),
    );
  }
}
```

---




