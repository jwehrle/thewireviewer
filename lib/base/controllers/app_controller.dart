import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:wireviewer/base/models/character.dart';

/// Interpolates [showName] into URI
String _duckDuckGoQuery(String showName) {
  return "http://api.duckduckgo.com/?q=$showName+characters&format=json";
}

class AppController {
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
  });

  /// Underlying selection ValueNotifier.
  final ValueNotifier<Character?> _selectedCharacter = ValueNotifier(null);

  /// The currently selected Character. If none is selected, value == null.
  /// Listen to this Listenable for selection changes.
  ValueListenable<Character?> get selectedCharacter => _selectedCharacter;

  /// Select the character. Set to null to unselect. Changes trigger
  /// notifications to all listeners.
  set select(Character? character) => _selectedCharacter.value = character;

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

  /// Dispose of resources that need to be disposed.
  void dispose() {
    _selectedCharacter.dispose();
  }
}
