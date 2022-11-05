<h1 align="center">Drishya Picker</h1>

<p align="center">
  <a href="https://flutter.dev">
    <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter" alt="Platform" />
  </a>
  <a href="https://pub.dartlang.org/packages/drishya_picker">
    <img src="https://img.shields.io/pub/v/drishya_picker.svg" alt="Pub Package" />
  </a>
  <a href="https://pub.dev/packages/drishya_picker/score">
    <img src="https://badges.bar/drishya_picker/likes" alt="likes"/>
  </a>
  <a><img src="https://img.shields.io/github/forks/koiralapankaj7/drishya_picker" alt="Forks"/></a>
</p>

---

<p align="center">A flutter package which is clone of facebook messenger gallery picker and camera, combined as single component. Gallery view and Camera view can also be use as Flutter widget. Under the hood drishya picker used <a href="https://pub.dev/packages/photo_manager">Photo Manager</a> and <a href="https://pub.dev/packages/camera">Camera</a>.</p>

---

# Table of contents

- [Installing](#installing)
- [Platform Setup](#platform-setup)
  - [Android](#android)
  - [IOS](#ios)
- [Gallery](#gallery)
- [Camera](#camera)
- [Bugs or Requests](#bugs-or-requests)
- [Contributors](#contributors)

---

# Installing

### 1. Add dependency
Add this to your package's `pubspec.yaml` file:
```yaml
dependencies:
  drishya_picker: ^latest_version
```

### 2. Install it
You can install packages from the command line:

with `pub`:
```
$ pub get
```
with `Flutter`:
```
$ flutter pub get
```

### 3. Import it
Now in your `Dart` code, you can use:
```dart
import 'package:drishya_picker/drishya_picker.dart';
```

---

# Platform Setup

For more details (if needed) you can go through <a href="https://pub.dev/packages/photo_manager">Photo Manager</a> and <a href="https://pub.dev/packages/camera">Camera</a> readme section as well.

## Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```
minSdkVersion 21
```

Required permissions: `INTERNET`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `ACCESS_MEDIA_LOCATION`.
If you don't need the `ACCESS_MEDIA_LOCATION` permission,
see [Disable `ACCESS_MEDIA_LOCATION` permission](#disable-access_media_location-permission).

### glide

Android native use glide to create image thumb bytes, version is 4.11.0.

If your other android library use the library, and version is not same, then you need edit your android project's build.gradle.

```gradle
rootProject.allprojects {

    subprojects {
        project.configurations.all {
            resolutionStrategy.eachDependency { details ->
                if (details.requested.group == 'com.github.bumptech.glide'
                        && details.requested.name.contains('glide')) {
                    details.useVersion '4.11.0'
                }
            }
        }
    }
}
```

And, if you want to use ProGuard, you can see the [ProGuard of Glide](https://github.com/bumptech/glide#proguard).

### Remove Media Location permission

Android contains [ACCESS_MEDIA_LOCATION](https://developer.android.com/training/data-storage/shared/media#media-location-permission) permission by default.

This permission is introduced in Android Q. If your app doesn't need this permission, you need to add the following node to the Android manifest in your app.

```xml
<uses-permission
  android:name="android.permission.ACCESS_MEDIA_LOCATION"
  tools:node="remove"
  />
```

If you found some warning logs with `Glide` appearing,
then the main project needs an implementation of `AppGlideModule`. 
See [Generated API](https://sjudd.github.io/glide/doc/generatedapi.html).

## IOS

Add following content to `info.plist`.

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Replace with your permission description..</string>
<key>NSCameraUsageDescription</key>
<string>Replace with your permission description..</string>
<key>NSMicrophoneUsageDescription</key>
<string>Replace with your permission description..</string>
```

---

# Gallery

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/gallery.gif" width="200"/>
            </td>            
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/1.jpg" width="200"/>
            </td>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/7.jpg" width="200" />
            </td>
        </tr> 
    </table>
</div>
<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/photo_editor.gif" width="200"/>
            </td>            
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/5.jpg" width="200"/>
            </td>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/6.jpg" width="200" />
            </td>
        </tr> 
    </table>
</div>


 1. Use `SlidableGallery` to make gallery view slidable otherwise ignore it.

 ```dart
class PickerDemo extends StatelessWidget {
  late final GalleryController controller;
  
  ...

  @override
  Widget build(BuildContext context) {
    return SlidableGallery(
      controller: controller,
      child: Scaffold(
        body: ...
      ),
    );
  }
}
``` 
 2. `GallerySetting` can be used for extra setting while 
    picking media.

- Using `pick()` function on controller to pick media.

```dart
class PickerDemo extends StatelessWidget {
  late final GalleryController controller;

  @override
  void initState() {
    super.initState();
    controller = GalleryController();
  }

    
  final _gallerySetting = GallerySetting(
      enableCamera: true,
      maximumCount: 10,
      requestType: RequestType.all,
      editorSetting: EditorSetting(colors: _colors, stickers: _stickers1),
      cameraSetting: const CameraSetting(videoDuration: Duration(seconds: 15)),
      cameraTextEditorSetting: EditorSetting(
        backgrounds: _defaultBackgrounds,
        colors: _colors.take(4).toList(),
        stickers: _stickers2,
      ),
      cameraPhotoEditorSetting: EditorSetting(
        colors: _colors.skip(4).toList(),
        stickers: _stickers3,
      ),
    );

  ...

  onPressed : () async {
    final entities = await controller.pick(context,setting:setting);
  }

  ...
}
```

 3. Using `GalleryViewField` similarly to flutter `TextField` to pick media. (Recommended approach, as creating and disposing of the controller has been already cared-of ) 

- `onChanged` – triggered whenever a user select/unselect media

- `onSubmitted` – triggered when a user is done with the selection


```dart
GalleryViewField(
  selectedEntities: [],
  onChanged: (entity, removed) {
     ...
  },
  onSubmitted: (list) {
     ...
  }
  child: const Icon(Icons.camera),
),
```

4. You can also use `GalleryView` as a `Widget`.

5. Browse the example app for more in-depth implementation and customization. 

---

# Camera

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/camera.gif" width="200"/>
            </td>            
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/8.jpg" width="200"/>
            </td>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/12.jpg" width="200" />
            </td>
        </tr> 
    </table>
</div>
<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/playground.gif" width="200"/>
            </td>            
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/photo_editor.gif" width="200"/>
            </td>
            <td style="text-align: center">
                <img src="https://raw.githubusercontent.com/koiralapankaj7/drishya_picker/dev/assets/10.jpg" width="200" />
            </td>
        </tr> 
    </table>
</div>

 1. Using `pick()` function on `CameraView` to pick media.

```dart
  ...
  onPressed : () async {
    final entity = await CameraView.pick();
  }
  ...
```

 2. Using `CameraViewField` similarly as flutter `TextField` to pick media.

- `onCapture` – triggered when photo/video capture completed

```dart
GalleryViewField(
  onCapture: (entity) {
     ...
  },
  child: const Icon(Icons.camera),
),
```

3. You can also use `CameraView` as a `Widget`.

---
# Bugs or Requests

If you encounter any problems feel free to open an [issue](https://github.com/koiralapankaj7/drishya_picker/issues/new?template=bug_report.md). If you feel the library is missing a feature, please raise a [ticket](https://github.com/koiralapankaj7/drishya_picker/issues/new?template=feature_request.md) on GitHub and I'll look into it. Pull request are also welcome.

---

# Maintainers

- [Pankaj Koirala](https://github.com/koiralapankaj7)

  <a href="https://twitter.com/koiralapankaj7">
    <img src="https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Ftwitter.com%2Fkoiralapankaj7"
      alt="Twitter" />
  </a>
