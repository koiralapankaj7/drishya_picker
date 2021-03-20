# drishya_picker

Messanger like media picker

<table>
  <tr>
    <td><img src="/assets/gif.gif" width="300" height="500"></td>
    <td><img src="/assets/1.jpg" width="300" height="500"></td>
    <td><img src="/assets/2.jpg" width="300" height="500"></td>
  </tr>
  <tr>
    <td><img src="/assets/3.jpg" width="300" height="500"></td>
    <td><img src="/assets/4.jpg" width="300" height="500"></td>
    <td><img src="/assets/5.jpg" width="300" height="500"></td>
  </tr>
  <tr>
    <td><img src="/assets/6.jpg" width="300" height="500"></td>
  </tr>
 </table>

#### Using controller

```dart
/// Media picker demo using controller
class PickerDemo extends StatelessWidget {
    final controller = DrishyaPickerController();

    // Call this method to pick data
    Future<void> _pickData({DrishyaSetting? setting}) async {
        final data = await controller.pickMedia(setting: setting);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Pick using controller'),
            ),
            body: DrishyaPicker(
                controller: controller,
                child: ...
            ),
        );
    }
}
```

#### Using picker

```dart
class PickerDemo extends StatefulWidget {
    @override
    _PickerDemoState createState() => _PickerDemoState();
}

/// Media picker demo using controller
class _PickerDemoState extends State<PickerDemo> {
    final controller = DrishyaPickerController();

    // Call this method to pick data
    Future<void> _pickData({DrishyaSetting? setting}) async {
        final data = await controller.pickMedia(setting: setting);
    }

    @override
    Widget build(BuildContext context) {
        return DrishyaPicker(
            requestType: RequestType.common,
            topMargin: MediaQuery.of(context).padding.top,
            child: Scaffold(
                body: Center(
                    child: MediaPicker(
                        setting: DrishyaSetting(
                            selected: list,
                            maximum: 5,
                            albumSubtitle: 'common',
                        ),
                        onChanged: (entity, isRemoved) {
                            //
                        },
                        onSubmitted: (list) {
                            //
                        },
                        child: child,
                    ),
                ),
            ),
        );
    }
}
```
