import 'package:flutter/material.dart';

/// Leargest size of shortest side of a phone
const double kSizeBreakPoint = 550.0;

/// Flex for list in large mode
const int kListFlex = 2;

/// Flex for detail in large mode
const int kDetailFlex = 3;

/// Height of CupertinoNavigationBar. 
/// Used for avoiding nav bar overlap
const EdgeInsets kCupertinoNavBarHeight = EdgeInsets.only(top: 68.0);

/// Standard Material padding. Used for 
/// SearchAnchor since it isn't being placed inside an AppBar.
const EdgeInsets kMaterialSearchPadding = EdgeInsets.symmetric(horizontal: 8.0);

/// Padding for CupertinoListTile in CharacterDescription
const EdgeInsets kCupertinoDescriptionPadding = EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 32.0);

/// URL to which image urls are added in CharacterImage
const String kImageUrlPrefix = 'https://duckduckgo.com/';