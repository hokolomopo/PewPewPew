import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math';
import 'dart:ui' as ui;

import 'background.dart';
import 'level.dart';
import 'terrain.dart';

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

  ui.Image backgroundImg;

  @override
  void initState() {
    super.initState();
    levelPainter.addElement(backgroundDrawer);

    levelPainter.addElement(terrainDrawer);
    terrainDrawer.createTerrainFromFunction(
        (left) => ((sin(left * 4 * pi) + 2) / 10),
        nbBlocks: 1000);
    terrainDrawer.addTerrainBlock(Offset(0.3, 0.5), width: 0.2, height: 0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onTapDown: (details) {_testTap(details, context);},
          child: levelPainter.level,
        ),
      ),
    );
  }

  _testTap(TapDownDetails details, BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double dxProp = details.localPosition.dx / screenSize.width;
    double dyProp = details.localPosition.dy / screenSize.height;
    Set<Offset> set = Set();
    set.add(Offset(0.3, 0.5));
    setState(() {
      terrainDrawer.removeBlocksInRange(Offset(dxProp, dyProp), 0.05);
    });
  }
}
