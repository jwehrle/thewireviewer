import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:list_detail_base/list_detail_base.dart';
import 'package:wireviewer/base/models/character.dart';
import 'package:wireviewer/base/models/constants.dart';

/// Character detail view used for larger screens.
/// Always visible and changes its view depending on
/// the value of [selectedCharacter].
class CharacterDetailTablet extends StatelessWidget {
  /// Creates a character detail view used for larger screens.
  /// Always visible and changes its view depending on
  /// the value of [selectedCharacter].
  const CharacterDetailTablet({
    super.key,
    // required this.selectedCharacter,
  });

  /// ValueListenable used in ValueListenableBuilder.
  /// When value is null, an empty Container is shown.
  /// When value is not null, character image (if imageURL
  /// is not empty), name, and description are shown.
  /// Transitions are fade-animated.
  // final ValueListenable<Character?> selectedCharacter;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Character?>(
      valueListenable:
          ListDetail.of<Character>(context).controller.selectedItem,
      builder: (context, character, _) {
        Widget body;

        if (character != null) {
          List<Widget> children = [
            Expanded(
              child: CharacterImage(
                character: character,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CharacterDescription(
                character: character,
              ),
            )
          ];
          body = Column(
            mainAxisSize: MainAxisSize.max,
            children: children,
          );
        } else {
          body = Container();
        }
        return AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          child: Container(
            key: ValueKey(character?.hashCode ?? 'null'),
            child: body,
          ),
        );
      },
    );
  }
}

/// Character detail view for smaller screens. Instead of
/// being always visible, this view is only shown
/// when an item in CharacterList is tapped.
/// Then [character] is passed to this view which displays
/// character image (if imageURL is not empty), name,
/// and description are shown.
class CharacterDetailPhone extends StatelessWidget {
  /// Creates character detail view for smaller screens. Instead of
  /// being always visible, this view is only shown
  /// when an item in CharacterList is tapped.
  /// Then [character] is passed to this view which displays
  /// character image (if imageURL is not empty), name,
  /// and description are shown.
  const CharacterDetailPhone({super.key, required this.character});

  /// The character for which details are shown.
  final Character character;

  @override
  Widget build(BuildContext context) {
    Widget body;

    List<Widget> children = [
      Expanded(
        child: Padding(
          padding: Platform.isIOS ? kCupertinoNavBarHeight : EdgeInsets.zero,
          child: CharacterImage(
            character: character,
          ),
        ),
      ),
      Padding(
        padding: kCupertinoDescriptionPadding,
        child: CharacterDescription(
          character: character,
        ),
      )
    ];
    body = Column(
      mainAxisSize: MainAxisSize.max,
      children: children,
    );

    final title = Text(character.name);
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: title),
        child: body,
      );
    }
    return Scaffold(
      appBar: AppBar(title: title),
      body: body,
    );
  }
}

/// Shows the newtork image of [character.imageURL] if it is
/// not empty otherwise shows a "no image" asset.
class CharacterImage extends StatelessWidget {
  /// Creates a widget that shows the newtork image of
  ///  [character.imageURL] if it is not empty otherwise
  ///  shows a "no image" asset.
  const CharacterImage({
    super.key,
    required this.character,
  });

  final Character character;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kCupertinoNavBarHeight,
      child: LayoutBuilder(builder: (context, constraints) {
        return character.imageURL.isEmpty
            ? Image.asset(
                'assets/no_image.png',
                fit: BoxFit.contain,
              )
            : Image.network(
                '$kImageUrlPrefix${character.imageURL}',
                fit: BoxFit.contain,
              );
      }),
    );
  }
}

/// Shows the [character.name] and [character.description]
/// in a platfor adaptive list tile.
class CharacterDescription extends StatelessWidget {
  /// Creates a widget that shows the [character.name] and
  ///  [character.description] in a platfor adaptive list tile.
  const CharacterDescription({
    super.key,
    required this.character,
  });

  final Character character;

  @override
  Widget build(BuildContext context) {
    final title = Text(character.name);
    return Platform.isIOS
        ? CupertinoListTile(
            title: title,
            subtitle: Text(
              character.description,
              style: const TextStyle(fontSize: 16.0),
              maxLines: 50,
            ),
          )
        : ListTile(
            title: title,
            subtitle: Text(character.description),
          );
  }
}
