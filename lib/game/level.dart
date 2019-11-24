import 'dart:ui';

import 'package:info2051_2018/game/terrain.dart';

class Level{
  Size size;
  String backgroundImage;

  List<TerrainBlock> terrain = List();
  List<Offset> spawnPoints = List();

  //TODO Delete dis
  Level();

  ///Load a level from a level file
  static Level loadLevel(String levelName){
    //TODO

    return null;
  }

  void addTerrain(TerrainBlock terrainBlock){
    terrain.add(terrainBlock);
  }

  void addSpawnPoint(Offset point){
    spawnPoints.add(point);
  }

}