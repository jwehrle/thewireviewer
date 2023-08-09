import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wireviewer/base/controllers/app_controller.dart';
import 'package:wireviewer/base/views/adaptive_layout.dart';

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

  @override
  void initState() {
    super.initState();
    _client = http.Client();
    _controller = AppController(showName: kTheWireID, client: _client);
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoApp(
        title: kAppTitle,
        home: AdaptiveLayout(
          appTitle: kAppTitle,
          controller: _controller,
        ),
      );
    }
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AdaptiveLayout(
        appTitle: kAppTitle,
        controller: _controller,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _client.close();
    super.dispose();
  }
}
