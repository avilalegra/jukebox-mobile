import 'dart:convert';

import 'package:jukebox/Album.dart';
import 'package:jukebox/Pagination.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://127.0.0.1:8000/api';

class AlbumsPaginationParams {
  final Filter nameFilter;
  final Sort nameSort;

  AlbumsPaginationParams({required this.nameFilter, required this.nameSort});
}

Future<Pagination<AlbumSummary>> fetchAlbums(
    AlbumsPaginationParams params) async {
  var response = await http.get(Uri.parse(
      '$baseUrl/albums?filters[name_lk]=${params.nameFilter.value}&sorts[name]=${params.nameSort.direction.name}'));

  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);

    List<AlbumSummary> albums = json['albums']
        .map<AlbumSummary>((e) => AlbumSummary.fromJson(e))
        .toList();

    return Pagination<AlbumSummary>(
        page: json['page'],
        perPage: json['perPage'],
        numbersOfPages: json['numberOfPages'],
        items: albums);
  } else {
    throw Exception('Failed to load album');
  }
}
