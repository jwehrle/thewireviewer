import 'package:flutter/foundation.dart';

/// Extracts name of character from [text]. Expects whatever text
/// precedes the first ' - ' pattern to be the character's name.
/// If this pattern is not present, returns entire [text] as name.
String _extractName(String text) {
  int end = text.indexOf(' - ');
  if (end == -1) {
    return text;
  }
  return text.substring(0, end);
}

/// Extracts image url from [map].
/// If [map] contains "Icon" field, 
/// and "Icon" value is a map,
/// and "Icon" map contains "URL" field,
/// and "URL" value is type String then returns "URL" value.
/// If any of the above are false, returns empty string.
String _extractImageURL(Map<String, dynamic> map) {
  if (!map.containsKey("Icon")) {
    return '';
  }
  final icon = map["Icon"]!;
  if (icon is! Map) {
    return '';
  }
  if (!icon.containsKey("URL")) {
    return '';
  }
  final url = icon["URL"]!;
  if (url is! String) {
    return '';
  }
  return url;
}

/// Encapsulates required character details of [name], [description], and [imageURL].
/// Has no public constructor. Use the factory, Character.fromMap().
class Character {
  final String name;
  final String description;
  final String imageURL;

  /// Private constructor. Use only Character.fromMap()
  @visibleForTesting
  Character({
    required this.name,
    required this.description,
    required this.imageURL,
  });

  /// Creates a Character from [map]. Expects key value pairs based on
  /// duckduckgo API. See https://serpapi.com/duckduckgo-search-api
  factory Character.fromMap(Map<String, dynamic> map) {
    final String text = map['Text'] ?? '';
    return Character(
      name: _extractName(text),
      description: text,
      imageURL: _extractImageURL(map),
    );
  }

  @override
  String toString() =>
      'Character(name: $name, description: $description, imageURL: $imageURL)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Character &&
        other.name == name &&
        other.description == description &&
        other.imageURL == imageURL;
  }

  @override
  int get hashCode => name.hashCode ^ description.hashCode ^ imageURL.hashCode;
}
