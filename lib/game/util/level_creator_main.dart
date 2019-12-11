import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/assets_manager.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/game_state.dart';
import 'package:info2051_2018/game/util/utils.dart';
import 'package:info2051_2018/game/world.dart';
import 'dart:convert';

import '../game_main.dart';
import '../level.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // To counter Flutter update inconvenient
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then( (_) {runApp(new PewPewPewLevelCreator()); });
}

class PewPewPewLevelCreator extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
        title: 'Pew Pew Pew !!!',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
          hintColor: Color(0xFFC0F0E8),
          primaryColor: Colors.lightBlue, // 0xFF80E1D1
          fontFamily: "Heroes",
          canvasColor: Colors.transparent,
        ),
        home: RandomScreen()  //new HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class RandomScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("press"),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LevelCreatorMain()),
        );
      },
    );
  }

}

class LevelCreatorMain extends StatefulWidget {
  LevelCreatorMain({Key key}) : super(key: key);

  static Size size;

  @override
  _LevelCreatorState createState() => new _LevelCreatorState();
}

class _LevelCreatorState extends State<LevelCreatorMain> {

  LevelPainter levelPainter;
  Level level;
  Camera camera;

  //List<TerrainBlock> blocks = List();

  _LevelCreatorState(){
    level = Level();
    level.size = Size(600, 300);
    level.color = HexColor("808080");

    camera = Camera(Offset(0,0));
    //camera.zoom = Offset(100 / level.size.width, 100 / level.size.height / (16 / 9));
    camera.zoom = Offset(0.3,0.3);

    AssetsManager assetManager = AssetsManager(level.size, "assets/graphics/backgrounds/space.jpg", 4);
    levelPainter = LevelPainter(camera, level.size, assetManager);
    levelPainter.addElement(BackgroundDrawer(level.size, AssetId.background));

    createSpawns();

    state = GameState(4, 4, levelPainter, level, camera, World());
  }

  Widget initThings(){
    for(TerrainBlock block in level.terrain)
      levelPainter.removeElement(block.drawer);

    level.terrain.removeRange(0, level.terrain.length);

    createLevel();

    for(TerrainBlock block in level.terrain)
      levelPainter.addElement(block.drawer);

    level.color = HexColor("808080");

    _scheduleFrame();

    return levelPainter.level;
  }

  void createLevel(){
    // Create terrain in cartesian coordinates (y from bot to top)
    level.terrain.add(new TerrainBlock(40, 200, 50, 10));
    level.terrain.add(new TerrainBlock(120, 250, 50, 10));
    level.terrain.add(new TerrainBlock(70, 150, 70, 10));

    level.terrain.add(new TerrainBlock(180, 165, 60, 10));
    level.terrain.add(new TerrainBlock(200, 210, 25, 10));
    level.terrain.add(new TerrainBlock(130, 120, 80, 10));

    level.terrain.add(new TerrainBlock(260, 130, 50, 10));
    level.terrain.add(new TerrainBlock(360, 130, 50, 10));
    level.terrain.add(new TerrainBlock(430, 180, 70, 10));

    level.terrain.add(new TerrainBlock(390, 90, 80, 10));
    level.terrain.add(new TerrainBlock(460, 70, 30, 10));
    level.terrain.add(new TerrainBlock(490, 100, 70, 10));

    level.terrain.add(new TerrainBlock(530, 145, 40, 10));


    // Invert Y axis
    for(TerrainBlock block in level.terrain)
      block.hitBox = Rectangle(block.hitBox.left, level.size.height - block.hitBox.top,
          block.hitBox.width, block.hitBox.height);
  }

  void createSpawns(){
    level.spawnPoints.add(Offset(65, 50));
    level.spawnPoints.add(Offset(145, 20));
    level.spawnPoints.add(Offset(80, 70));
    level.spawnPoints.add(Offset(120, 80));

    level.spawnPoints.add(Offset(210, 120));
    level.spawnPoints.add(Offset(210, 50));
    level.spawnPoints.add(Offset(145, 100));
    level.spawnPoints.add(Offset(160, 100));

    level.spawnPoints.add(Offset(285, 100));
    level.spawnPoints.add(Offset(385, 100));
    level.spawnPoints.add(Offset(440, 100));
    level.spawnPoints.add(Offset(465, 100));

    level.spawnPoints.add(Offset(420, 100));
    level.spawnPoints.add(Offset(500, 170));
    level.spawnPoints.add(Offset(540, 170));

    level.spawnPoints.add(Offset(550, 100));
  }

  int _callbackId;
  /// Schedule an execution of the _update function for the next frame
  void _scheduleFrame() {
    _callbackId = SchedulerBinding.instance.scheduleFrameCallback(_update);
  }

  /// Unschedule an execution of the _update function for the next frame
  Future<bool> _unscheduleFrame()  {
    SchedulerBinding.instance.cancelFrameCallbackWithId(_callbackId);
    return Future.value(true);
  }

  GameState state;
  Duration lastTimeStamp;

  /// Function called at each frame.
  /// Update the GameState and re-draw the game on the screen
  void _update(Duration timestamp) {
    int timeElapsed =
    lastTimeStamp == null ? 0 : (timestamp - lastTimeStamp).inMilliseconds;
    lastTimeStamp = timestamp;

    if (levelPainter.gameStarted) {
      state.update(1000);
    }

    setState(() {});
    _scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    GameMain.size = MediaQuery
        .of(context)
        .size;
    levelPainter.screenSize = GameMain.size;
    Size s = GameMain.size;
    if(s.height > s.width)
      s = Size(s.height, s.width);
    levelPainter.assetsManager.init(GameMain.size);

    return new Scaffold(
      body: WillPopScope(
        onWillPop: _unscheduleFrame,
        child: Container(
          child :GestureDetector(
              onLongPress: () {
                JsonEncoder encoder = new JsonEncoder.withIndent('  ');
                String prettyPrint = encoder.convert(level);

                Map jsonMap = jsonDecode(prettyPrint);
                Level plz = Level.fromJson(jsonMap);

                prettyPrint = jsonEncode(plz);

                print(prettyPrint);

                print(prettyPrint.substring(0, 200));
                print(prettyPrint.substring(200, prettyPrint.length));


              },
              child: initThings()
          )
              )));
  }

  @override
  void initState() {
    super.initState();

    //Set orientation to landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    //Disable Device status bar
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  dispose() {
    _unscheduleFrame();
    super.dispose();
  }

}



/// Level 1
/*
  void createLevel(){
    // Create terrain in cartesian coordinates (y from bot to top)
    level.terrain.add(new TerrainBlock(100, 90, 50, 90));
    level.terrain.add(new TerrainBlock(150, 65, 100, 65));
    level.terrain.add(new TerrainBlock(250, 50, 100, 50));
    level.terrain.add(new TerrainBlock(350, 65, 100, 65));
    level.terrain.add(new TerrainBlock(450, 90, 50, 90));

    level.terrain.add(new TerrainBlock(175, 115, 60, 10));
    level.terrain.add(new TerrainBlock(250, 135, 100, 10));
    level.terrain.add(new TerrainBlock(365, 115, 60, 10));
    level.terrain.add(new TerrainBlock(270, 90, 60, 10));


    // Invert Y axis
    for(TerrainBlock block in level.terrain)
      block.hitBox = Rectangle(block.hitBox.left, level.size.height - block.hitBox.top,
          block.hitBox.width, block.hitBox.height);
  }

  void createSpawns(){
    level.spawnPoints.add(Offset(125, 60));
    level.spawnPoints.add(Offset(160, 110));
    level.spawnPoints.add(Offset(240, 110));
    level.spawnPoints.add(Offset(270, 130));
    level.spawnPoints.add(Offset(295, 130));
    level.spawnPoints.add(Offset(320, 130));
    level.spawnPoints.add(Offset(360, 110));
    level.spawnPoints.add(Offset(430, 110));
    level.spawnPoints.add(Offset(475, 60));

    level.spawnPoints.add(Offset(180, 60));
    level.spawnPoints.add(Offset(215, 60));
    level.spawnPoints.add(Offset(260, 40));
    level.spawnPoints.add(Offset(320, 40));
    level.spawnPoints.add(Offset(375, 60));
    level.spawnPoints.add(Offset(405, 60));

    level.spawnPoints.add(Offset(300, 80));
  }
 */



///Level 2
/*
  void createLevel(){
    // Create terrain in cartesian coordinates (y from bot to top)
    level.terrain.add(new TerrainBlock(100, 130, 30, 130));
    level.terrain.add(new TerrainBlock(130, 100, 30, 100));
    level.terrain.add(new TerrainBlock(160, 70, 30, 70));
    level.terrain.add(new TerrainBlock(190, 40, 30, 40));
    level.terrain.add(new TerrainBlock(220, 10, 30, 10));
    level.terrain.add(new TerrainBlock(250, 20, 30, 20));
    level.terrain.add(new TerrainBlock(280, 40, 60, 40));
    level.terrain.add(new TerrainBlock(340, 20, 30, 20));
    level.terrain.add(new TerrainBlock(370, 10, 30, 10));
    level.terrain.add(new TerrainBlock(400, 40, 30, 40));
    level.terrain.add(new TerrainBlock(430, 70, 30, 70));
    level.terrain.add(new TerrainBlock(460, 100, 30, 100));
    level.terrain.add(new TerrainBlock(490, 130, 30, 130
    ));


    // Invert Y axis
    for(TerrainBlock block in level.terrain)
      block.hitBox = Rectangle(block.hitBox.left, level.size.height - block.hitBox.top,
          block.hitBox.width, block.hitBox.height);
  }

  void createSpawns(){
    level.spawnPoints.add(Offset(100, 50));
    level.spawnPoints.add(Offset(120, 50));
    level.spawnPoints.add(Offset(145, 50));
    level.spawnPoints.add(Offset(175, 50));
    level.spawnPoints.add(Offset(205, 50));
    level.spawnPoints.add(Offset(235, 50));
    level.spawnPoints.add(Offset(265, 50));
    level.spawnPoints.add(Offset(295, 50));
    level.spawnPoints.add(Offset(325, 50));
    level.spawnPoints.add(Offset(355, 50));
    level.spawnPoints.add(Offset(385, 50));
    level.spawnPoints.add(Offset(415, 50));
    level.spawnPoints.add(Offset(445, 50));
    level.spawnPoints.add(Offset(475, 50));
    level.spawnPoints.add(Offset(490, 50));
    level.spawnPoints.add(Offset(510, 50));
  }
 */

///LEVEL 3 SPAAAACE
/*
 */