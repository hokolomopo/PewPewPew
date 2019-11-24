import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info2051_2018/draw/background.dart';
import 'package:info2051_2018/draw/level_painter.dart';
import 'package:info2051_2018/game/camera.dart';
import 'package:info2051_2018/game/character.dart';
import 'package:info2051_2018/game/game_state.dart';

import '../level.dart';
import '../terrain.dart';

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

  List<TerrainBlock> blocks = List();

  _LevelCreatorState(){
    level = Level();
    level.size = Size(400, 150);

    camera = Camera(Offset(0,0));
    //camera.zoom = Offset(100 / level.size.width, 100 / level.size.height / (16 / 9));
    camera.zoom = Offset(0.4,0.4);

    this.levelPainter = LevelPainter(camera, level.size, showHitBoxes: false);
    levelPainter.addElement(BackgroundDrawer(level.size));

    createSpawns();

    GameState(4, 4, levelPainter, level, camera);
  }

  Widget initThings(){
    for(TerrainBlock block in blocks)
      levelPainter.removeElement(block.drawer);

    blocks.removeRange(0, blocks.length);

    createLevel();

    for(TerrainBlock block in blocks)
      levelPainter.addElement(block.drawer);

    return levelPainter.level;
  }

  void createLevel(){
    blocks.add(new TerrainBlock(-100, 70, 20000, 10));
    blocks.add(new TerrainBlock(150, 0, 10, 20000));
    blocks.add(new TerrainBlock(50, 40, 50, 10));
  }

  void createSpawns(){
    for(int i = 0;i < 16;i++)
      level.spawnPoints.add(Offset(15.0*i, 10));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
          child :GestureDetector(
              onLongPress: () {
                print("LongPress");
              },
              child: initThings()
          )
      ),
    );
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
}