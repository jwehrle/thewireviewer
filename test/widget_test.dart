import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wireviewer/base/controllers/app_controller.dart';

import 'package:wireviewer/base/models/character.dart';
import 'package:wireviewer/base/views/adaptive_layout.dart';
import 'package:wireviewer/base/views/character_detail.dart';
import 'package:wireviewer/base/views/character_list.dart';

class MockAppController extends Mock implements AppController {}

/// Example character map taken from successful API result.
const Map<String, dynamic> wellFormedCharacterMap = {
  "FirstURL": "https://duckduckgo.com/Apu_Nahasapeemapetilan",
  "Icon": {"Height": "", "URL": "/i/99b04638.png", "Width": ""},
  "Result":
      "<a href=\"https://duckduckgo.com/Apu_Nahasapeemapetilon\">Apu Nahasapeemapetilon</a><br>Apu Nahasapeemapetilon is a recurring char…",
  "Text":
      "Apu Nahasapeemapetilon - Apu Nahasapeemapetilon is a recurring character in the American animated television series The Simpsons…",
};

/// Example character map with only one word in Text field. Edge case for name extraction.
const Map<String, dynamic> textWithSingleCharacterMap = {
  "FirstURL": "https://duckduckgo.com/Apu_Nahasapeemapetilan",
  "Icon": {"Height": "", "URL": "/i/99b04638.png", "Width": ""},
  "Result":
      "<a href=\"https://duckduckgo.com/Apu_Nahasapeemapetilon\">Apu Nahasapeemapetilon</a><br>Apu Nahasapeemapetilon is a recurring char…",
  "Text": "Apu",
};

/// Example character map with no image url. Happens frequently.
const Map<String, dynamic> noImageCharacterMap = {
  "FirstURL": "https://duckduckgo.com/Apu_Nahasapeemapetilan",
  "Icon": {"Height": "", "URL": "", "Width": ""},
  "Result":
      "<a href=\"https://duckduckgo.com/Apu_Nahasapeemapetilon\">Apu Nahasapeemapetilon</a><br>Apu Nahasapeemapetilon is a recurring char…",
  "Text":
      "Apu Nahasapeemapetilon - Apu Nahasapeemapetilon is a recurring character in the American animated television series The Simpsons…",
};

/// Example character map with no image url. Happens frequently.
const Map<String, dynamic> weirdImageCharacterMap = {
  "FirstURL": "https://duckduckgo.com/Apu_Nahasapeemapetilan",
  "Icon": {"Height": "", "URL": true, "Width": ""},
  "Result":
      "<a href=\"https://duckduckgo.com/Apu_Nahasapeemapetilon\">Apu Nahasapeemapetilon</a><br>Apu Nahasapeemapetilon is a recurring char…",
  "Text":
      "Apu Nahasapeemapetilon - Apu Nahasapeemapetilon is a recurring character in the American animated television series The Simpsons…",
};

/// Example character map for failed API result.
const Map<String, dynamic> emptyCharacterMap = {};

void main() {
  late String body;
  late List<Character> characterList;

  setUp(() async {
    body = await rootBundle.loadString('assets/test_response_body.json');
    characterList = [
      Character(
          name: "Apu Nahasapeemapetilan",
          description:
              "Apu Nahasapeemapetilan - Apu Nahasapeemapetilan is a recurring character in the American animated television series The Simpsons. He is an Indian immigrant proprietor who runs the Kwik-E-Mart, a popular convenience store in Springfield, and is known for his catchphrase, \"Thank you, come again\".",
          imageURL: ""),
      Character(
          name: "Apu Nahasapeemapetilon",
          description:
              "Apu Nahasapeemapetilon - Apu Nahasapeemapetilon is a recurring character in the American animated television series The Simpsons. He is an Indian immigrant proprietor who runs the Kwik-E-Mart, a popular convenience store in Springfield, and is known for his catchphrase, \"Thank you, come again\".",
          imageURL: "/i/99b04638.png"),
      Character(
          name: "Barney Gumble",
          description:
              "Barney Gumble - Barnard Arnold \"Barney\" Gumble is a recurring character in the American animated TV series The Simpsons. He is voiced by Dan Castellaneta and first appeared in the series premiere episode \"Simpsons Roasting on an Open Fire\". Barney is the town drunk of Springfield and one of Homer Simpson's friends.",
          imageURL: "/i/39ce98c0.png"),
      Character(
          name: "Bart Simpson",
          description:
              "Bart Simpson - Bartholomew Jojo \"Bart\" Simpson is a fictional character in the American animated television series The Simpsons and part of the Simpson family. He is voiced by Nancy Cartwright and first appeared on television in The Tracey Ullman Show short \"Good Night\" on April 19, 1987.",
          imageURL: ""),
      Character(
          name: "Bender (Futurama)",
          description:
              "Bender (Futurama) - Bender Bending Rodríguez is one of the main characters in the animated television series Futurama. He was conceived by the series' creators Matt Groening and David X. Cohen, and is voiced by John DiMaggio.",
          imageURL: "/i/cb4121fd.png"),
    ];
  });

  group('Character model tests', () {
    test('Character test: Wellformed map', () {
      Character character = Character.fromMap(wellFormedCharacterMap);
      expect(character.name, "Apu Nahasapeemapetilon");
      expect(character.description,
          "Apu Nahasapeemapetilon - Apu Nahasapeemapetilon is a recurring character in the American animated television series The Simpsons…");
      expect(character.imageURL, "/i/99b04638.png");
    });

    test('Character test: Text with single word map', () {
      Character character = Character.fromMap(textWithSingleCharacterMap);
      expect(character.name, "Apu");
      expect(character.description, "Apu");
      expect(character.imageURL, "/i/99b04638.png");
    });

    test('Character test: No image map', () {
      Character character = Character.fromMap(noImageCharacterMap);
      expect(character.name, "Apu Nahasapeemapetilon");
      expect(character.description,
          "Apu Nahasapeemapetilon - Apu Nahasapeemapetilon is a recurring character in the American animated television series The Simpsons…");
      expect(character.imageURL, "");
    });

    test('Character test: No image map', () {
      Character character = Character.fromMap(weirdImageCharacterMap);
      expect(character.name, "Apu Nahasapeemapetilon");
      expect(character.description,
          "Apu Nahasapeemapetilon - Apu Nahasapeemapetilon is a recurring character in the American animated television series The Simpsons…");
      expect(character.imageURL, "");
    });

    test('Character test: Empty map', () {
      Character character = Character.fromMap(emptyCharacterMap);
      expect(character.name, "");
      expect(character.description, "");
      expect(character.imageURL, "");
    });
  });

  group("AppController tests", () {
    MockClient client =
        MockClient((request) => Future.value(Response(body, 200)));

    test('showName', () {
      AppController controller = AppController(
        showName: "simpsons",
        client: client,
      );
      expect(controller.showName, "simpsons");
      controller.dispose();
    });

    test('fetchAll', () async {
      AppController controller = AppController(
        showName: "simpsons",
        client: client,
      );
      final result = await controller.fetchAll();
      expect(result, characterList);
      controller.dispose();
    });

    test('select', () {
      Character character = Character.fromMap(wellFormedCharacterMap);
      AppController controller = AppController(
        showName: "simpsons",
        client: client,
      );
      controller.selectedCharacter
          .addListener(() => expect(controller.selectedCharacter, character));
      controller.select = character;
      controller.dispose();
    });

    test('unselect', () {
      AppController controller = AppController(
        showName: "simpsons",
        client: client,
      );
      controller.selectedCharacter
          .addListener(() => expect(controller.selectedCharacter, null));
      controller.select = null;
      controller.dispose();
    });
  });

  testWidgets('AdaptiveLayout displays Character list',
      (WidgetTester tester) async {
    MockClient client =
        MockClient((request) => Future.value(Response(body, 200)));
    final controller = AppController(showName: 'Simpsons', client: client);
    await tester.pumpWidget(MaterialApp(
        home: AdaptiveLayout(
      appTitle: 'Test Title',
      controller: controller,
    )));
    expect(find.byType(CharacterList), findsOneWidget);
    await tester.pumpAndSettle();
    // find an item by text and tap
    final gumbleFinder = find.widgetWithText(ListTile, 'Barney Gumble');
    expect(gumbleFinder, findsOneWidget);
    await tester.tap(gumbleFinder);
    controller.dispose();
  });

  testWidgets('CharacterDetailPhone', (WidgetTester tester) async {
    await mockNetworkImages(
      () async => tester.pumpWidget(
        MaterialApp(
          home: CharacterDetailPhone(
            character: characterList[2],
          ),
        ),
      ),
    );
    expect(find.byType(CharacterImage), findsOneWidget);
    expect(find.byType(CharacterDescription), findsOneWidget);
  });

  testWidgets('CharacterDetailTablet', (WidgetTester tester) async {
    final ValueNotifier<Character?> selectedCharacter =
        ValueNotifier(characterList[2]);

    await mockNetworkImages(
      () async => tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: CharacterDetailTablet(
              selectedCharacter: selectedCharacter,
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CharacterImage), findsOneWidget);
    expect(find.byType(CharacterDescription), findsOneWidget);

    selectedCharacter.dispose();
  });
}
