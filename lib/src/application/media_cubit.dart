// import 'package:bloc/bloc.dart';
// import 'package:photo_manager/photo_manager.dart';

// ///
// class AlbumCollectionCubit extends Cubit<AlbumCollectionState> {
//   ///
//   AlbumCollectionCubit() : super(const AlbumCollectionState());

//   ///
//   void fetchAlbums(RequestType type) async {
//     emit(state.copyWith(isLoading: true, hasError: false));

//     final result = await PhotoManager.requestPermission();
//     if (result) {
//       try {
//         final albums = await PhotoManager.getAssetPathList(type: type);
//         return emit(state.copyWith(
//           albums: albums,
//           isLoading: false,
//           hasPermission: true,
//         ));
//       } catch (e) {
//         return emit(state.copyWith(
//           error: e.toString(),
//           isLoading: false,
//           hasError: true,
//           hasPermission: true,
//         ));
//       }
//     } else {
//       return emit(state.copyWith(
//         error: 'Permission denied',
//         isLoading: false,
//         hasError: true,
//         hasPermission: false,
//       ));
//     }
//   }
// }

// ///
// class AlbumCollectionState {
//   ///
//   const AlbumCollectionState({
//     this.albums = const <AssetPathEntity>[],
//     this.error = '',
//     this.isLoading = false,
//     this.hasError = false,
//     this.hasPermission = false,
//   });

//   ///
//   final List<AssetPathEntity> albums;

//   ///
//   final String? error;

//   ///
//   final bool isLoading;

//   ///
//   final bool hasPermission;

//   final bool hasError;

//   ///
//   int get count => albums.length;

//   ///
//   bool get isEmpty => albums.isEmpty;

//   ///
//   bool get isNotEmpty => !isEmpty;

//   ///
//   bool get hasData => !hasError;

//   ///
//   AlbumCollectionState copyWith({
//     List<AssetPathEntity>? albums,
//     String? error,
//     bool? isLoading,
//     bool? hasPermission,
//     bool? hasError,
//   }) =>
//       AlbumCollectionState(
//         albums: albums ?? this.albums,
//         error: error ?? this.error,
//         isLoading: isLoading ?? this.isLoading,
//         hasPermission: hasPermission ?? this.hasPermission,
//         hasError: hasError ?? this.hasError,
//       );
// }

// ///
// class CurrentAlbumCubit extends Cubit<CurrentAlbumState> {
//   ///
//   CurrentAlbumCubit() : super(CurrentAlbumState());

//   ///
//   void changeAlbum(AssetPathEntity album) {
//     return emit(state.copyWith(album: album));
//   }
// }

// ///
// class CurrentAlbumState {
//   ///
//   CurrentAlbumState({
//     this.album,
//     this.isLoading = false,
//   });

//   ///
//   final AssetPathEntity? album;

//   ///
//   final bool isLoading;

//   ///
//   bool get hasData => album != null;

//   ///
//   String get name => album?.name ?? 'Media';

//   ///
//   CurrentAlbumState copyWith({
//     AssetPathEntity? album,
//     bool? isLoading,
//   }) =>
//       CurrentAlbumState(
//         album: album ?? this.album,
//         isLoading: isLoading ?? this.isLoading,
//       );
// }

// ///
// class GalleryCubit extends Cubit<GalleryState> {
//   ///
//   GalleryCubit() : super(const GalleryState());

//   void empty() {
//     return emit(state.copyWith(
//       hasError: false,
//       hasPermission: true,
//     ));
//   }

//   ///
//   void fetchAssets(AssetPathEntity album, {int? count}) async {
//     emit(state.copyWith(isLoading: true, hasError: false));

//     final result = await PhotoManager.requestPermission();

//     if (result) {
//       try {
//         final items = await album.assetList;
//         return emit(state.copyWith(
//           album: album,
//           items: items,
//           currentPage: 1,
//           lastPage: 0,
//           error: '',
//           isLoading: false,
//           hasPermission: true,
//         ));
//       } catch (e) {
//         return emit(state.copyWith(
//           error: e.toString(),
//           isLoading: false,
//           hasPermission: true,
//         ));
//       }
//     } else {
//       return emit(state.copyWith(
//         error: 'Permission denied',
//         isLoading: false,
//         hasError: true,
//         hasPermission: false,
//       ));
//     }
//   }
// }

// ///
// class GalleryState {
//   ///
//   const GalleryState({
//     this.album,
//     this.items = const <AssetEntity>[],
//     this.currentPage = 0,
//     this.lastPage = 0,
//     this.error = '',
//     this.isLoading = false,
//     this.hasPermission = false,
//     this.hasError = true,
//   });

//   ///
//   final AssetPathEntity? album;

//   ///
//   final List<AssetEntity> items;

//   ///
//   final int? currentPage;

//   ///
//   final int? lastPage;

//   ///
//   final String? error;

//   ///
//   final bool isLoading;

//   ///
//   final bool hasPermission;

//   ///
//   final bool hasError;

//   /// Length of gallery
//   int get count => items.length;

//   ///
//   GalleryState copyWith({
//     AssetPathEntity? album,
//     List<AssetEntity>? items,
//     int? currentPage,
//     int? lastPage,
//     String? error,
//     bool? isLoading,
//     bool? hasPermission,
//     bool? hasError,
//   }) =>
//       GalleryState(
//         album: album ?? this.album,
//         items: items ?? this.items,
//         currentPage: currentPage ?? this.currentPage,
//         lastPage: lastPage ?? this.lastPage,
//         error: error ?? this.error,
//         isLoading: isLoading ?? this.isLoading,
//         hasPermission: hasPermission ?? this.hasPermission,
//         hasError: hasError ?? this.hasError,
//       );

//   @override
//   String toString() {
//     return 'Album    :   $album\n'
//         'List     :   $items\n'
//         'Error    :   $error\n'
//         'Loading  :   $isLoading\n'
//         'Current  :   $currentPage\n'
//         'Last     :   $lastPage\n';
//   }
// }
