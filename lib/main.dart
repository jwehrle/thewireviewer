import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:list_detail_base/list_detail_base.dart';
import 'package:wireviewer/base/controllers/app_controller.dart';

import 'base/models/character.dart';
import 'base/views/character_detail.dart';
import 'base/views/character_list.dart';

const String kTheWireID = 'the+wire';
const String kAppTitle = 'The Wire Character Viewer';

void main() {
  runApp(const TheWireViewerApp());
}

/// App for exploring the characters of The Simpsons TV Show.
/// Adaptive for:
/// - Android and iOS
/// - Phone and Tablet
/// - Light and Dark modes
class TheWireViewerApp extends StatefulWidget {
  const TheWireViewerApp({super.key});

  @override
  State<StatefulWidget> createState() => TheWireViewerAppState();
}

class TheWireViewerAppState extends State<TheWireViewerApp> {
  late final AppController _controller;
  late final http.Client _client;

  /// Prevents TextFields in [CharacterListBody] from being reassigned
  /// on orientation changes.
  final GlobalKey<CharacterListBodyState> _characterListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _controller = AppController(
      showName: kTheWireID,
      client: _client,
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller
          .fetchAll()
          .then((value) => _controller.characterList = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget layout = ListDetail(
      controller: _controller,
      child: Builder(
        builder: (innerContext) {
          return ListDetailLayout<Character>(
            controller: _controller,
            listBuilder: (context) {
              return  SizedBox(
                key: _characterListKey,
                child: const CharacterListBody(
                  appTitle: kAppTitle,
                  // characters: _characterList!,
                ),
              );
            },
            detailBuilder: (context) => const CharacterDetailTablet(),
          );
        },
      ),
    );

    return Platform.isIOS
        ? CupertinoApp(
            title: kAppTitle,
            home: CupertinoPageScaffold(
              navigationBar:
                  const CupertinoNavigationBar(middle: Text(kAppTitle)),
              child: Padding(
                padding: const EdgeInsets.only(top: 68.0, bottom: 32.0),
                child: layout,
              ),
            ),
          )
        : MaterialApp(
            title: kAppTitle,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: Scaffold(
              appBar: AppBar(title: const Text(kAppTitle)),
              body: layout,
            ),
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    _client.close();
    // _strCtl.close();
    super.dispose();
  }
}
