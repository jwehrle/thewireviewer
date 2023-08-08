import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:simpsonsviewer/base/controllers/app_controller.dart';
import 'package:simpsonsviewer/base/models/character.dart';
import 'package:simpsonsviewer/base/models/constants.dart';
import 'package:simpsonsviewer/base/views/character_detail.dart';
import 'package:simpsonsviewer/base/views/character_list.dart';

/// Display for app. Adaptive to size (tablet or phone), orientation
/// (in large size), and platform (iOS or otherwise).
/// In large mode, displays list + detail of selected Character.
/// In small mode, displays list.
class AdaptiveLayout extends StatelessWidget {
  /// Creates a widget that displays for app. Adaptive to size
  ///  (tablet or phone), orientation (in large size), and
  /// platform (iOS or otherwise). In large mode, displays
  /// list + detail of selected Character. In small mode, displays list.
  const AdaptiveLayout({
    super.key,
    required this.appTitle,
    required this.controller,
  });

  final String appTitle;

  /// Controller for fetching list of characters and selecting
  /// characters
  final AppController controller;

  /// Determines whether device is larger than a typical phone
  bool _isLarge(BuildContext context, BoxConstraints constraints) {
    bool isLarge;
    if (constraints.hasBoundedHeight && constraints.hasBoundedWidth) {
      double shortest = constraints.maxHeight > constraints.maxWidth
          ? constraints.maxWidth
          : constraints.maxHeight;
      isLarge = shortest > kSizeBreakPoint;
    } else {
      isLarge = MediaQuery.of(context).size.shortestSide > kSizeBreakPoint;
    }
    return isLarge;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SizeAdaptiveView(
            appTitle: appTitle,
            isLarge: _isLarge(context, constraints),
            orientation: orientation,
            getCharacterList: controller.fetchAll,
            onSelect: (character) => controller.select = character,
            selectedCharacter: controller.selectedCharacter,
          );
        },
      );
    });
  }
}

/// Displays either [ListDetail] or [CharacterList] depending
/// on [isLarge].
/// [isLarge] : Whether device is larger than a phone (tablet)
/// [orientation] : Orientation of device, used by [ListDetail]
/// [selectedCharacter] : ValueListenable of character used by
/// both [ListDetail] and [CharacterList]
/// [getCharacterList] : Function used to fetch list of characters
/// [onSelect] : Function used to select character
class SizeAdaptiveView extends StatelessWidget {
  /// Creates a widget that displays either [ListDetail] or
  /// [CharacterList] depending on [isLarge].
  /// [isLarge] : Whether device is larger than a phone (tablet)
  /// [orientation] : Orientation of device, used by [ListDetail]
  /// [selectedCharacter] : ValueListenable of character used by
  /// both [ListDetail] and [CharacterList]
  /// [getCharacterList] : Function used to fetch list of characters
  /// [onSelect] : Function used to select character
  const SizeAdaptiveView({
    super.key,
    required this.appTitle,
    required this.isLarge,
    required this.orientation,
    required this.selectedCharacter,
    required this.getCharacterList,
    required this.onSelect,
  });

  final String appTitle;

  ///Whether device is larger than a phone (tablet)
  final bool isLarge;

  /// Orientation of device, used by [ListDetail]
  final Orientation orientation;

  /// ValueListenable of character used by
  /// both [ListDetail] and [CharacterList]
  final ValueListenable<Character?> selectedCharacter;

  /// Function used to fetch list of characters
  final Future<List<Character>> Function() getCharacterList;

  /// Function used to select character
  final ValueChanged<Character?> onSelect;

  @override
  Widget build(BuildContext context) {
    return isLarge
        ? ListDetail(
            appTitle: appTitle,
            orientation: orientation,
            selectedCharacter: selectedCharacter,
            getCharacterList: getCharacterList,
            onSelect: onSelect,
          )
        : CharacterList(
            appTitle: appTitle,
            getCharacterList: getCharacterList,
            onSelect: onSelect,
            useScaffold: true,
          );
  }
}

/// Displays both list and deatil views. Facilitates search
/// and selection and detail display in one view.
/// [orientation] determines the location of list and detail.
/// [selectedCharacter] ValueListenable detail listens to.
/// [getCharacterList] Function returns Future<List<Character>>
/// [onSelect] callback for list to select characters.
class ListDetail extends StatelessWidget {
  /// Creates a widget that displays both list and deatil views.
  /// Facilitates search and selection and detail display in one view.
  /// [orientation] determines the location of list and detail.
  /// [selectedCharacter] ValueListenable detail listens to.
  /// [getCharacterList] Function returns Future<List<Character>>
  /// [onSelect] callback for list to select characters.
  const ListDetail({
    super.key,
    required this.appTitle,
    required this.orientation,
    required this.selectedCharacter,
    required this.getCharacterList,
    required this.onSelect,
  });

  final String appTitle;

  /// Device orientation. Determines direction and location
  /// of list and detail
  final Orientation orientation;

  /// ValueListenable to which detail listens to displays
  /// character details.
  final ValueListenable<Character?> selectedCharacter;

  /// Function that fetches list of characters for use by list.
  final Future<List<Character>> Function() getCharacterList;

  /// Callback for list items to select character
  final ValueChanged<Character?> onSelect;

  final String _listHero = 'list_hero';
  final String _detailHero = 'detail_hero';

  @override
  Widget build(BuildContext context) {
    // Make basic list view
    Widget list = Hero(
      tag: _listHero,
      child: CharacterList(
        appTitle: appTitle,
        getCharacterList: getCharacterList,
        onSelect: onSelect,
        useScaffold: false,
      ),
    );
    list = Flexible(
      flex: kListFlex,
      child: list,
    );
    Widget detail = Hero(
      tag: _detailHero,
      child: CharacterDetailTablet(
        selectedCharacter: selectedCharacter,
      ),
    );
    detail = Flexible(
      flex: kDetailFlex,
      child: detail,
    );
    // Assemble Flex params
    final Axis direction;
    final List<Widget> flexChildren;
    if (orientation == Orientation.portrait) {
      direction = Axis.vertical;
      flexChildren = [detail, const Divider(), list];
    } else {
      direction = Axis.horizontal;
      flexChildren = [list, const Divider(), detail];
    }
    final body = Flex(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: direction,
      children: flexChildren,
    );
    const Widget title = Text('The Simpsons');
    return Platform.isIOS
        ? CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: title,
            ),
            child: Padding(
              padding: kCupertinoNavBarHeight,
              child: body,
            ),
          )
        : Scaffold(
            appBar: AppBar(title: title),
            body: body,
          );
  }
}
