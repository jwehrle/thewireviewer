import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:list_detail_base/list_detail_base.dart';

import 'package:wireviewer/base/models/character.dart';

/// Interpolates [showName] into URI
String _duckDuckGoQuery(String showName) {
  return "http://api.duckduckgo.com/?q=$showName+characters&format=json";
}

class AppController extends ListDetailController<Character> {
  /// The name of the used in the query field of the duckduckgo API call.
  /// [showName] must conform to API. See https://serpapi.com/duckduckgo-search-api
  final String showName;

  final http.Client client;

  /// Creates a controller for this application which can:
  /// Fetch all characters from [showName],
  /// Search characters based on key terms,
  /// Character selection.
  AppController({
    required this.showName,
    required this.client,
  }) : super();

  /// Returns list of all characters.
  Future<List<Character>> fetchAll() async {
    String url = _duckDuckGoQuery(showName);
    final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final List characterList = result["RelatedTopics"] ?? [];
      return List<Character>.from(
          characterList.map((map) => Character.fromMap(map)));
    }
    return Future.error(
        'HTTP request failed with status code: ${response.statusCode}');
  }

  /// Setter for receiving fetched character list which is then
  /// added to a StreamController to which other views can listen.
  set characterList(List<Character> value) => _strCtl.add(value);

  /// The underlying StreamController for passing character lists.
  final StreamController<List<Character>> _strCtl = StreamController();

  /// Stream of character list.
  Stream<List<Character>> get stream => _strCtl.stream;

  @override
  void dispose() {
    _strCtl.close();
    super.dispose();
  }
}
