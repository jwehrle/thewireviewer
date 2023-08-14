import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_detail_base/list_detail_base.dart';
import 'package:wireviewer/base/controllers/app_controller.dart';
import 'dart:io' show Platform;

import 'package:wireviewer/base/models/character.dart';
import 'package:wireviewer/base/views/character_detail.dart';

/// Creates a searchable list of character names.
/// Character name tiles are selectable.
/// Widget is adaptive to iOS, in which case it makes Cupertino widgets,
/// otherwise Material widgets are used.
class CharacterListBody extends StatefulWidget {
  final String appTitle;

  /// Creates a searchable list of character names.
  /// Character name tiles are selectable.
  /// Widget is adaptive to iOS, in which case it makes Cupertino widgets,
  /// otherwise Material widgets are used.
  const CharacterListBody({
    super.key,
    required this.appTitle,
    // required this.characters,
  });

  @override
  State<CharacterListBody> createState() => CharacterListBodyState();
}

class CharacterListBodyState extends State<CharacterListBody> {
  /// Current search string value only used in iOS version.
  String _searchVaue = '';

  /// Controller for [CupertinoSearchTextField] which is only used
  ///  in iOS version
  late final TextEditingController _searchCtl;

  /// Callback that keeps [_searchVaue] current
  void _searchListener() {
    setState(() => _searchVaue = _searchCtl.value.text);
  }

  @override
  void initState() {
    super.initState();
    _searchCtl = TextEditingController();
    _searchCtl.addListener(_searchListener);
  }

  List<Character> _find(String text, List<Character> list) {
    if (text.isEmpty) {
      return [];
    }
    return list
        .where((e) => e.description.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    AppController controller =
        ListDetail.of<Character>(context).controller as AppController;

    bool useScaffold = !controller.isSplit;

    return StreamBuilder<List<Character>>(
      stream: controller.stream,
      builder: (context, snap) {
        if (snap.hasData) {

          // If search is empty, show all.
          // Otherwise, show subset matching search
          List<Widget> results = _searchVaue.isEmpty
              ? snap.data!
                  .map((char) => CharacterListTile(
                        character: char,
                        onSelect: (character) => controller.select = character,
                        useScaffold: useScaffold,
                      ))
                  .toList()
              : _find(_searchVaue, snap.data!)
                  .map((char) => CharacterListTile(
                        character: char,
                        onSelect: (character) => controller.select = character,
                        useScaffold: useScaffold,
                        searchText: _searchVaue,
                      ))
                  .toList();

          if (Platform.isIOS) {
            return SingleChildScrollView(
              child: CupertinoListSection(
                header: CupertinoSearchTextField(
                  controller: _searchCtl,
                  onSuffixTap: _searchCtl.clear,
                ),
                children: results,
              ),
            );
          }
          
          return MaterialListSection(
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchCtl,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () => _searchCtl.clear(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
            children: results,
          );
        }
        return const Center(child: CircularProgressIndicator.adaptive());
      },
    );
  }

  @override
  void dispose() {
    _searchCtl.removeListener(_searchListener);
    _searchCtl.dispose();
    super.dispose();
  }
}

/// Similar to CupertinoListSection. Shows a header widget
/// followed by a list.
class MaterialListSection extends StatelessWidget {
  /// Similar to CupertinoListSection. Shows a [header] widget
  /// followed by a ListView of [children].
  const MaterialListSection({
    super.key,
    required this.header,
    required this.children,
  });

  final Widget header;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: header,
        ),
        Expanded(
          child: ListView(
            children: children,
          ),
        ),
      ],
    );
  }
}

/// ListTile that can be the name-only version for the list
/// portion of the layout or shown in the search results.
/// [searchText] determines which version is made.
/// Selecting in either state calls [onSelect].
/// Name-only tiles show only the character name.
/// Search-tiles show name and description with the 
/// search text in bold.
class CharacterListTile extends StatelessWidget {
  const CharacterListTile({
    super.key,
    required this.character,
    required this.onSelect,
    required this.useScaffold,
    this.searchText,
  });

  final Character character;
  final ValueChanged<Character> onSelect;
  final bool useScaffold;
  final String? searchText;

  /// Returns a RichText based on [character.description] with [searchText] in bold.
  RichText _subtitle(
      Character character, String searchText, Brightness brightness) {
    int start =
        character.description.toLowerCase().indexOf(searchText.toLowerCase());
    int end = start + searchText.length;
    TextStyle style = TextStyle(
      color: brightness == Brightness.dark ? Colors.white70 : Colors.black87,
    );
    return RichText(
      text: TextSpan(
        children: [
          if (start != 0)
            TextSpan(
              text: character.description.substring(0, start),
              style: style,
            ),
          TextSpan(
              text: character.description.substring(start, end),
              style: style.copyWith(fontWeight: FontWeight.bold)),
          if (end != character.description.length)
            TextSpan(
              text: character.description.substring(end),
              style: style,
            ),
        ],
      ),
    );
  }

  void _tileTap(BuildContext context, Character character) {
    onSelect(character);
    if (useScaffold) {
      _openDetails(context, character);
    }
  }

  void _openDetails(BuildContext context, Character character) {
    final route = Platform.isIOS
        ? CupertinoPageRoute(
            builder: (context) => CharacterDetailPhone(
              character: character,
            ),
          )
        : MaterialPageRoute(
            builder: (context) => CharacterDetailPhone(
              character: character,
            ),
          );
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    Brightness brightness;
    if (Platform.isIOS) {
      brightness = CupertinoTheme.brightnessOf(context);
      return CupertinoListTile(
        title: Text(character.name),
        subtitle: searchText != null
            ? _subtitle(character, searchText!, brightness)
            : null,
        onTap: () => _tileTap(context, character),
      );
    }
    brightness = Theme.of(context).brightness;
    return ListTile(
      title: Text(character.name),
      subtitle: searchText != null
          ? _subtitle(character, searchText!, brightness)
          : null,
      onTap: () => _tileTap(context, character),
    );
  }
}
