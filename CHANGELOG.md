## 1.0.0 - 20/03/2021

* Messenger style media picker 
* Media selection limit
* MediaController / MediaPicker (TextField behaviour) for picking media    
* OnChanged and OnSubmitted callback available, similar to Textfield

## 1.0.0+1
Bug fixes

## 1.0.1 
Breaking changes and feature upgrade

* Added camera picker
* Bug fixes
* UI polishing

## 1.0.1+1 
Updated readme

## 1.0.1+2
Breaking changes 

* Picker will return DrishyaEntity
* [Before] : AssetEntity
* [Now]    : DrishyaEntity

## 1.0.2
Features and UI update

* Image edit
* Stickers view updated
* Camera view will accept resolution and image format

## 1.0.2+1 - 
Hotfix

## 1.0.3
Breaking changes

* Edit bug fixed 
* DrishyaEndity properties updated
* Paginated gallery

## 2.0.0-dev 
DrishyaPicker is on the verge of being a fully customizable package 

- **Breaking**: `DrishyaEntity` now extends `AssetEntity` and some field has been removed for performance optimization.
- **Breaking**: `GalleryViewWrapper` has been replaced by `SlidableGallery`
- **Breaking**: `GalleryController` will not take parameters anymore. Now, you can pass settings while picking the assets.
- **Added**: Default stickers for the editor section have been removed. Now you have to provide your own stickers which makes the editor more customizable and unique. You can implement `Sticker` class to make your own sticker or just use already available stickers. E.g, `IconSticker`, `ImageSticker` and `TextSticker`. 
- **Added**: Same as stickers now you can provide your own background and color settings for the editor. You can also make your own background. Implement `EditorBackground` to make your own background or use the default one provided by the package. E.g, `GradientBackground`, `MemoryAssetBackground`, and 
`DrishyaBackground`.
- **Added**: Now you can use `GalleryView`, `CameraView`, and `DrishyaEditor` independently with full customization support.

- **General**: All available API has been made public now.
- **General**: To see what else this package has to offer, please visit the example app.

**Warning**: The license has been updated. Now, author permission is required, if you are re-publishing this package in `pub.dev` just by renaming the packages or with minor changes. 

## 2.0.0-dev-1
Dependencies updated to latest version.
