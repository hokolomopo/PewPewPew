import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math';
import 'dart:ui' as ui;

import 'background.dart';
import 'level.dart';
import 'terrain.dart';
import 'Character.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // To counter Flutter update inconvenient
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(new PewPewPew());
  });
}

class PewPewPew extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pew Pew Pew !!!',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Color(0xFFC0F0E8),
        primaryColor: Colors.red,
        // 0xFF80E1D1
        fontFamily: "Heroes",
        canvasColor: Colors.transparent,
      ),
      home: DrawTest(), //new HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class DrawTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawTestState();
}

class _DrawTestState extends State<DrawTest> {
  LevelPainter levelPainter = LevelPainter();

  TerrainDrawer terrainDrawer = TerrainDrawer();
  BackgroundDrawer backgroundDrawer = BackgroundDrawer();

  List<CharacterDrawer> characters = List();

  ui.Image backgroundImg;

  @override
  void initState() {
    super.initState();
    levelPainter.addElement(backgroundDrawer);

    levelPainter.addElement(terrainDrawer);
    terrainDrawer.createTerrainFromFunction(
        (left) => ((sin(left / 25 * pi) + 2) * 10),
        nbBlocks: 1000);
    terrainDrawer.addTerrainBlock(Offset(20.0, 50.0), width: 20.0, height: 10.0);

    characters.add(CharacterDrawer(
        "assets/graphics/characters/rotated_worm.png", Offset(20.0, 60.0)));
    characters.add(CharacterDrawer(
        "assets/graphics/characters/worm.png", Offset(80.0, 60.0)));

    characters.forEach((character) {
      levelPainter.addElement(character);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onTapDown: (details) {
            _testTap(details, context);
          },
          child: levelPainter.level,
        ),
      ),
    );
  }

  _testTap(TapDownDetails details, BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double dxProp = details.localPosition.dx / screenSize.width;
    double dyProp = details.localPosition.dy / screenSize.height;
    setState(() {
      characters[0].decreaseLife(0.05);
      characters[0].move(Offset(5, -1));
      characters[1].decreaseLife(0.1);
      characters[1].move(Offset(-5, 0.2));
    });
  }
}
