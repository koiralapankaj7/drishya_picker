// import 'package:http/http.dart' as http;

// const _url = 'https://api.mojilala.com';
// const _searchPath = '/v1/stickers/search';
// const _trendingPath = '/v1/stickers/trending';
// const _random = '/v1/stickers/random';
// const _key = 'dc6zaTOxFJmzC';

// class StickerRepository {
//   Future<void> fetchStickers(String term) async {
//     final url = Uri.parse('$_url$_searchPath?q=$term&api_key=$_key');
//     final resp = http.get(url);
//   }

//   Future<void> fetchTrendingStickers() async {
//     final url = Uri.parse('uri');
//     final resp = http.get(url);
//   }

//   Future<void> fetchRandomStickers({String? tag}) async {
//     final url = Uri.parse('$_url$_random?api_key=$_key&tag=$tag');
//     final resp = http.get(url);
//   }
// }
